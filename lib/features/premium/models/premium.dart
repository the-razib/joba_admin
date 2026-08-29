import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_colors.dart';

class PromoCode {
  const PromoCode({
    required this.code,
    required this.percentOff,
    required this.expiresAt,
    this.active = true,
    this.usedCount = 0,
  });

  final String code;
  final int percentOff;
  final DateTime expiresAt;
  final bool active;
  final int usedCount;

  PromoCode copyWith({bool? active}) => PromoCode(
        code: code,
        percentOff: percentOff,
        expiresAt: expiresAt,
        active: active ?? this.active,
        usedCount: usedCount,
      );

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'percentOff': percentOff,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'active': active,
      'usedCount': usedCount,
    };
  }

  factory PromoCode.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return PromoCode(
      code: docId ?? map['code']?.toString() ?? '',
      percentOff: (map['percentOff'] as num?)?.toInt() ?? 0,
      expiresAt: parseDate(map['expiresAt']),
      active: map['active'] as bool? ?? true,
      usedCount: (map['usedCount'] as num?)?.toInt() ?? 0,
    );
  }
}

enum TxStatus {
  success,
  refunded,
  pending;

  String get label => switch (this) {
        TxStatus.success => 'Success',
        TxStatus.refunded => 'Refunded',
        TxStatus.pending => 'Pending',
      };

  Color get color => switch (this) {
        TxStatus.success => AppColors.success,
        TxStatus.refunded => AppColors.purple,
        TxStatus.pending => AppColors.warning,
      };
}

class Transaction {
  const Transaction({
    required this.id,
    required this.userName,
    required this.amountBdt,
    required this.method,
    required this.date,
    this.status = TxStatus.success,
  });

  final String id;
  final String userName;
  final int amountBdt;
  final String method; // bKash / Nagad / Card
  final DateTime date;
  final TxStatus status;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'amountBdt': amountBdt,
      'method': method,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(date),
      'status': status.name,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    final stStr = map['status']?.toString().toLowerCase() ?? 'success';
    final txStatus = TxStatus.values.firstWhere(
      (s) => s.name == stStr,
      orElse: () => TxStatus.success,
    );

    return Transaction(
      id: docId ?? map['id']?.toString() ?? '',
      userName: map['userName']?.toString() ?? 'Anonymous',
      amountBdt: (map['amountBdt'] as num?)?.toInt() ?? 0,
      method: map['method']?.toString() ?? 'bKash',
      date: parseDate(map['date'] ?? map['createdAt']),
      status: txStatus,
    );
  }
}
