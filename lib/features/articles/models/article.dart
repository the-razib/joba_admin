import 'package:cloud_firestore/cloud_firestore.dart';

enum ArticleStatus {
  draft,
  review,
  published;

  String get label => switch (this) {
        ArticleStatus.draft => 'Draft',
        ArticleStatus.review => 'In Review',
        ArticleStatus.published => 'Published',
      };
}

/// Mirrors the app's bilingual `articles` Firestore schema and extends it
/// with admin-only fields (audio, SEO, stats, medical review) that the app safely ignores.
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
    this.likes = 0,
    this.commentsCount = 0,
    this.shares = 0,
    this.readingTimeMin = 3,
    this.medicalReviewerBn = 'ডাঃ সাবরিনা সুলতানা',
    this.medicalReviewerEn = 'Dr. Sabrina Sultana',
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
  final String imagePath; // asset path (mock) or Storage URL (Phase 3)
  final String? audioBnPath;
  final String? audioEnPath;
  final List<String> tags;
  final ArticleStatus status;
  final bool featured;
  final int displayOrder;
  final int views;
  final int likes;
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
    int? readingTimeMin,
    String? medicalReviewerBn,
    String? medicalReviewerEn,
    bool? isMedicallyReviewed,
    String? slug,
    String? seoTitle,
    String? seoDescription,
    int? version,
    DateTime? updatedAt,
  }) =>
      Article(
        id: id,
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
        views: views,
        likes: likes,
        commentsCount: commentsCount,
        shares: shares,
        readingTimeMin: readingTimeMin ?? this.readingTimeMin,
        medicalReviewerBn: medicalReviewerBn ?? this.medicalReviewerBn,
        medicalReviewerEn: medicalReviewerEn ?? this.medicalReviewerEn,
        isMedicallyReviewed: isMedicallyReviewed ?? this.isMedicallyReviewed,
        slug: slug ?? this.slug,
        seoTitle: seoTitle ?? this.seoTitle,
        createdBy: createdBy,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'title': {'bn': titleBn, 'en': titleEn},
      'titleBn': titleBn,
      'titleEn': titleEn,
      'subtitle': {'bn': subtitleBn, 'en': subtitleEn},
      'subtitleBn': subtitleBn,
      'subtitleEn': subtitleEn,
      'content': {'bn': contentBn, 'en': contentEn},
      'contentBn': contentBn,
      'contentEn': contentEn,
      'imagePath': imagePath,
      'imageUrl': imagePath,
      'audioBnPath': audioBnPath,
      'audioEnPath': audioEnPath,
      'audioUrl': {'bn': audioBnPath, 'en': audioEnPath},
      'tags': tags,
      'status': status.name,
      'featured': featured,
      'displayOrder': displayOrder,
      'views': views,
      'likes': likes,
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

    final statusStr = map['status']?.toString().toLowerCase() ?? 'published';
    final artStatus = ArticleStatus.values.firstWhere(
      (s) => s.name == statusStr,
      orElse: () => ArticleStatus.published,
    );

    return Article(
      id: docId ?? map['id']?.toString() ?? '',
      categoryId: map['categoryId']?.toString() ?? 'period',
      titleBn: titleMap?['bn']?.toString() ?? map['titleBn']?.toString() ?? '',
      titleEn: titleMap?['en']?.toString() ?? map['titleEn']?.toString() ?? '',
      subtitleBn: subtitleMap?['bn']?.toString() ?? map['subtitleBn']?.toString() ?? '',
      subtitleEn: subtitleMap?['en']?.toString() ?? map['subtitleEn']?.toString() ?? '',
      contentBn: contentMap?['bn']?.toString() ?? map['contentBn']?.toString() ?? '',
      contentEn: contentMap?['en']?.toString() ?? map['contentEn']?.toString() ?? '',
      imagePath: map['imageUrl']?.toString() ?? map['imagePath']?.toString() ?? '',
      audioBnPath: audioMap?['bn']?.toString() ?? map['audioBnPath']?.toString(),
      audioEnPath: audioMap?['en']?.toString() ?? map['audioEnPath']?.toString(),
      tags: (map['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      status: artStatus,
      featured: map['featured'] as bool? ?? false,
      displayOrder: (map['displayOrder'] as num?)?.toInt() ?? 0,
      views: (map['views'] as num?)?.toInt() ?? 0,
      likes: (map['likes'] as num?)?.toInt() ?? 0,
      commentsCount: (map['commentsCount'] as num?)?.toInt() ?? 0,
      shares: (map['shares'] as num?)?.toInt() ?? 0,
      readingTimeMin: (map['readingTimeMin'] as num?)?.toInt() ?? 3,
      medicalReviewerBn: map['medicalReviewerBn']?.toString() ?? 'ডাঃ সাবরিনা সুলতানা',
      medicalReviewerEn: map['medicalReviewerEn']?.toString() ?? 'Dr. Sabrina Sultana',
      isMedicallyReviewed: map['isMedicallyReviewed'] as bool? ?? true,
      slug: map['slug']?.toString() ?? '',
      seoTitle: map['seoTitle']?.toString() ?? '',
      seoDescription: map['seoDescription']?.toString() ?? '',
      createdBy: map['createdBy']?.toString() ?? 'Admin',
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
      version: (map['version'] as num?)?.toInt() ?? 1,
    );
  }
}
