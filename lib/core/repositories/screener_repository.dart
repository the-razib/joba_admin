import 'package:joba_admin/core/models/screener_admin_model.dart';

abstract class ScreenerRepository {
  Future<List<ScreenerAdminModel>> getScreeners();
  Future<ScreenerAdminModel?> getScreenerById(String id);
  Future<ScreenerAdminModel> createScreener(ScreenerAdminModel screener);
  Future<ScreenerAdminModel> updateScreener(ScreenerAdminModel screener);
  Future<bool> deleteScreener(String id);
  Future<bool> toggleScreenerActive(String id, bool enabled);
}

class MockScreenerRepository implements ScreenerRepository {
  final List<ScreenerAdminModel> _screeners = [
    // 1. PCOS Screener
    ScreenerAdminModel(
      id: 'pcos',
      nameBn: 'PCOS স্ক্রিনার',
      nameEn: 'PCOS Screener',
      subtitleBn: 'অনিয়মিত পিরিয়ড বা হরমোনজনিত লক্ষণ যাচাই করুন',
      subtitleEn:
          'Screen for irregular periods and hormonal imbalance symptoms',
      source: 'Rotterdam Criteria',
      imagePath: '',
      accentColorHex: '#E65671',
      displayOrder: 1,
      enabled: true,
      totalCompletions: 1420,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      questions: const [
        ScreenerQuestionAdmin(
          id: 'pcos_1',
          questionBn:
              'মাসিক চক্র অনিয়মিত (৩৫ দিনের বেশি ব্যবধান বা মাঝে মাঝে মিস হওয়া)',
          questionEn:
              'Irregular menstrual cycle (intervals > 35 days or missed periods)',
          points: 1,
          order: 1,
          isActive: true,
        ),
        ScreenerQuestionAdmin(
          id: 'pcos_2',
          questionBn: 'মুখে বা শরীরে অতিরিক্ত লোমের বৃদ্ধি',
          questionEn: 'Excessive facial or body hair growth (Hirsutism)',
          points: 1,
          order: 2,
          isActive: true,
        ),
        ScreenerQuestionAdmin(
          id: 'pcos_3',
          questionBn: 'ঘন ঘন ব্রণ বা অতিরিক্ত তৈলাক্ত ত্বক',
          questionEn: 'Persistent acne outbreaks or severely oily skin',
          points: 1,
          order: 3,
          isActive: true,
        ),
        ScreenerQuestionAdmin(
          id: 'pcos_4',
          questionBn: 'ওজন বৃদ্ধি বা কমাতে অস্বাভাবিক কষ্ট হওয়া',
          questionEn:
              'Unexplained weight gain or extreme difficulty losing weight',
          points: 1,
          order: 4,
          isActive: true,
        ),
        ScreenerQuestionAdmin(
          id: 'pcos_5',
          questionBn: 'মাথার চুল পাতলা হয়ে যাওয়া',
          questionEn: 'Thinning hair or male-pattern hair loss on scalp',
          points: 1,
          order: 5,
          isActive: true,
        ),
        ScreenerQuestionAdmin(
          id: 'pcos_6',
          questionBn: 'পরিবারে PCOS বা ডায়াবেটিসের ইতিহাস আছে',
          questionEn:
              'Family history of PCOS, Type-2 Diabetes, or insulin resistance',
          points: 1,
          order: 6,
          isActive: true,
        ),
      ],
      riskTiers: const [
        RiskTierAdminConfig(
          key: RiskTierKey.low,
          labelBn: 'স্বাভাবিক পরিসীমা',
          labelEn: 'Low Risk / Normal Range',
          descriptionBn:
              'আপনার নির্বাচিত উত্তরগুলোতে উল্লেখযোগ্য কোনো ঝুঁকির লক্ষণ পাওয়া যায়নি। নিয়মিত ট্র্যাকিং চালিয়ে যান।',
          descriptionEn:
              'No significant risk indicators found. Continue regular cycle tracking.',
          colorHex: '#5FA873',
          minRatio: 0.0,
          maxRatio: 0.33,
        ),
        RiskTierAdminConfig(
          key: RiskTierKey.moderate,
          labelBn: 'মাঝারি ইঙ্গিত',
          labelEn: 'Moderate Indication',
          descriptionBn:
              'কিছু লক্ষণ মিলেছে। জীবনযাত্রায় পরিবর্তন ও পর্যাপ্ত পুষ্টি গ্রহণ করুন এবং প্রয়োজনে ডাক্তারের পরামর্শ নিন।',
          descriptionEn:
              'Some symptoms matched. Consider lifestyle adaptations and clinical consultation.',
          colorHex: '#FFC96B',
          minRatio: 0.34,
          maxRatio: 0.66,
        ),
        RiskTierAdminConfig(
          key: RiskTierKey.high,
          labelBn: 'লক্ষণীয় ইঙ্গিত',
          labelEn: 'High Indication',
          descriptionBn:
              'বেশ কয়েকটি গুরুত্বপূর্ণ লক্ষণ মিলেছে। সঠিক মূল্যায়নের জন্য একজন স্ত্রীরোগ বিশেষজ্ঞের পরামর্শ নেওয়া উচিত।',
          descriptionEn:
              'Multiple key indicators matched. A formal evaluation with a gynecologist is strongly advised.',
          colorHex: '#FF7B88',
          minRatio: 0.67,
          maxRatio: 1.0,
        ),
      ],
    ),

    // 2. Endometriosis Screener
    ScreenerAdminModel(
      id: 'endo',
      nameBn: 'এন্ডোমেট্রিওসিস স্ক্রিনার',
      nameEn: 'Endometriosis Screener',
      subtitleBn: 'তীব্র পিরিয়ড ব্যথা ও পেলভিক অস্বস্তি যাচাই করুন',
      subtitleEn: 'Screen for severe menstrual pain and pelvic discomfort',
      source: 'ESHRE Guidelines',
      imagePath: '',
      accentColorHex: '#E65671',
      displayOrder: 2,
      enabled: true,
      totalCompletions: 980,
      createdAt: DateTime.now().subtract(const Duration(days: 85)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      questions: const [
        ScreenerQuestionAdmin(
          id: 'endo_1',
          questionBn:
              'পিরিয়ডের সময় অতিরিক্ত তীব্র তলপেটে ব্যথা যা ওষুধেও কমে না',
          questionEn:
              'Severe debilitating pelvic pain during period that does not respond to regular painkillers',
          points: 1,
          order: 1,
          isActive: true,
        ),
        ScreenerQuestionAdmin(
          id: 'endo_2',
          questionBn: 'পিরিয়ড চলাকালীন মলত্যাগ বা প্রস্রাবে ব্যথা',
          questionEn:
              'Painful bowel movements or painful urination during menstruation',
          points: 1,
          order: 2,
          isActive: true,
        ),
        ScreenerQuestionAdmin(
          id: 'endo_3',
          questionBn: 'দৈনন্দিন কাজকর্মে বাধা দেয় এমন ক্রনিক পেলভিক ব্যথা',
          questionEn:
              'Chronic pelvic pain outside of period cycle that limits daily activities',
          points: 1,
          order: 3,
          isActive: true,
        ),
        ScreenerQuestionAdmin(
          id: 'endo_4',
          questionBn: 'পিরিয়ডের পূর্বে বা পরে অস্বাভাবিক স্পটিং/ব্লিডিং',
          questionEn: 'Abnormal spotting or bleeding between menstrual cycles',
          points: 1,
          order: 4,
          isActive: true,
        ),
        ScreenerQuestionAdmin(
          id: 'endo_5',
          questionBn: 'পিরিয়ডের সময় তীব্র ক্লান্তি, বমি বমি ভাব বা ডায়রিয়া',
          questionEn:
              'Severe fatigue, nausea, diarrhea, or digestive distress during period',
          points: 1,
          order: 5,
          isActive: true,
        ),
        ScreenerQuestionAdmin(
          id: 'endo_6',
          questionBn: 'গর্ভধারণে দীর্ঘমেয়াদী সমস্যা বা বিলম্ব',
          questionEn: 'Difficulty conceiving or past history of infertility',
          points: 1,
          order: 6,
          isActive: true,
        ),
      ],
      riskTiers: const [
        RiskTierAdminConfig(
          key: RiskTierKey.low,
          labelBn: 'স্বাভাবিক পরিসীমা',
          labelEn: 'Low Risk / Normal Range',
          descriptionBn:
              'আপনার নির্বাচিত উত্তরগুলোতে উল্লেখযোগ্য কোনো ঝুঁকির লক্ষণ পাওয়া যায়নি। নিয়মিত ট্র্যাকিং চালিয়ে যান।',
          descriptionEn:
              'No significant risk indicators found. Continue regular cycle tracking.',
          colorHex: '#5FA873',
          minRatio: 0.0,
          maxRatio: 0.33,
        ),
        RiskTierAdminConfig(
          key: RiskTierKey.moderate,
          labelBn: 'মাঝারি ইঙ্গিত',
          labelEn: 'Moderate Indication',
          descriptionBn:
              'কিছু লক্ষণ মিলেছে। উপসর্গগুলো ট্র্যাক করুন এবং ডাক্তার সামারি শেয়ার করে পরামর্শ নিন।',
          descriptionEn:
              'Some symptoms matched. Track symptom timeline and consult a doctor.',
          colorHex: '#FFC96B',
          minRatio: 0.34,
          maxRatio: 0.66,
        ),
        RiskTierAdminConfig(
          key: RiskTierKey.high,
          labelBn: 'লক্ষণীয় ইঙ্গিত',
          labelEn: 'High Indication',
          descriptionBn:
              'এন্ডোমেট্রিওসিসের একাধিক লক্ষণ মিলেছে। ব্যথা অবহেলা না করে দ্রুত বিশেষজ্ঞের শরণাপন্ন হোন।',
          descriptionEn:
              'Multiple key indicators matched. Early clinical diagnosis is strongly recommended.',
          colorHex: '#FF7B88',
          minRatio: 0.67,
          maxRatio: 1.0,
        ),
      ],
    ),

    // 3. PMDD Screener
    ScreenerAdminModel(
      id: 'pmdd',
      nameBn: 'PMDD স্ক্রিনার',
      nameEn: 'PMDD Screener',
      subtitleBn: 'পিরিয়ডের পূর্বে তীব্র মানসিক ও শারীরিক পরিবর্তন',
      subtitleEn:
          'Screen for severe premenstrual emotional and physical changes',
      source: 'DSM-5 Criteria',
      imagePath: '',
      accentColorHex: '#E65671',
      displayOrder: 3,
      enabled: true,
      totalCompletions: 740,
      createdAt: DateTime.now().subtract(const Duration(days: 70)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      questions: const [
        ScreenerQuestionAdmin(
          id: 'pmdd_1',
          questionBn:
              'পিরিয়ডের ১-২ সপ্তাহ আগে তীব্র মেজাজ খিটখিটে বা হঠাৎ রাগ হওয়া',
          questionEn:
              'Marked irritability, anger, or increased interpersonal conflicts 1-2 weeks before period',
          points: 1,
          order: 1,
          isActive: true,
        ),
        ScreenerQuestionAdmin(
          id: 'pmdd_2',
          questionBn: 'গভীর বিষণ্ণতা, হতাশা বা নিজেকে মূল্যহীন মনে হওয়া',
          questionEn:
              'Marked depressed mood, feelings of hopelessness, or self-deprecating thoughts',
          points: 1,
          order: 2,
          isActive: true,
        ),
        ScreenerQuestionAdmin(
          id: 'pmdd_3',
          questionBn: 'অতিরিক্ত উদ্বেগ, মানসিক চাপ বা অস্থিরতা',
          questionEn:
              'Marked anxiety, tension, and feelings of being keyed up or on edge',
          points: 1,
          order: 3,
          isActive: true,
        ),
        ScreenerQuestionAdmin(
          id: 'pmdd_4',
          questionBn: 'দৈনন্দিন কাজে আগ্রহ কমে যাওয়া বা মনোযোগে সমস্যা',
          questionEn:
              'Decreased interest in usual activities and difficulty concentrating',
          points: 1,
          order: 4,
          isActive: true,
        ),
        ScreenerQuestionAdmin(
          id: 'pmdd_5',
          questionBn:
              'তীব্র ক্লান্তি, শক্তির ঘাটতি বা ঘুমের সমস্যা (অনিদ্রা/অতিরিক্ত ঘুম)',
          questionEn:
              'Lethargy, marked lack of energy, insomnia, or hypersomnia',
          points: 1,
          order: 5,
          isActive: true,
        ),
        ScreenerQuestionAdmin(
          id: 'pmdd_6',
          questionBn:
              'পিরিয়ড শুরু হওয়ার কয়েকদিনের মধ্যে এই লক্ষণগুলো সম্পূর্ণ চলে যায়',
          questionEn:
              'Symptoms remit completely within a few days after onset of menstruation',
          points: 1,
          order: 6,
          isActive: true,
        ),
      ],
      riskTiers: const [
        RiskTierAdminConfig(
          key: RiskTierKey.low,
          labelBn: 'স্বাভাবিক পরিসীমা',
          labelEn: 'Low Risk / Normal Range',
          descriptionBn:
              'আপনার নির্বাচিত উত্তরগুলোতে উল্লেখযোগ্য কোনো ঝুঁকির লক্ষণ পাওয়া যায়নি। নিয়মিত ট্র্যাকিং চালিয়ে যান।',
          descriptionEn:
              'No significant risk indicators found. Continue regular cycle tracking.',
          colorHex: '#5FA873',
          minRatio: 0.0,
          maxRatio: 0.33,
        ),
        RiskTierAdminConfig(
          key: RiskTierKey.moderate,
          labelBn: 'মাঝারি ইঙ্গিত',
          labelEn: 'Moderate Indication',
          descriptionBn:
              'PMS-এর লক্ষণ মিলেছে। পর্যাপ্ত ঘুম, মেডিটেশন ও সুষম খাদ্য মেজাজ নিয়ন্ত্রণে সহায়তা করতে পারে।',
          descriptionEn:
              'Pre-menstrual symptoms noted. Prioritize rest, mindfulness, and balanced nutrition.',
          colorHex: '#FFC96B',
          minRatio: 0.34,
          maxRatio: 0.66,
        ),
        RiskTierAdminConfig(
          key: RiskTierKey.high,
          labelBn: 'লক্ষণীয় ইঙ্গিত',
          labelEn: 'High Indication',
          descriptionBn:
              'PMDD-এর একাধিক লক্ষণ মিলেছে। মানসিক স্বাস্থ্যের যত্ন ও সঠিক থেরাপির জন্য বিশেষজ্ঞের পরামর্শ নিন।',
          descriptionEn:
              'High clinical correlation with PMDD criteria. Professional evaluation is recommended.',
          colorHex: '#FF7B88',
          minRatio: 0.67,
          maxRatio: 1.0,
        ),
      ],
    ),

    // 4. Heavy Bleeding Screener
    ScreenerAdminModel(
      id: 'heavy',
      nameBn: 'হেভি ব্লিডিং স্ক্রিনার',
      nameEn: 'Heavy Bleeding Screener',
      subtitleBn: 'অতিরিক্ত রক্তক্ষরণ ও রক্তশূন্যতার ঝুঁকি যাচাই করুন',
      subtitleEn: 'Screen for menorrhagia and iron-deficiency anemia risk',
      source: 'NICE Guidelines',
      imagePath: '',
      accentColorHex: '#E65671',
      displayOrder: 4,
      enabled: true,
      totalCompletions: 1120,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      questions: const [
        ScreenerQuestionAdmin(
          id: 'heavy_1',
          questionBn: 'প্রতি ১-২ ঘণ্টায় প্যাড/ট্যাম্পন পরিবর্তন করতে হয়',
          questionEn:
              'Needing to change sanitary pad or tampon every 1-2 hours for consecutive hours',
          points: 1,
          order: 1,
          isActive: true,
        ),
        ScreenerQuestionAdmin(
          id: 'heavy_2',
          questionBn: 'ব্লিডিং ৭ দিনের বেশি স্থায়ী হয়',
          questionEn:
              'Menstrual bleeding lasting continuously for more than 7 days',
          points: 1,
          order: 2,
          isActive: true,
        ),
        ScreenerQuestionAdmin(
          id: 'heavy_3',
          questionBn: 'ব্লিডিং ৭ দিনের বেশি স্থায়ী হয়',
          questionEn: 'Passing large blood clots (larger than a standard coin)',
          points: 1,
          order: 3,
          isActive: true,
        ),
        ScreenerQuestionAdmin(
          id: 'heavy_4',
          questionBn:
              'রাতে প্যাড লিক হওয়া বা প্যাড পরিবর্তনের জন্য ঘুম ভেঙে যাওয়া',
          questionEn:
              'Waking up at night to change protection or frequent night-time flooding',
          points: 1,
          order: 4,
          isActive: true,
        ),
        ScreenerQuestionAdmin(
          id: 'heavy_5',
          questionBn:
              'পিরিয়ডের সময় মাথা ঘোরা, দুর্বলতা বা শ্বাসকষ্ট অনুভব হওয়া',
          questionEn:
              'Feeling dizzy, unusually fatigued, or short of breath during period (Anemia signs)',
          points: 1,
          order: 5,
          isActive: true,
        ),
      ],
      riskTiers: const [
        RiskTierAdminConfig(
          key: RiskTierKey.low,
          labelBn: 'স্বাভাবিক পরিসীমা',
          labelEn: 'Low Risk / Normal Range',
          descriptionBn:
              'আপনার নির্বাচিত উত্তরগুলোতে উল্লেখযোগ্য কোনো ঝুঁকির লক্ষণ পাওয়া যায়নি। নিয়মিত ট্র্যাকিং চালিয়ে যান।',
          descriptionEn:
              'No significant risk indicators found. Continue regular cycle tracking.',
          colorHex: '#5FA873',
          minRatio: 0.0,
          maxRatio: 0.33,
        ),
        RiskTierAdminConfig(
          key: RiskTierKey.moderate,
          labelBn: 'মাঝারি ইঙ্গিত',
          labelEn: 'Moderate Indication',
          descriptionBn:
              'রক্তক্ষরণ স্বাভাবিকের চেয়ে কিছুটা বেশি। আয়রন সমৃদ্ধ খাবার গ্রহণ করুন এবং প্যাড ব্যবহারের সংখ্যা ট্র্যাক করুন।',
          descriptionEn:
              'Flow is moderately heavy. Increase dietary iron and monitor protection counts.',
          colorHex: '#FFC96B',
          minRatio: 0.34,
          maxRatio: 0.66,
        ),
        RiskTierAdminConfig(
          key: RiskTierKey.high,
          labelBn: 'লক্ষণীয় ইঙ্গিত',
          labelEn: 'High Indication',
          descriptionBn:
              'অতিরিক্ত রক্তক্ষরণ ও অ্যানিমিয়ার উচ্চ ঝুঁকি রয়েছে। অবহেলা না করে দ্রুত ডাক্তারের পরামর্শ নিন।',
          descriptionEn:
              'High risk of menorrhagia and anemia. Prompt clinical consultation is advised.',
          colorHex: '#FF7B88',
          minRatio: 0.67,
          maxRatio: 1.0,
        ),
      ],
    ),
  ];

  @override
  Future<List<ScreenerAdminModel>> getScreeners() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.from(_screeners);
  }

  @override
  Future<ScreenerAdminModel?> getScreenerById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _screeners.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ScreenerAdminModel> createScreener(ScreenerAdminModel screener) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _screeners.add(screener);
    return screener;
  }

  @override
  Future<ScreenerAdminModel> updateScreener(ScreenerAdminModel screener) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _screeners.indexWhere((s) => s.id == screener.id);
    if (index != -1) {
      _screeners[index] = screener.copyWith(updatedAt: DateTime.now());
      return _screeners[index];
    }
    _screeners.add(screener);
    return screener;
  }

  @override
  Future<bool> deleteScreener(String id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final before = _screeners.length;
    _screeners.removeWhere((s) => s.id == id);
    return _screeners.length < before;
  }

  @override
  Future<bool> toggleScreenerActive(String id, bool enabled) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _screeners.indexWhere((s) => s.id == id);
    if (index != -1) {
      _screeners[index] = _screeners[index].copyWith(
        enabled: enabled,
        updatedAt: DateTime.now(),
      );
      return true;
    }
    return false;
  }
}
