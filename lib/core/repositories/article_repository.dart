import 'package:joba_admin/features/articles/models/article.dart';
import 'package:joba_admin/features/articles/models/article_category.dart';

/// Phase 1: mock seed. Phase 3: `FirebaseArticleRepository` reads/writes
/// `articles` + `article_categories` (same schema as the Joba app).
abstract class ArticleRepository {
  Future<List<ArticleCategory>> seedCategories();
  Future<List<Article>> seedArticles();
  Future<List<String>> seedTags();
  Future<void> createArticle(Article article);
  Future<void> updateArticle(Article article);
  Future<void> deleteArticle(String id);
  Future<void> createCategory(ArticleCategory category);
  Future<void> updateCategory(ArticleCategory category);
  Future<void> deleteCategory(String id);
}

class MockArticleRepository implements ArticleRepository {
  @override
  Future<List<ArticleCategory>> seedCategories() async => const [
        ArticleCategory(
          id: 'care',
          nameBn: 'যত্ন',
          nameEn: 'Self-Care',
          subtitleBn: 'শারীরিক ও মানসিক',
          subtitleEn: 'Physical & Mental',
          imagePath: 'assets/images/articles/article_care.jpg',
          isFullWidth: true,
          order: 0,
        ),
        ArticleCategory(
          id: 'period',
          nameBn: 'পিরিয়ড',
          nameEn: 'Period',
          subtitleBn: 'হাইজিন ও অন্যান্য',
          subtitleEn: 'Hygiene & More',
          imagePath: 'assets/images/articles/article_period.jpg',
          isFullWidth: false,
          order: 1,
        ),
        ArticleCategory(
          id: 'menopause',
          nameBn: 'মেনোপজ',
          nameEn: 'Menopause',
          subtitleBn: 'মেনোপজে করণীয়',
          subtitleEn: 'Menopause Care',
          imagePath: 'assets/images/articles/article_menopause.jpg',
          isFullWidth: false,
          order: 2,
        ),
        ArticleCategory(
          id: 'discharge',
          nameBn: 'মুক্তি',
          nameEn: 'Discharge',
          subtitleBn: 'ডিজিজ সম্পর্কিত',
          subtitleEn: 'Disease Related',
          imagePath: 'assets/images/articles/article_care.jpg',
          isFullWidth: true,
          order: 3,
        ),
        ArticleCategory(
          id: 'myths',
          nameBn: 'ভুল ধারণা',
          nameEn: 'Myths',
          subtitleBn: 'সঠিক তথ্য জানুন',
          subtitleEn: 'Facts & Truths',
          imagePath: 'assets/images/articles/article_period.jpg',
          isFullWidth: false,
          order: 4,
        ),
        ArticleCategory(
          id: 'needToKnow',
          nameBn: 'জানতে হবে',
          nameEn: 'Need to Know',
          subtitleBn: 'জরুরি স্বাস্থ্য তথ্য',
          subtitleEn: 'Essential Health Info',
          imagePath: 'assets/images/articles/article_menopause.jpg',
          isFullWidth: false,
          order: 5,
        ),
      ];

  @override
  Future<List<String>> seedTags() async => const [
        'pain',
        'cramps',
        'relief',
        'natural',
        'hygiene',
        'nutrition',
        'cycle',
        'pms',
        'hormone',
        'fitness',
      ];

  @override
  Future<List<Article>> seedArticles() async {
    final now = DateTime.now();
    DateTime d(int days) => now.subtract(Duration(days: days));
    return [
      Article(
        id: 'art-001',
        categoryId: 'period',
        titleBn: 'পিরিয়ডের সময় ব্যথা কমানোর উপায়',
        titleEn: 'How to Manage Period Pain Naturally',
        subtitleBn:
            'মাসিকের সময় প্রাকৃতিক উপায়ে ব্যথা কমানোর সহজ ও কার্যকরী উপায়গুলো জেনে নিন।',
        subtitleEn:
            'Simple and effective natural ways to reduce menstrual pain.',
        contentBn:
            'মাসিকের সময় হালকা থেকে তীব্র ব্যথা হওয়া খুবই সাধারণ একটি বিষয়। তবে কিছু প্রাকৃতিক উপায়ে এই ব্যথা অনেকটাই কমানো সম্ভব।\n\nগরম পানির সেঁক, হালকা ব্যায়াম এবং পর্যাপ্ত পানি পান করলে ব্যথা উল্লেখযোগ্যভাবে কমে। এছাড়া আদা ও মৌরি চা উপকারী।\n\nব্যথা খুব তীব্র হলে বা দীর্ঘদিন থাকলে অবশ্যই চিকিৎসকের পরামর্শ নিন।',
        contentEn:
            'Mild to severe cramps during a period are very common. Several natural approaches can reduce the pain considerably.\n\nA warm compress, light exercise and staying hydrated all help. Ginger or fennel tea can also be beneficial.\n\nIf the pain is severe or persistent, always consult a doctor.',
        imagePath: 'assets/images/articles/article_period.jpg',
        tags: const ['pain', 'cramps', 'relief', 'natural'],
        status: ArticleStatus.published,
        featured: true,
        displayOrder: 0,
        views: 12400,
        likes: 1200,
        commentsCount: 86,
        shares: 532,
        readingTimeMin: 3,
        medicalReviewerBn: 'ডাঃ সাবরিনা সুলতানা',
        medicalReviewerEn: 'Dr. Sabrina Sultana',
        isMedicallyReviewed: true,
        slug: 'how-to-manage-period-pain-naturally',
        seoTitle: 'Period Pain Relief: Natural Ways That Work',
        seoDescription:
            'Discover natural, doctor-reviewed ways to reduce menstrual cramps and feel better during your period.',
        createdAt: d(85),
        updatedAt: d(3),
        version: 4,
      ),
      Article(
        id: 'art-002',
        categoryId: 'care',
        titleBn: 'চুলের যত্নে ঘরোয়া সমাধান খুব সহজেই জেনে নিন',
        titleEn: 'Natural Home Remedies for Healthy Hair',
        subtitleBn: 'ঘরোয়া উপাদান দিয়ে স্বাস্থ্যোজ্জ্বল চুলের সহজ যত্ন।',
        subtitleEn: 'Simple hair care with natural household ingredients.',
        contentBn:
            'স্বাস্থ্যোজ্জ্বল চুল পেতে নিয়মিত সঠিক যত্ন প্রয়োজন। নারিকেল তেল, পেঁয়াজের রস ও অ্যালোভেরা জেল চুলের গোড়া মজবুত করে।\n\nপর্যাপ্ত পুষ্টি ও পানি গ্রহণ চুলের স্বাস্থ্যের জন্য অপরিহার্য।',
        contentEn:
            'Healthy hair requires regular, gentle care. Coconut oil, onion juice, and aloe vera strengthen roots naturally.\n\nAdequate nutrition and hydration are essential for hair wellness.',
        imagePath: 'assets/images/articles/article_care.jpg',
        tags: const ['natural', 'hygiene'],
        status: ArticleStatus.published,
        displayOrder: 1,
        views: 9800,
        likes: 932,
        commentsCount: 63,
        shares: 310,
        readingTimeMin: 4,
        medicalReviewerBn: 'ডাঃ সাবরিনা সুলতানা',
        medicalReviewerEn: 'Dr. Sabrina Sultana',
        isMedicallyReviewed: true,
        slug: 'natural-home-remedies-for-healthy-hair',
        createdAt: d(80),
        updatedAt: d(10),
        version: 2,
      ),
      Article(
        id: 'art-003',
        categoryId: 'menopause',
        titleBn: 'মেনোপজের প্রাথমিক লক্ষণসমূহ ও করণীয়',
        titleEn: 'Early Signs of Menopause & Guidance',
        subtitleBn: 'পেরিমেনোপজের লক্ষণ চিনে প্রস্তুত থাকুন।',
        subtitleEn: 'Recognise perimenopause signs and stay prepared.',
        contentBn:
            'গরম লাগা, ঘুমের সমস্যা ও মেজাজের পরিবর্তন মেনোপজের প্রাথমিক লক্ষণ হতে পারে। ক্যালসিয়াম ও ভিটামিন ডি যুক্ত খাবার নিয়মিত গ্রহণ করুন।',
        contentEn:
            'Hot flashes, sleep issues, and mood shifts can be early signs. Include calcium and vitamin D rich foods in your diet.',
        imagePath: 'assets/images/articles/article_menopause.jpg',
        tags: const ['hormone'],
        status: ArticleStatus.published,
        displayOrder: 2,
        views: 8600,
        likes: 745,
        commentsCount: 52,
        shares: 268,
        readingTimeMin: 4,
        medicalReviewerBn: 'ডাঃ সাবরিনা সুলতানা',
        medicalReviewerEn: 'Dr. Sabrina Sultana',
        isMedicallyReviewed: true,
        slug: 'early-signs-of-menopause',
        createdAt: d(78),
        updatedAt: d(12),
        version: 1,
      ),
      Article(
        id: 'art-004',
        categoryId: 'care',
        titleBn: 'পিরিয়ড হাইজিন মেনে চলার সঠিক নিয়ম',
        titleEn: 'Period Hygiene Best Practices',
        subtitleBn: 'সুস্থ থাকার জন্য সঠিক হাইজিন চর্চা অপরিহার্য।',
        subtitleEn: 'Proper hygiene practices are essential for staying healthy.',
        contentBn:
            'প্যাড বা কাপ ব্যবহারের সময় পরিচ্ছন্নতা সবচেয়ে গুরুত্বপূর্ণ। ৪-৬ ঘণ্টা অন্তর প্যাড বদলান এবং হাত ধুয়ে নিন।',
        contentEn:
            'Cleanliness matters most when using pads or cups. Change pads every 4-6 hours and wash your hands well.',
        imagePath: 'assets/images/articles/article_care.jpg',
        tags: const ['hygiene'],
        status: ArticleStatus.published,
        displayOrder: 0,
        views: 8600,
        likes: 745,
        commentsCount: 47,
        shares: 220,
        readingTimeMin: 3,
        medicalReviewerBn: 'ডাঃ সাবরিনা সুলতানা',
        medicalReviewerEn: 'Dr. Sabrina Sultana',
        isMedicallyReviewed: true,
        slug: 'period-hygiene-best-practices',
        createdAt: d(75),
        updatedAt: d(15),
        version: 2,
      ),
      Article(
        id: 'art-005',
        categoryId: 'period',
        titleBn: 'অতিরিক্ত রক্তপাত: কারণ ও সমাধান',
        titleEn: 'Heavy Periods: Causes & Solutions',
        subtitleBn: 'অতিরিক্ত রক্তপাতের কারণ জানুন ও প্রয়োজনীয় পদক্ষেপ নিন।',
        subtitleEn: 'Learn why heavy bleeding happens and what to do about it.',
        contentBn:
            'হরমোনের অসামঞ্জস্য, ফাইব্রয়েড বা থাইরয়েড সমস্যার কারণে অতিরিক্ত রক্তপাত হতে পারে। লক্ষণ থাকলে চিকিৎসক দেখান।',
        contentEn:
            'Hormonal imbalance, fibroids or thyroid issues can cause heavy bleeding. See a doctor if symptoms persist.',
        imagePath: 'assets/images/articles/article_period.jpg',
        tags: const ['pain', 'hormone'],
        status: ArticleStatus.published,
        displayOrder: 3,
        views: 7200,
        likes: 612,
        commentsCount: 47,
        shares: 190,
        readingTimeMin: 5,
        medicalReviewerBn: 'ডাঃ সাবরিনা সুলতানা',
        medicalReviewerEn: 'Dr. Sabrina Sultana',
        isMedicallyReviewed: true,
        slug: 'heavy-periods-causes-and-solutions',
        createdAt: d(70),
        updatedAt: d(20),
        version: 1,
      ),
      Article(
        id: 'art-006',
        categoryId: 'discharge',
        titleBn: 'যোনি স্রাব বা ডিসচার্জ: কোনটি স্বাভাবিক?',
        titleEn: 'Vaginal Discharge: What is Normal?',
        subtitleBn: 'স্বাভাবিক ও অস্বাভাবিক স্রাবের লক্ষণগুলো চিনে নিন।',
        subtitleEn: 'Learn the signs of healthy vs unhealthy discharge.',
        contentBn:
            'যোনি স্রাব নারীদের শরীরের একটি স্বাভাবিক প্রক্রিয়া যা যোনিকে পরিচ্ছন্ন রাখতে সাহায্য করে। কিন্তু দুর্গন্ধযুক্ত বা অস্বাভাবিক রঙের স্রাব হলে চিকিৎসকের পরামর্শ নেওয়া জরুরি।',
        contentEn:
            'Discharge is a normal process that keeps the vaginal area healthy. However, discolored or foul-smelling discharge requires medical attention.',
        imagePath: 'assets/images/articles/article_care.jpg',
        tags: const ['hygiene', 'natural'],
        status: ArticleStatus.published,
        displayOrder: 4,
        readingTimeMin: 4,
        medicalReviewerBn: 'ডাঃ সাবরিনা সুলতানা',
        medicalReviewerEn: 'Dr. Sabrina Sultana',
        isMedicallyReviewed: true,
        slug: 'vaginal-discharge-what-is-normal',
        createdAt: d(30),
        updatedAt: d(1),
        version: 1,
      ),
      Article(
        id: 'art-007',
        categoryId: 'myths',
        titleBn: 'পিরিয়ড নিয়ে সাধারণ ৫টি ভুল ধারণা',
        titleEn: '5 Common Myths About Periods Debunked',
        subtitleBn: 'কুসংস্কার এড়িয়ে বৈজ্ঞানিক তথ্য জানুন।',
        subtitleEn: 'Separate fact from fiction with evidence-based truths.',
        contentBn:
            'পিরিয়ডের সময় টক খাওয়া যাবে না বা ব্যায়াম করা যাবে না — এগুলো নিতান্তই ভুল ধারণা। পুষ্টিকর খাবার ও হালকা ব্যায়াম বরং শরীরকে সুস্থ রাখে।',
        contentEn:
            'Avoiding sour food or skipping light exercise during menstruation are common myths. Balanced meals and light movement actually help.',
        imagePath: 'assets/images/articles/article_period.jpg',
        tags: const ['natural'],
        status: ArticleStatus.published,
        displayOrder: 5,
        views: 1100,
        likes: 98,
        commentsCount: 12,
        shares: 30,
        readingTimeMin: 3,
        medicalReviewerBn: 'ডাঃ সাবরিনা সুলতানা',
        medicalReviewerEn: 'Dr. Sabrina Sultana',
        isMedicallyReviewed: true,
        slug: '5-common-myths-about-periods-debunked',
        createdAt: d(25),
        updatedAt: d(2),
        version: 2,
      ),
    ];
  }

  @override
  Future<void> createArticle(Article article) async {}

  @override
  Future<void> updateArticle(Article article) async {}

  @override
  Future<void> deleteArticle(String id) async {}

  @override
  Future<void> createCategory(ArticleCategory category) async {}

  @override
  Future<void> updateCategory(ArticleCategory category) async {}

  @override
  Future<void> deleteCategory(String id) async {}
}
