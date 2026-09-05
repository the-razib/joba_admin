import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { VertexAI, HarmCategory, HarmBlockThreshold } from '@google-cloud/vertexai';

interface SathiPolicy {
  enabled: boolean;
  visibleInMobile: boolean;
  allowGuestUsers: boolean;
  safetyFilterEnabled: boolean;
  budgetProtectionEnabled: boolean;
  fallbackResponsesEnabled: boolean;
  dailyCallsPerUser: number;
  monthlyBudgetUsd: number;
  defaultModel: string;
  maxOutputTokens: number;
  temperature: number;
  lastFetched: number;
}

let cachedPolicy: SathiPolicy | null = null;
const POLICY_CACHE_TTL_MS = 60 * 1000; // 1 minute in-memory cache

async function getPolicy(db: FirebaseFirestore.Firestore): Promise<SathiPolicy> {
  const now = Date.now();
  if (cachedPolicy && now - cachedPolicy.lastFetched < POLICY_CACHE_TTL_MS) {
    return cachedPolicy;
  }
  const snap = await db.collection('app_config').doc('sathi_ai').get();
  const data = snap.data() || {};
  cachedPolicy = {
    enabled: data.enabled ?? true,
    visibleInMobile: data.visibleInMobile ?? true,
    allowGuestUsers: data.allowGuestUsers ?? false,
    safetyFilterEnabled: data.safetyFilterEnabled ?? true,
    budgetProtectionEnabled: data.budgetProtectionEnabled ?? true,
    fallbackResponsesEnabled: data.fallbackResponsesEnabled ?? true,
    dailyCallsPerUser: typeof data.dailyCallsPerUser === 'number' ? data.dailyCallsPerUser : 15,
    monthlyBudgetUsd: typeof data.monthlyBudgetUsd === 'number' ? data.monthlyBudgetUsd : 150.0,
    defaultModel: data.defaultModel || 'gemini-2.5-flash-lite',
    maxOutputTokens: typeof data.maxOutputTokens === 'number' ? data.maxOutputTokens : 450,
    temperature: typeof data.temperature === 'number' ? data.temperature : 0.4,
    lastFetched: now,
  };
  return cachedPolicy;
}

function calculateModelCost(model: string, inputTokens: number, outputTokens: number): number {
  let inputRate = 0.10; // per 1M tokens
  let outputRate = 0.40; // per 1M tokens

  if (model.includes('gemini-2.5-flash-lite') || model.includes('gemini-3.1-flash-lite')) {
    inputRate = 0.10;
    outputRate = 0.40;
  } else if (model.includes('gemini-2.5-flash')) {
    inputRate = 0.30;
    outputRate = 2.50;
  } else if (model.includes('pro')) {
    inputRate = 1.25;
    outputRate = 10.00;
  }

  return (inputTokens / 1_000_000) * inputRate + (outputTokens / 1_000_000) * outputRate;
}

const SYSTEM_INSTRUCTION =
  'You are Sathi, an empathetic, culturally sensitive, and medically cautious women’s health education companion in the Joba app. ' +
  'Answer concisely, warmly, and clearly in the language used by the user (Bengali or English).\n\n' +
  'Clinical Rules:\n' +
  '1. Never diagnose, prescribe specific medicine dosages, or claim medical certainty.\n' +
  '2. Never ask for or store personal identification (names, emails, phone numbers) or exact private calendar entries.\n' +
  '3. Urgent Red Flags: If the user mentions heavy bleeding (soaking more than 2 pads per hour), severe unbearable pelvic pain, sudden fainting, high fever with foul discharge, or severe pregnancy complications, firmly advise prompt medical consultation with a qualified gynecologist or healthcare clinic.\n' +
  '4. Scope: Limit answers to menstrual wellness, period hygiene, cramps, ovulation, pregnancy awareness, PCOS/PCOD education, nutrition, and general lifestyle.';

export const sathiChat = onCall(
  {
    region: 'asia-south1',
    maxInstances: 20,
    memory: '256MiB',
    timeoutSeconds: 30,
  },
  async (request) => {
    const db = getFirestore();
    const uid = request.auth?.uid;

    const policy = await getPolicy(db);

    // Check 1: Feature enable & visibility
    if (!policy.enabled || !policy.visibleInMobile) {
      throw new HttpsError(
        'unavailable',
        'Sathi AI is currently unavailable. Please check back later.'
      );
    }

    // Check 2: Auth requirement
    if (!uid && !policy.allowGuestUsers) {
      throw new HttpsError(
        'unauthenticated',
        'Please sign in to your Joba account to chat with Sathi AI.'
      );
    }

    const effectiveUid = uid || 'guest_user';
    const todayKey = new Date().toISOString().split('T')[0];

    // Check 3: Budget Protection
    if (policy.budgetProtectionEnabled) {
      const yearMonth = todayKey.substring(0, 7);
      const monthSnap = await db
        .collection('sathi_ai_usage_daily')
        .where('date', '>=', `${yearMonth}-01`)
        .where('date', '<=', `${yearMonth}-31`)
        .get();

      let currentMonthCost = 0;
      for (const doc of monthSnap.docs) {
        currentMonthCost += Number(doc.data()?.costUsd || 0);
      }

      if (currentMonthCost >= policy.monthlyBudgetUsd) {
        throw new HttpsError(
          'resource-exhausted',
          'Monthly Sathi AI usage budget reached. AI requests are temporarily paused.'
        );
      }
    }

    // Check 4: User Daily Quota
    if (effectiveUid !== 'guest_user') {
      const userUsageRef = db.collection('sathi_ai_user_usage').doc(effectiveUid);
      const userUsageSnap = await userUsageRef.get();
      const userData = userUsageSnap.data();

      let dailyCount = 0;
      if (userData && userData.date === todayKey) {
        dailyCount = Number(userData.count || 0);
      }

      if (dailyCount >= policy.dailyCallsPerUser) {
        throw new HttpsError(
          'resource-exhausted',
          `Daily question limit (${policy.dailyCallsPerUser}) reached for today.`
        );
      }

      await userUsageRef.set(
        {
          date: todayKey,
          count: dailyCount + 1,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
    }

    const userPrompt = String(request.data?.prompt || '').trim();
    if (!userPrompt) {
      throw new HttpsError('invalid-argument', 'Message prompt cannot be empty.');
    }

    // Call Vertex AI / Agent Platform API
    const vertexLocation = process.env.VERTEX_LOCATION || 'us-central1';
    const projectId = process.env.GCLOUD_PROJECT || 'joba-a913b';

    const vertexAi = new VertexAI({
      project: projectId,
      location: vertexLocation,
    });

    const modelName = policy.defaultModel || 'gemini-2.5-flash-lite';
    const generativeModel = vertexAi.getGenerativeModel({
      model: modelName,
      systemInstruction: SYSTEM_INSTRUCTION,
      generationConfig: {
        maxOutputTokens: policy.maxOutputTokens || 450,
        temperature: policy.temperature || 0.4,
      },
      safetySettings: policy.safetyFilterEnabled
        ? [
            {
              category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
              threshold: HarmBlockThreshold.BLOCK_LOW_AND_ABOVE,
            },
            {
              category: HarmCategory.HARM_CATEGORY_HARASSMENT,
              threshold: HarmBlockThreshold.BLOCK_LOW_AND_ABOVE,
            },
            {
              category: HarmCategory.HARM_CATEGORY_HATE_SPEECH,
              threshold: HarmBlockThreshold.BLOCK_LOW_AND_ABOVE,
            },
            {
              category: HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT,
              threshold: HarmBlockThreshold.BLOCK_LOW_AND_ABOVE,
            },
          ]
        : undefined,
    });

    let aiReply = '';
    let inputTokens = 0;
    let outputTokens = 0;

    try {
      const result = await generativeModel.generateContent({
        contents: [{ role: 'user', parts: [{ text: userPrompt }] }],
      });

      aiReply = result.response?.candidates?.[0]?.content?.parts?.[0]?.text?.trim() || '';
      const usageMetadata = result.response?.usageMetadata;
      inputTokens = usageMetadata?.promptTokenCount || Math.ceil(userPrompt.length / 4);
      outputTokens = usageMetadata?.candidatesTokenCount || Math.ceil(aiReply.length / 4);

      if (!aiReply) {
        aiReply = 'আমি দুঃখিত, এই প্রশ্নের উত্তরটি তৈরি করতে পারিনি। অনুগ্রহ করে প্রশ্নটি অন্যভাবে জিজ্ঞাসা করুন।';
      }
    } catch (err: any) {
      console.error('[sathiChat] Vertex AI generation failed:', err);
      throw new HttpsError(
        'internal',
        'Could not generate response from AI platform. Please try again shortly.'
      );
    }

    const costUsd = calculateModelCost(modelName, inputTokens, outputTokens);

    // Atomic Daily Aggregate Rollup
    const dailyRef = db.collection('sathi_ai_usage_daily').doc(todayKey);
    await dailyRef.set(
      {
        date: todayKey,
        calls: FieldValue.increment(1),
        inputTokens: FieldValue.increment(inputTokens),
        outputTokens: FieldValue.increment(outputTokens),
        totalTokens: FieldValue.increment(inputTokens + outputTokens),
        costUsd: FieldValue.increment(costUsd),
        [`modelBreakdown.${modelName.replace(/\./g, '_')}`]: FieldValue.increment(1),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    return {
      text: aiReply,
      model: modelName,
      source: 'ai',
      tokens: inputTokens + outputTokens,
    };
  }
);
