import 'package:cloud_firestore/cloud_firestore.dart';

enum ArticleStatus {
  published('Published'),
  draft('Draft'),
  review('Review');

  final String label;
  const ArticleStatus(this.label);
}

/// Rich Article entity supporting bilingual content (BN & EN),
/// real analytics (views & bookmarks), medical review metadata, and dual serialization.
class Article {
  const Article({
    required this.id,
    required this.categoryId,
    required this.titleBn,
    required this.titleEn,
    this.subtitleBn = '',
    this.subtitleEn = '',
    this.contentBn = '',
    this.contentEn = '',
    this.imagePath = '',
    this.audioBnPath,
    this.audioEnPath,
    this.tags = const [],
    this.status = ArticleStatus.published,
    this.featured = false,
    this.displayOrder = 0,
    this.views = 0,
    this.bookmarks = 0,
    this.commentsCount = 0,
    this.shares = 0,
    this.readingTimeMin = 3,
    this.medicalReviewerBn = 'ডা. সাবরিনা রহমান (এমবিবিএস, এফসিপিএস)',
    this.medicalReviewerEn = 'Dr. Sabrina Rahman (MBBS, FCPS)',
    this.isMedicallyReviewed = true,
    this.slug = '',
    this.seoTitle = '',
    this.seoDescription = '',
    this.createdBy = 'Admin',
    required this.createdAt,
    required this.updatedAt,
    this.version = 1,
  });

  final String id;
  final String categoryId;
  final String titleBn;
  final String titleEn;
  final String subtitleBn;
  final String subtitleEn;
  final String contentBn;
  final String contentEn;
  final String imagePath;
  final String? audioBnPath;
  final String? audioEnPath;
  final List<String> tags;
  final ArticleStatus status;
  final bool featured;
  final int displayOrder;
  final int views;
  final int bookmarks;
  int get likes => bookmarks; // Backwards compatibility alias
  final int commentsCount;
  final int shares;
  final int readingTimeMin;
  final String medicalReviewerBn;
  final String medicalReviewerEn;
  final bool isMedicallyReviewed;
  final String slug;
  final String seoTitle;
  final String seoDescription;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  Article copyWith({
    String? id,
    String? categoryId,
    String? titleBn,
    String? titleEn,
    String? subtitleBn,
    String? subtitleEn,
    String? contentBn,
    String? contentEn,
    String? imagePath,
    String? audioBnPath,
    String? audioEnPath,
    List<String>? tags,
    ArticleStatus? status,
    bool? featured,
    int? displayOrder,
    int? views,
    int? bookmarks,
    int? commentsCount,
    int? shares,
    int? readingTimeMin,
    String? medicalReviewerBn,
    String? medicalReviewerEn,
    bool? isMedicallyReviewed,
    String? slug,
    String? seoTitle,
    String? seoDescription,
    DateTime? updatedAt,
    int? version,
  }) =>
      Article(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        titleBn: titleBn ?? this.titleBn,
        titleEn: titleEn ?? this.titleEn,
        subtitleBn: subtitleBn ?? this.subtitleBn,
        subtitleEn: subtitleEn ?? this.subtitleEn,
        contentBn: contentBn ?? this.contentBn,
        contentEn: contentEn ?? this.contentEn,
        imagePath: imagePath ?? this.imagePath,
        audioBnPath: audioBnPath ?? this.audioBnPath,
        audioEnPath: audioEnPath ?? this.audioEnPath,
        tags: tags ?? this.tags,
        status: status ?? this.status,
        featured: featured ?? this.featured,
        displayOrder: displayOrder ?? this.displayOrder,
        views: views ?? this.views,
        bookmarks: bookmarks ?? this.bookmarks,
        commentsCount: commentsCount ?? this.commentsCount,
        shares: shares ?? this.shares,
        readingTimeMin: readingTimeMin ?? this.readingTimeMin,
        medicalReviewerBn: medicalReviewerBn ?? this.medicalReviewerBn,
        medicalReviewerEn: medicalReviewerEn ?? this.medicalReviewerEn,
        isMedicallyReviewed: isMedicallyReviewed ?? this.isMedicallyReviewed,
        slug: slug ?? this.slug,
        seoTitle: seoTitle ?? this.seoTitle,
        seoDescription: seoDescription ?? this.seoDescription,
        createdBy: createdBy,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'category': categoryId,
      'title': {'bn': titleBn, 'en': titleEn},
      'titleBn': titleBn,
      'titleEn': titleEn,
      'title_bn': titleBn,
      'title_en': titleEn,
      'subtitle': {'bn': subtitleBn, 'en': subtitleEn},
      'subtitleBn': subtitleBn,
      'subtitleEn': subtitleEn,
      'subtitle_bn': subtitleBn,
      'subtitle_en': subtitleEn,
      'content': {'bn': contentBn, 'en': contentEn},
      'contentBn': contentBn,
      'contentEn': contentEn,
      'content_bn': contentBn,
      'content_en': contentEn,
      'imagePath': imagePath,
      'imageUrl': imagePath,
      'audioBnPath': audioBnPath,
      'audioEnPath': audioEnPath,
      'audioUrl': {'bn': audioBnPath, 'en': audioEnPath},
      'tags': tags,
      'status': status.name,
      'isPublished': status == ArticleStatus.published,
      'featured': featured,
      'displayOrder': displayOrder,
      'order': displayOrder,
      'views': views,
      'bookmarks': bookmarks,
      'likes': bookmarks,
      'commentsCount': commentsCount,
      'shares': shares,
      'readingTimeMin': readingTimeMin,
      'medicalReviewerBn': medicalReviewerBn,
      'medicalReviewerEn': medicalReviewerEn,
      'isMedicallyReviewed': isMedicallyReviewed,
      'slug': slug,
      'seoTitle': seoTitle,
      'seoDescription': seoDescription,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'version': version,
      'articleVersion': version,
    };
  }

  factory Article.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    final titleMap = map['title'] as Map<String, dynamic>?;
    final subtitleMap = map['subtitle'] as Map<String, dynamic>?;
    final contentMap = map['content'] as Map<String, dynamic>?;
    final audioMap = map['audioUrl'] as Map<String, dynamic>?;

    final isPub = map['isPublished'] as bool?;
    final statusStr = map['status']?.toString().toLowerCase() ??
        (isPub == false ? 'draft' : 'published');
    final artStatus = ArticleStatus.values.firstWhere(
      (s) => s.name == statusStr,
      orElse: () => ArticleStatus.published,
    );

    return Article(
      id: docId ?? map['id']?.toString() ?? '',
      categoryId: map['categoryId']?.toString() ??
          map['category']?.toString() ??
          'period',
      titleBn: titleMap?['bn']?.toString() ??
          map['titleBn']?.toString() ??
          map['title_bn']?.toString() ??
          '',
      titleEn: titleMap?['en']?.toString() ??
          map['titleEn']?.toString() ??
          map['title_en']?.toString() ??
          '',
      subtitleBn: subtitleMap?['bn']?.toString() ??
          map['subtitleBn']?.toString() ??
          map['subtitle_bn']?.toString() ??
          '',
      subtitleEn: subtitleMap?['en']?.toString() ??
          map['subtitleEn']?.toString() ??
          map['subtitle_en']?.toString() ??
          '',
      contentBn: contentMap?['bn']?.toString() ??
          map['contentBn']?.toString() ??
          map['content_bn']?.toString() ??
          '',
      contentEn: contentMap?['en']?.toString() ??
          map['contentEn']?.toString() ??
          map['content_en']?.toString() ??
          '',
      imagePath: map['imageUrl']?.toString() ??
          map['imagePath']?.toString() ??
          '',
      audioBnPath: audioMap?['bn']?.toString() ??
          map['audioBnPath']?.toString(),
      audioEnPath: audioMap?['en']?.toString() ??
          map['audioEnPath']?.toString(),
      tags: (map['tags'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      status: artStatus,
      featured: map['featured'] as bool? ?? false,
      displayOrder: (map['displayOrder'] as num?)?.toInt() ??
          (map['order'] as num?)?.toInt() ??
          0,
      views: (map['views'] as num?)?.toInt() ?? 0,
      bookmarks: (map['bookmarks'] as num?)?.toInt() ??
          (map['likes'] as num?)?.toInt() ??
          0,
      commentsCount: (map['commentsCount'] as num?)?.toInt() ?? 0,
      shares: (map['shares'] as num?)?.toInt() ?? 0,
      readingTimeMin: (map['readingTimeMin'] as num?)?.toInt() ?? 3,
      medicalReviewerBn: map['medicalReviewerBn']?.toString() ??
          'ডা. সাবরিনা রহমান (এমবিবিএস, এফসিপিএস)',
      medicalReviewerEn: map['medicalReviewerEn']?.toString() ??
          'Dr. Sabrina Rahman (MBBS, FCPS)',
      isMedicallyReviewed: map['isMedicallyReviewed'] as bool? ?? true,
      slug: map['slug']?.toString() ?? '',
      seoTitle: map['seoTitle']?.toString() ?? '',
      seoDescription: map['seoDescription']?.toString() ?? '',
      createdBy: map['createdBy']?.toString() ?? 'Admin',
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
      version: (map['version'] as num?)?.toInt() ??
          (map['articleVersion'] as num?)?.toInt() ??
          1,
    );
  }
}
