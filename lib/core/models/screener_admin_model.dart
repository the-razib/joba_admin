enum RiskTierKey { low, moderate, high }

/// Configuration for individual risk tiers on the result gauge
class RiskTierAdminConfig {
  final RiskTierKey key;
  final String labelBn;
  final String labelEn;
  final String descriptionBn;
  final String descriptionEn;
  final String colorHex;
  final double minRatio;
  final double maxRatio;

  const RiskTierAdminConfig({
    required this.key,
    required this.labelBn,
    required this.labelEn,
    required this.descriptionBn,
    required this.descriptionEn,
    required this.colorHex,
    required this.minRatio,
    required this.maxRatio,
  });

  RiskTierAdminConfig copyWith({
    RiskTierKey? key,
    String? labelBn,
    String? labelEn,
    String? descriptionBn,
    String? descriptionEn,
    String? colorHex,
    double? minRatio,
    double? maxRatio,
  }) {
    return RiskTierAdminConfig(
      key: key ?? this.key,
      labelBn: labelBn ?? this.labelBn,
      labelEn: labelEn ?? this.labelEn,
      descriptionBn: descriptionBn ?? this.descriptionBn,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      colorHex: colorHex ?? this.colorHex,
      minRatio: minRatio ?? this.minRatio,
      maxRatio: maxRatio ?? this.maxRatio,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key.name,
      'labelBn': labelBn,
      'labelEn': labelEn,
      'descriptionBn': descriptionBn,
      'descriptionEn': descriptionEn,
      'colorHex': colorHex,
      'minRatio': minRatio,
      'maxRatio': maxRatio,
    };
  }

  factory RiskTierAdminConfig.fromMap(Map<String, dynamic> map) {
    return RiskTierAdminConfig(
      key: RiskTierKey.values.firstWhere(
        (e) => e.name == map['key'],
        orElse: () => RiskTierKey.low,
      ),
      labelBn: map['labelBn'] ?? '',
      labelEn: map['labelEn'] ?? '',
      descriptionBn: map['descriptionBn'] ?? '',
      descriptionEn: map['descriptionEn'] ?? '',
      colorHex: map['colorHex'] ?? '#5FA873',
      minRatio: (map['minRatio'] as num?)?.toDouble() ?? 0.0,
      maxRatio: (map['maxRatio'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

/// A single clinical question inside a screener questionnaire
class ScreenerQuestionAdmin {
  final String id;
  final String questionBn;
  final String questionEn;
  final int points;
  final int order;
  final bool isActive;

  const ScreenerQuestionAdmin({
    required this.id,
    required this.questionBn,
    required this.questionEn,
    this.points = 1,
    this.order = 0,
    this.isActive = true,
  });

  ScreenerQuestionAdmin copyWith({
    String? id,
    String? questionBn,
    String? questionEn,
    int? points,
    int? order,
    bool? isActive,
  }) {
    return ScreenerQuestionAdmin(
      id: id ?? this.id,
      questionBn: questionBn ?? this.questionBn,
      questionEn: questionEn ?? this.questionEn,
      points: points ?? this.points,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionBn': questionBn,
      'questionEn': questionEn,
      'points': points,
      'order': order,
      'isActive': isActive,
    };
  }

  factory ScreenerQuestionAdmin.fromMap(Map<String, dynamic> map) {
    return ScreenerQuestionAdmin(
      id: map['id'] ?? '',
      questionBn: map['questionBn'] ?? '',
      questionEn: map['questionEn'] ?? '',
      points: (map['points'] as num?)?.toInt() ?? 1,
      order: (map['order'] as num?)?.toInt() ?? 0,
      isActive: map['isActive'] as bool? ?? true,
    );
  }
}

/// Clinical Disease Checkup Screener Model for Admin Panel
class ScreenerAdminModel {
  final String id;
  final String nameBn;
  final String nameEn;
  final String subtitleBn;
  final String subtitleEn;
  final String source;
  final String imagePath; // PNG / SVG asset path or Firebase Storage URL
  final String accentColorHex;
  final int displayOrder;
  final bool enabled;
  final List<ScreenerQuestionAdmin> questions;
  final List<RiskTierAdminConfig> riskTiers;
  final int totalCompletions;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ScreenerAdminModel({
    required this.id,
    required this.nameBn,
    required this.nameEn,
    required this.subtitleBn,
    required this.subtitleEn,
    required this.source,
    this.imagePath = '',
    this.accentColorHex = '#E65671',
    this.displayOrder = 0,
    this.enabled = true,
    this.questions = const [],
    this.riskTiers = const [],
    this.totalCompletions = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  int get activeQuestionsCount => questions.where((q) => q.isActive).length;

  int get totalPoints =>
      questions.where((q) => q.isActive).fold(0, (sum, q) => sum + q.points);

  ScreenerAdminModel copyWith({
    String? id,
    String? nameBn,
    String? nameEn,
    String? subtitleBn,
    String? subtitleEn,
    String? source,
    String? imagePath,
    String? accentColorHex,
    int? displayOrder,
    bool? enabled,
    List<ScreenerQuestionAdmin>? questions,
    List<RiskTierAdminConfig>? riskTiers,
    int? totalCompletions,
    DateTime? updatedAt,
  }) {
    return ScreenerAdminModel(
      id: id ?? this.id,
      nameBn: nameBn ?? this.nameBn,
      nameEn: nameEn ?? this.nameEn,
      subtitleBn: subtitleBn ?? this.subtitleBn,
      subtitleEn: subtitleEn ?? this.subtitleEn,
      source: source ?? this.source,
      imagePath: imagePath ?? this.imagePath,
      accentColorHex: accentColorHex ?? this.accentColorHex,
      displayOrder: displayOrder ?? this.displayOrder,
      enabled: enabled ?? this.enabled,
      questions: questions ?? this.questions,
      riskTiers: riskTiers ?? this.riskTiers,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nameBn': nameBn,
      'nameEn': nameEn,
      'subtitleBn': subtitleBn,
      'subtitleEn': subtitleEn,
      'source': source,
      'imagePath': imagePath,
      'accentColorHex': accentColorHex,
      'displayOrder': displayOrder,
      'enabled': enabled,
      'questions': questions.map((q) => q.toMap()).toList(),
      'riskTiers': riskTiers.map((t) => t.toMap()).toList(),
      'totalCompletions': totalCompletions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ScreenerAdminModel.fromMap(Map<String, dynamic> map) {
    return ScreenerAdminModel(
      id: map['id'] ?? '',
      nameBn: map['nameBn'] ?? '',
      nameEn: map['nameEn'] ?? '',
      subtitleBn: map['subtitleBn'] ?? '',
      subtitleEn: map['subtitleEn'] ?? '',
      source: map['source'] ?? '',
      imagePath: map['imagePath'] ?? '',
      accentColorHex: map['accentColorHex'] ?? '#E65671',
      displayOrder: (map['displayOrder'] as num?)?.toInt() ?? 0,
      enabled: map['enabled'] as bool? ?? true,
      questions:
          (map['questions'] as List<dynamic>?)
              ?.map(
                (q) => ScreenerQuestionAdmin.fromMap(q as Map<String, dynamic>),
              )
              .toList() ??
          [],
      riskTiers:
          (map['riskTiers'] as List<dynamic>?)
              ?.map(
                (t) => RiskTierAdminConfig.fromMap(t as Map<String, dynamic>),
              )
              .toList() ??
          [],
      totalCompletions: (map['totalCompletions'] as num?)?.toInt() ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
