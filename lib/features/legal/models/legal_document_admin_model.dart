import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents an editable legal document in the Joba Admin panel
/// (Privacy Policy, Terms & Conditions).
class LegalDocumentAdminModel {
  final String id;
  final String titleBn;
  final String titleEn;
  final String contentBn;
  final String contentEn;
  final String version;
  final DateTime updatedAt;

  const LegalDocumentAdminModel({
    required this.id,
    required this.titleBn,
    required this.titleEn,
    required this.contentBn,
    required this.contentEn,
    this.version = '1.0.0',
    required this.updatedAt,
  });

  LegalDocumentAdminModel copyWith({
    String? id,
    String? titleBn,
    String? titleEn,
    String? contentBn,
    String? contentEn,
    String? version,
    DateTime? updatedAt,
  }) {
    return LegalDocumentAdminModel(
      id: id ?? this.id,
      titleBn: titleBn ?? this.titleBn,
      titleEn: titleEn ?? this.titleEn,
      contentBn: contentBn ?? this.contentBn,
      contentEn: contentEn ?? this.contentEn,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titleBn': titleBn,
      'titleEn': titleEn,
      'contentBn': contentBn,
      'contentEn': contentEn,
      'version': version,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory LegalDocumentAdminModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedDate;
    final rawDate = map['updatedAt'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return LegalDocumentAdminModel(
      id: id,
      titleBn: map['titleBn']?.toString() ?? '',
      titleEn: map['titleEn']?.toString() ?? '',
      contentBn: map['contentBn']?.toString() ?? '',
      contentEn: map['contentEn']?.toString() ?? '',
      version: map['version']?.toString() ?? '1.0.0',
      updatedAt: parsedDate,
    );
  }
}
