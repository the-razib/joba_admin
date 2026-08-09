import 'package:joba_admin/core/models/article.dart';
import 'package:joba_admin/core/models/article_category.dart';

/// Phase 1: mock seed. Phase 3: `FirebaseArticleRepository` reads/writes
/// `articles` + `article_categories` (same schema as the Joba app).
abstract class ArticleRepository {
  Future<List<ArticleCategory>> seedCategories();
  Future<List<Article>> seedArticles();
  Future<List<String>> seedTags();
}

class MockArticleRepository implements ArticleRepository {
  @override
  Future<List<ArticleCategory>> seedCategories() async => const [
        ArticleCategory(id: 'period', nameBn: 'পিরিয়ড হেলথ', nameEn: 'Period Health', order: 0),
        ArticleCategory(id: 'care', nameBn: 'হাইজিন ও কেয়ার', nameEn: 'Hygiene & Care', order: 1),
        ArticleCategory(id: 'menopause', nameBn: 'মেনোপজ', nameEn: 'Menopause', order: 2),
        ArticleCategory(id: 'discharge', nameBn: 'ডিসচার্জ', nameEn: 'Discharge', order: 3),
        ArticleCategory(id: 'myths', nameBn: 'মিথ ও তথ্য', nameEn: 'Myths & Facts', order: 4),
      ];

  @override
  Future<List<String>> seedTags() async => const [
        'pain', 'cramps', 'relief', 'natural', 'hygiene',
        'nutrition', 'cycle', 'pms', 'hormone', 'fitness',
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
        subtitleBn: 'মাসিকের সময় প্রাকৃতিক উপায়ে ব্যথা কমানোর সহজ ও কার্যকরী উপায়গুলো জেনে নিন।',
        subtitleEn: 'Simple and effective natural ways to reduce menstrual pain.',
        contentBn:
            'মাসিকের সময় হালকা থেকে তীব্র ব্যথা হওয়া খুবই সাধারণ একটি বিষয়। তবে কিছু প্রাকৃতিক উপায়ে এই ব্যথা অনেকটাই কমানো সম্ভব।\n\nগরম পানির সেঁক, হালকা ব্যায়াম এবং পর্যাপ্ত পানি পান করলে ব্যথা উল্লেখযোগ্যভাবে কমে। এছাড়া আদা ও মৌরি চা উপকারী।\n\nব্যথা খুব তীব্র হলে বা দীর্ঘদিন থাকলে অবশ্যই চিকিৎসকের পরামর্শ নিন।',
        contentEn:
            'Mild to severe cramps during a period are very common. Several natural approaches can reduce the pain considerably.\n\nA warm compress, light exercise and staying hydrated all help. Ginger or fennel tea can also be beneficial.\n\nIf the pain is severe or persistent, always consult a doctor.',
        imagePath: 'assets/images/profile_avatars/hijab/hijab_avatar_01.png',
        tags: const ['pain', 'cramps', 'relief', 'natural'],
        status: ArticleStatus.published,
        featured: true,
        displayOrder: 0,
        views: 12400,
        likes: 1200,
        commentsCount: 86,
        shares: 532,
        readingTimeMin: 5,
        slug: 'how-to-manage-period-pain-naturally',
        seoTitle: 'Period Pain Relief: Natural Ways That Work',
        seoDescription: 'Discover natural, doctor-reviewed ways to reduce menstrual cramps and feel better during your period.',
        createdAt: d(85),
        updatedAt: d(3),
        version: 4,
      ),
      Article(
        id: 'art-002',
        categoryId: 'period',
        titleBn: 'মেনস্ট্রুয়াল সাইকেল বুঝে নিন',
        titleEn: 'Understanding Your Menstrual Cycle',
        subtitleBn: 'আপনার সাইকেলের চারটি ধাপ ও সেগুলোর প্রভাব বুঝে নিন।',
        subtitleEn: 'Understand the four phases of your cycle and how they affect you.',
        contentBn:
            'মেনস্ট্রুয়াল সাইকেল চারটি ধাপে বিভক্ত: মেনস্ট্রুয়াল, ফলিকুলার, ওভুলেশন ও লুটিয়াল। প্রতিটি ধাপে শরীরের হরমোন ও মেজাজে পরিবর্তন আসে।\n\nনিজের ধাপগুলো চিনে রাখলে পরিকল্পনা ও আত্মযত্ন সহজ হয়।',
        contentEn:
            'The menstrual cycle has four phases: menstrual, follicular, ovulation and luteal. Hormones, energy and mood shift across each phase.\n\nKnowing your phases makes planning and self-care much easier.',
        imagePath: 'assets/images/profile_avatars/modern/modern_avatar_03.png',
        tags: const ['cycle', 'hormone'],
        status: ArticleStatus.published,
        displayOrder: 1,
        views: 9800,
        likes: 932,
        commentsCount: 63,
        shares: 310,
        readingTimeMin: 6,
        slug: 'understanding-your-menstrual-cycle',
        createdAt: d(80),
        updatedAt: d(10),
        version: 2,
      ),
      Article(
        id: 'art-003',
        categoryId: 'period',
        titleBn: 'মাসিকের সময় যে খাবার খাওয়া উচিত',
        titleEn: 'Foods to Eat During Menstruation',
        subtitleBn: 'সঠিক খাবারে মাসিকের অস্বস্তি কমান।',
        subtitleEn: 'Reduce period discomfort with the right nutrition.',
        contentBn:
            'শাকসবজি, ফল, বাদাম ও পর্যাপ্ত পানি মাসিকের সময় শরীরকে সহায়তা করে। আয়রনসমৃদ্ধ খাবার রক্তস্বল্পতা প্রতিরোধে জরুরি।',
        contentEn:
            'Leafy greens, fruits, nuts and plenty of water support your body during menstruation. Iron-rich food helps prevent anaemia.',
        imagePath: 'assets/images/profile_avatars/simple/simple_avatar_05.png',
        tags: const ['nutrition', 'pms'],
        status: ArticleStatus.published,
        displayOrder: 2,
        views: 8600,
        likes: 745,
        commentsCount: 52,
        shares: 268,
        readingTimeMin: 4,
        slug: 'foods-to-eat-during-menstruation',
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
        imagePath: 'assets/images/profile_avatars/modern/modern_avatar_06.png',
        tags: const ['hygiene'],
        status: ArticleStatus.published,
        displayOrder: 0,
        views: 8600,
        likes: 745,
        commentsCount: 47,
        shares: 220,
        readingTimeMin: 4,
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
        imagePath: 'assets/images/profile_avatars/hijab/hijab_avatar_04.png',
        tags: const ['pain', 'hormone'],
        status: ArticleStatus.published,
        displayOrder: 3,
        views: 7200,
        likes: 612,
        commentsCount: 47,
        shares: 190,
        readingTimeMin: 5,
        slug: 'heavy-periods-causes-and-solutions',
        createdAt: d(70),
        updatedAt: d(20),
        version: 1,
      ),
      Article(
        id: 'art-006',
        categoryId: 'period',
        titleBn: 'অনিয়মিত পিরিয়ড: কখন চিন্তা করবেন',
        titleEn: 'Irregular Periods: When to Worry',
        subtitleBn: 'অনিয়মিত পিরিয়ডের কারণ ও সতর্কতার লক্ষণ।',
        subtitleEn: 'Causes of irregular periods and warning signs to watch.',
        contentBn: 'মাঝে মাঝে সাইকেল ওঠানামা করা স্বাভাবিক। তবে টানা তিন মাস অনিয়ম থাকলে চিকিৎসকের পরামর্শ নিন।',
        contentEn: 'Occasional cycle variation is normal. But see a doctor if irregularity persists for three months.',
        imagePath: '',
        tags: const ['cycle', 'pms'],
        status: ArticleStatus.draft,
        displayOrder: 4,
        readingTimeMin: 5,
        slug: 'irregular-periods-when-to-worry',
        createdAt: d(30),
        updatedAt: d(1),
        version: 1,
      ),
      Article(
        id: 'art-007',
        categoryId: 'myths',
        titleBn: 'ক্র্যাম্প বনাম সাধারণ ব্যথা: পার্থক্য জানুন',
        titleEn: 'Cramps vs Normal Pain: Know the Difference',
        subtitleBn: 'কোন ব্যথা স্বাভাবিক আর কোনটি সতর্কতার, জেনে নিন।',
        subtitleEn: 'Which pains are normal and which need attention.',
        contentBn: 'ক্র্যাম্প সাধারণত পেটের নিচের অংশে হয় এবং ১-৩ দিন থাকে। তীব্র ও দীর্ঘস্থায়ী ব্যথা এন্ডোমেট্রিওসিসের লক্ষণ হতে পারে।',
        contentEn: 'Cramps usually sit low in the abdomen and last 1-3 days. Severe, long pain may signal endometriosis.',
        imagePath: 'assets/images/profile_avatars/simple/simple_avatar_09.png',
        tags: const ['pain', 'cramps'],
        status: ArticleStatus.review,
        displayOrder: 5,
        views: 1100,
        likes: 98,
        commentsCount: 12,
        shares: 30,
        readingTimeMin: 4,
        slug: 'cramps-vs-normal-pain',
        createdAt: d(25),
        updatedAt: d(2),
        version: 2,
      ),
      Article(
        id: 'art-008',
        categoryId: 'menopause',
        titleBn: 'মেনোপজের প্রাথমিক লক্ষণসমূহ',
        titleEn: 'Early Signs of Menopause',
        subtitleBn: 'পেরিমেনোপজের লক্ষণ চিনে প্রস্তুত থাকুন।',
        subtitleEn: 'Recognise perimenopause signs and stay prepared.',
        contentBn: 'গরম লাগা, ঘুমের সমস্যা ও মেজাজের পরিবর্তন প্রাথমিক লক্ষণ হতে পারে।',
        contentEn: 'Hot flashes, sleep issues and mood swings can be early signs.',
        imagePath: 'assets/images/profile_avatars/hijab/hijab_avatar_07.png',
        tags: const ['hormone'],
        status: ArticleStatus.published,
        displayOrder: 0,
        views: 5400,
        likes: 421,
        commentsCount: 33,
        shares: 140,
        readingTimeMin: 5,
        slug: 'early-signs-of-menopause',
        createdAt: d(60),
        updatedAt: d(8),
        version: 1,
      ),
    ];
  }
}
