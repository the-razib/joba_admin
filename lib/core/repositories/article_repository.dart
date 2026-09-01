import 'package:joba_admin/features/articles/models/article.dart';
import 'package:joba_admin/features/articles/models/article_category.dart';

abstract class ArticleRepository {
  Future<List<ArticleCategory>> fetchCategories();
  Future<List<Article>> fetchArticles();
  Future<List<String>> fetchTags();
  Future<Article?> fetchArticleById(String id);
  Future<void> saveArticle(Article article);
  Future<void> deleteArticle(String id);
  Future<void> saveCategory(ArticleCategory category);
  Future<void> deleteCategory(String id);
  Future<void> toggleCategory(String id, bool active);
  Future<void> reorderArticles(List<String> orderedIds);
  Future<void> addTag(String tag);
  Future<void> deleteTag(String tag);

  // Legacy/Mock methods for backward compatibility
  Future<List<ArticleCategory>> seedCategories();
  Future<List<Article>> seedArticles();
  Future<List<String>> seedTags();
  Future<void> createArticle(Article article);
  Future<void> updateArticle(Article article);
  Future<void> createCategory(ArticleCategory category);
  Future<void> updateCategory(ArticleCategory category);
}

class MockArticleRepository implements ArticleRepository {
  List<ArticleCategory>? _categories;
  List<Article>? _articles;
  List<String>? _tags;

  List<ArticleCategory> _initialCategories() => const [
        ArticleCategory(
          id: 'care',
          nameBn: 'যত্ন',
          nameEn: 'Care',
          subtitleBn: 'শারীরিক ও মানসিক',
          subtitleEn: 'Physical & mental',
          imagePath: 'assets/images/articles/article_care.jpg',
          isFullWidth: true,
          order: 0,
        ),
        ArticleCategory(
          id: 'period',
          nameBn: 'পিরিয়ড',
          nameEn: 'Period',
          subtitleBn: 'হাইজিন ও অন্যান্য',
          subtitleEn: 'Hygiene & more',
          imagePath: 'assets/images/articles/article_period.jpg',
          isFullWidth: false,
          order: 1,
        ),
        ArticleCategory(
          id: 'menopause',
          nameBn: 'মেনোপজ',
          nameEn: 'Menopause',
          subtitleBn: 'মেনোপজে করণীয়',
          subtitleEn: 'What to do during menopause',
          imagePath: 'assets/images/articles/article_menopause.jpg',
          isFullWidth: false,
          order: 2,
        ),
        ArticleCategory(
          id: 'discharge',
          nameBn: 'যোনিস্রাব',
          nameEn: 'Discharge',
          subtitleBn: 'ডিজিজ সম্পর্কিত',
          subtitleEn: 'Disease related',
          imagePath: 'assets/images/articles/article_discharge.jpg',
          isFullWidth: true,
          order: 3,
        ),
        ArticleCategory(
          id: 'myths',
          nameBn: 'ভুল ধারণা',
          nameEn: 'Myths',
          subtitleBn: 'যা বিশ্বাস করা উচিত নয়',
          subtitleEn: 'Things not to believe',
          imagePath: 'assets/images/articles/article_myths.jpg',
          isFullWidth: false,
          order: 4,
        ),
        ArticleCategory(
          id: 'needToKnow',
          nameBn: 'জানতে হবে',
          nameEn: 'Need to Know',
          subtitleBn: 'জরুরি স্বাস্থ্য তথ্য',
          subtitleEn: 'Physical & mental',
          imagePath: 'assets/images/articles/article_needtoknow.jpg',
          isFullWidth: false,
          order: 5,
        ),
      ];

  List<String> _initialTags() => [
        'selfcare',
        'mentalhealth',
        'wellness',
        'lifestyle',
        'period',
        'hygiene',
        'cramps',
        'womenshealth',
        'menopause',
        'perimenopause',
        'hormonehealth',
        'discharge',
        'infection',
        'myths',
        'facts',
        'education',
        'screening',
        'checkup',
        'prevention',
      ];

  List<Article> _initialArticles() {
    final now = DateTime.now();
    DateTime d(int days) => now.subtract(Duration(days: days));
    return [
      Article(
        id: 'art_care_001',
        categoryId: 'care',
        titleBn: 'মানসিক ও শারীরিক সুস্বাস্থ্যে দৈনন্দিন সেলফ-কেয়ার রুটিন',
        titleEn: 'Daily Self-Care Routine for Physical and Mental Wellness',
        subtitleBn:
            'ব্যস্ত জীবনে নিজের যত্ন নেওয়ার সহজ ও কার্যকরী বিজ্ঞানসম্মত উপায়সমূহ।',
        subtitleEn: 'Practical daily habits to nurture your mind and body.',
        contentBn:
            'দৈনন্দিন ব্যস্ততা এবং মানসিক চাপের মধ্যে নারীদের শারীরিক ও মানসিক স্বাস্থ্য রক্ষা করা অত্যন্ত জরুরি। একটি সঠিক সেলফ-কেয়ার রুটিন শুধু মন ভালো রাখে না, বরং হরমোনের ভারসাম্য রক্ষা করতেও সরাসরি সাহায্য করে।\n\n১. পর্যাপ্ত ঘুম ও বায়োলজিক্যাল ক্লক:\nপ্রতি রাতে ৭ থেকে ৮ ঘণ্টা নিরবচ্ছিন্ন ঘুম নিশ্চিত করুন।\n\n২. পর্যাপ্ত পানি ও সঠিক পুষ্টি:\nপ্রতিদিন কমপক্ষে ২.৫ থেকে ৩ লিটার বিশুদ্ধ পানি পান করুন।\n\n৩. শারীরিক ব্যায়াম ও মেডিটেশন:\nপ্রতিদিন ২০-৩০ মিনিট হালকা হাঁটা বা যোগব্যায়াম করুন।',
        contentEn:
            'Maintaining physical and mental well-being in the midst of daily hustle is essential for women. A consistent self-care routine not only boosts mood but also supports hormonal equilibrium.\n\n1. Restorative Sleep:\nPrioritize 7 to 8 hours of uninterrupted sleep each night.\n\n2. Optimal Hydration & Nutrition:\nDrink 2.5 to 3 liters of water daily.\n\n3. Mindful Movement:\nIncorporate 20-30 minutes of brisk walking or yoga.',
        imagePath: 'assets/images/articles/article_care.jpg',
        tags: const ['selfcare', 'mentalhealth', 'wellness', 'lifestyle'],
        status: ArticleStatus.published,
        featured: true,
        displayOrder: 0,
        views: 0,
        bookmarks: 0,
        readingTimeMin: 4,
        medicalReviewerBn: 'ডা. সাবরিনা রহমান (এমবিবিএস, এফসিপিএস)',
        medicalReviewerEn: 'Dr. Sabrina Rahman (MBBS, FCPS - Gynae & Obs)',
        isMedicallyReviewed: true,
        slug: 'daily-self-care-routine-for-physical-and-mental-wellness',
        seoTitle: 'Daily Self-Care Guide for Women',
        seoDescription: 'Practical science-backed habits for mental and physical wellness.',
        createdAt: d(30),
        updatedAt: d(1),
        version: 1,
      ),
      Article(
        id: 'art_period_001',
        categoryId: 'period',
        titleBn: 'পিরিয়ডের সময় সঠিক হাইজিন ও ব্যথা নিয়ন্ত্রণের বিজ্ঞানসম্মত উপায়',
        titleEn: 'Evidence-Based Period Hygiene & Cramp Relief Guide',
        subtitleBn:
            'ইনফেকশন প্রতিরোধে করণীয় ও আরামদায়ক মাসিকের ঘরোয়া ও নিরাপদ সমাধান।',
        subtitleEn: 'Protect against infections and relieve menstrual pain safely.',
        contentBn:
            'মাসিক প্রতিটি নারীর প্রজনন স্বাস্থ্যের স্বাভাবিক প্রক্রিয়া। তবে এই সময়ে পরিষ্কার-পরিচ্ছন্নতার অবহেলা গুরুতর ইনফেকশনের কারণ হতে পারে।\n\n১. প্যাড বা কাপ পরিবর্তনের সঠিক নিয়ম:\nস্যানিটারি প্যাড প্রতি ৪ থেকে ৬ ঘণ্টা পর পর পরিবর্তন করা আবশ্যক।\n\n২. সঠিক ধৌতকরণ পদ্ধতি:\nযোনিপথ সবসময় সামনে থেকে পেছনের দিকে পরিষ্কার জল দিয়ে ধোবেন।\n\n৩. মাসিকের তীব্র ব্যথা কমানোর নিরাপদ উপায়:\nপেটের নিচের অংশে গরম পানির সেঁক দিন।',
        contentEn:
            'Menstruation is a natural biological cycle. However, inadequate menstrual hygiene can predispose women to severe urinary tract and reproductive infections.\n\n1. Safe Changing Intervals:\nReplace sanitary pads every 4 to 6 hours.\n\n2. Cleansing Best Practices:\nAlways cleanse the perineal area from front to back.\n\n3. Relieving Dysmenorrhea:\nApply heat therapy to the lower abdomen.',
        imagePath: 'assets/images/articles/article_period.jpg',
        tags: const ['period', 'hygiene', 'cramps', 'womenshealth'],
        status: ArticleStatus.published,
        featured: true,
        displayOrder: 1,
        views: 0,
        bookmarks: 0,
        readingTimeMin: 5,
        medicalReviewerBn: 'ডা. নাজনীন আক্তার (স্ত্রীরোগ বিশেষজ্ঞ)',
        medicalReviewerEn: 'Dr. Nazneen Akter (Gynecology Specialist, MBBS, DGO)',
        isMedicallyReviewed: true,
        slug: 'evidence-based-period-hygiene-and-cramp-relief-guide',
        seoTitle: 'Period Hygiene and Pain Management Guide',
        seoDescription: 'Comprehensive guide to healthy menstruation and pain relief.',
        createdAt: d(25),
        updatedAt: d(2),
        version: 1,
      ),
      Article(
        id: 'art_menopause_001',
        categoryId: 'menopause',
        titleBn: 'পেরিমেনোপজ ও মেনোপজের লক্ষণ: শরীর ও মনের পরিপূর্ণ যত্ন',
        titleEn: 'Understanding Perimenopause and Menopause Symptoms',
        subtitleBn: 'হরমোন পরিবর্তনের এই স্বাভাবিক ধাপে সুস্থ ও প্রাণবন্ত থাকার উপায়।',
        subtitleEn: 'Managing hot flashes, mood shifts, and bone health effectively.',
        contentBn:
            'সাধারণত ৪৫ থেকে ৫৫ বছর বয়সে নারীদের প্রজনন ক্ষমতার স্বাভাবিক সমাপ্তি ঘটে, যাকে মেনোপজ বলা হয়।\n\n১. প্রধান লক্ষণসমূহ:\nহট ফ্ল্যাশ, অনিয়মিত মাসিক ও ঘুমের ব্যাঘাত।\n\n২. সুস্থ থাকার কার্যকরী পরামর্শ:\nক্যালসিয়াম ও ভিটামিন ডি৩ সমৃদ্ধ খাবার নিয়মিত গ্রহণ করুন।',
        contentEn:
            'Menopause marks the natural biological cessation of menstrual cycles, typically occurring between ages 45 and 55.\n\n1. Hallmark Symptoms:\nHot flashes, night sweats, and irregular cycles.\n\n2. Evidence-Based Management:\nEnsure adequate daily intake of Calcium and Vitamin D3.',
        imagePath: 'assets/images/articles/article_menopause.jpg',
        tags: const ['menopause', 'perimenopause', 'hormonehealth', 'wellness'],
        status: ArticleStatus.published,
        featured: false,
        displayOrder: 2,
        views: 0,
        bookmarks: 0,
        readingTimeMin: 6,
        medicalReviewerBn: 'অধ্যাপক ডা. রাবেয়া বেগম (এমবিবিএস, এফসিপিএস, এমএস)',
        medicalReviewerEn: 'Prof. Dr. Rabeya Begum (MBBS, FCPS, MS - Gynae)',
        isMedicallyReviewed: true,
        slug: 'understanding-perimenopause-and-menopause-symptoms',
        createdAt: d(20),
        updatedAt: d(5),
        version: 1,
      ),
      Article(
        id: 'art_discharge_001',
        categoryId: 'discharge',
        titleBn: 'যোনিস্রাব: স্বাভাবিক বনাম অস্বাভাবিক লক্ষণের পার্থক্য চিনুন',
        titleEn: 'Vaginal Discharge Guide: What Is Normal vs When to See a Doctor',
        subtitleBn: 'রং, ঘনত্ব ও গন্ধের পরিবর্তন এবং ইনফেকশনের প্রাথমিক সতর্কতা।',
        subtitleEn: 'Color, texture, and odor guide for women\'s reproductive health.',
        contentBn:
            'যোনিস্রাব নারী শরীরের একটি প্রাকৃতিক ও স্বাস্থ্যকর প্রক্রিয়া, যা যোনিপথকে পরিষ্কার রাখে।\n\n১. স্বাভাবিক যোনিস্রাব:\nবর্ণহীন, স্বচ্ছ বা দুধের মতো হালকা সাদা।\n\n২. অস্বাভাবিক লক্ষণ:\nঘন ছানার মতো সাদা স্রাব ও তীব্র চুলকানি (ইস্ট ইনফেকশন)। হলদেটে বা সবুজাভ স্রাব।',
        contentEn:
            'Vaginal discharge is a normal physiological mechanism that lubricates and cleanses the reproductive tract.\n\n1. Normal Discharge:\nClear or thin milky-white with mild odor.\n\n2. Warning Signs:\nThick curd-like discharge with itching (yeast infection), or yellow-greenish discharge.',
        imagePath: 'assets/images/articles/article_discharge.jpg',
        tags: const ['discharge', 'infection', 'womenshealth', 'hygiene'],
        status: ArticleStatus.published,
        featured: true,
        displayOrder: 3,
        views: 0,
        bookmarks: 0,
        readingTimeMin: 5,
        medicalReviewerBn: 'ডা. ফারহানা হক (এমবিবিএস, এফসিপিএস)',
        medicalReviewerEn: 'Dr. Farhana Huq (MBBS, FCPS - Obstetrics & Gynae)',
        isMedicallyReviewed: true,
        slug: 'vaginal-discharge-guide-normal-vs-infection',
        createdAt: d(15),
        updatedAt: d(3),
        version: 1,
      ),
      Article(
        id: 'art_myths_001',
        categoryId: 'myths',
        titleBn: 'নারী স্বাস্থ্য ও মাসিক নিয়ে বহুল প্রচলিত ৫টি ভুল ধারণা ও সত্যতা',
        titleEn: '5 Common Menstrual & Reproductive Health Myths Debunked',
        subtitleBn: 'কুসংস্কার এড়িয়ে বিজ্ঞানের আলোকে সঠিক চিকিৎসা তথ্য জেনে নিন।',
        subtitleEn: 'Replacing outdated misconceptions with clinical medical facts.',
        contentBn:
            'আমাদের সমাজে নারী স্বাস্থ্য এবং মাসিক নিয়ে অনেক ভুল ধারণা রয়েছে।\n\n১. ভুল ধারণা: মাসিকের সময় গোসল করা উচিত নয়। (সত্য: পরিষ্কার থাকা জরুরি)\n২. ভুল ধারণা: টক খেলে রক্ত জমাট বাঁধে। (সত্য: ভিটামিন সি রক্তস্বল্পতা প্রতিরোধে উপকারী)',
        contentEn:
            'Socio-cultural myths surrounding women\'s reproductive health often induce anxiety.\n\n1. Myth: Bathing during periods is harmful. (Fact: Warm showers relieve cramps)\n2. Myth: Citrus foods cause clotting. (Fact: Vitamin C improves iron absorption)',
        imagePath: 'assets/images/articles/article_myths.jpg',
        tags: const ['myths', 'facts', 'period', 'education'],
        status: ArticleStatus.published,
        featured: false,
        displayOrder: 4,
        views: 0,
        bookmarks: 0,
        readingTimeMin: 4,
        medicalReviewerBn: 'ডা. তনুশ্রী সরকার (মেডিকেল কনসালট্যান্ট)',
        medicalReviewerEn: 'Dr. Tanushree Sarker (Medical Consultant, MBBS, MPH)',
        isMedicallyReviewed: true,
        slug: 'common-menstrual-and-reproductive-health-myths-debunked',
        createdAt: d(10),
        updatedAt: d(1),
        version: 1,
      ),
      Article(
        id: 'art_needtoknow_001',
        categoryId: 'needToKnow',
        titleBn: 'প্রতিটি নারীর যেসব স্বাস্থ্য পরীক্ষা ও জরুরি তথ্য জেনে রাখা প্রয়োজন',
        titleEn: 'Essential Health Checkups and Screenings Every Woman Needs',
        subtitleBn: 'সুস্থ ও দীর্ঘ জীবনের জন্য রুটিন চেকআপ এবং রোগ প্রতিরোধের পূর্ণাঙ্গ নির্দেশিকা।',
        subtitleEn: 'Age-wise routine screenings, blood tests, and preventative care.',
        contentBn:
            'প্রতিরোধ প্রতিকারের চেয়ে উত্তম। সময়মতো সঠিক স্ক্রিনিং জটিল রোগ প্রতিরোধ করে।\n\n১. রক্ত পরীক্ষা: সিবিসি, থাইরয়েড (TSH) ও সুগার টেস্ট।\n২. ক্যানসার স্ক্রিনিং: প্যাপ স্মিয়ার ও ব্রেস্ট সেলফ-এক্সামিনেশন।\n৩. ভ্যাকসিনেশন: এইচপিভি ও রুবেলা টিকা।',
        contentEn:
            'Preventative screening saves lives through early clinical detection.\n\n1. Annual Blood Panels: CBC, Thyroid, and Glucose tests.\n2. Gynecological Screenings: Pap Smear and Breast Self-Exams.\n3. Vaccinations: HPV and Rubella vaccines.',
        imagePath: 'assets/images/articles/article_needtoknow.jpg',
        tags: const ['screening', 'checkup', 'prevention', 'womenshealth'],
        status: ArticleStatus.published,
        featured: true,
        displayOrder: 5,
        views: 0,
        bookmarks: 0,
        readingTimeMin: 5,
        medicalReviewerBn: 'ডা. সানজিদা ইসলাম (এমবিবিএস, এফসিপিএস, এমডি)',
        medicalReviewerEn: 'Dr. Sanjida Islam (MBBS, FCPS, MD - Internal Medicine)',
        isMedicallyReviewed: true,
        slug: 'essential-health-checkups-and-screenings-every-woman-needs',
        createdAt: d(5),
        updatedAt: d(1),
        version: 1,
      ),
    ];
  }

  @override
  Future<List<ArticleCategory>> fetchCategories() async {
    _categories ??= List<ArticleCategory>.from(_initialCategories());
    return List.unmodifiable(_categories!);
  }

  @override
  Future<List<Article>> fetchArticles() async {
    _articles ??= List<Article>.from(_initialArticles());
    return List.unmodifiable(_articles!);
  }

  @override
  Future<List<String>> fetchTags() async {
    _tags ??= List<String>.from(_initialTags());
    return List.unmodifiable(_tags!);
  }

  @override
  Future<Article?> fetchArticleById(String id) async {
    final list = await fetchArticles();
    return list.where((a) => a.id == id).firstOrNull;
  }

  @override
  Future<void> saveArticle(Article article) async {
    _articles ??= List<Article>.from(_initialArticles());
    final idx = _articles!.indexWhere((a) => a.id == article.id);
    if (idx != -1) {
      _articles![idx] = article;
    } else {
      _articles!.add(article);
    }
  }

  @override
  Future<void> deleteArticle(String id) async {
    _articles ??= List<Article>.from(_initialArticles());
    _articles!.removeWhere((a) => a.id == id);
  }

  @override
  Future<void> saveCategory(ArticleCategory category) async {
    _categories ??= List<ArticleCategory>.from(_initialCategories());
    final idx = _categories!.indexWhere((c) => c.id == category.id);
    if (idx != -1) {
      _categories![idx] = category;
    } else {
      _categories!.add(category);
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    _categories ??= List<ArticleCategory>.from(_initialCategories());
    _categories!.removeWhere((c) => c.id == id);
  }

  @override
  Future<void> toggleCategory(String id, bool active) async {
    _categories ??= List<ArticleCategory>.from(_initialCategories());
    final idx = _categories!.indexWhere((c) => c.id == id);
    if (idx != -1) {
      _categories![idx] = _categories![idx].copyWith(active: active);
    }
  }

  @override
  Future<void> reorderArticles(List<String> orderedIds) async {
    _articles ??= List<Article>.from(_initialArticles());
    for (var i = 0; i < orderedIds.length; i++) {
      final idx = _articles!.indexWhere((a) => a.id == orderedIds[i]);
      if (idx != -1) {
        _articles![idx] = _articles![idx].copyWith(displayOrder: i);
      }
    }
    _articles!.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
  }

  @override
  Future<void> addTag(String tag) async {
    _tags ??= List<String>.from(_initialTags());
    final clean = tag.trim().toLowerCase();
    if (clean.isNotEmpty && !_tags!.contains(clean)) {
      _tags!.add(clean);
    }
  }

  @override
  Future<void> deleteTag(String tag) async {
    _tags ??= List<String>.from(_initialTags());
    _tags!.remove(tag.trim().toLowerCase());
  }

  @override
  Future<List<ArticleCategory>> seedCategories() => fetchCategories();

  @override
  Future<List<Article>> seedArticles() => fetchArticles();

  @override
  Future<List<String>> seedTags() => fetchTags();

  @override
  Future<void> createArticle(Article article) => saveArticle(article);

  @override
  Future<void> updateArticle(Article article) => saveArticle(article);

  @override
  Future<void> createCategory(ArticleCategory category) => saveCategory(category);

  @override
  Future<void> updateCategory(ArticleCategory category) => saveCategory(category);
}
