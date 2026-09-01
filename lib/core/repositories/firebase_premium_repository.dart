import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:flutter/foundation.dart';
import 'package:joba_admin/core/repositories/premium_repository.dart';
import 'package:joba_admin/core/services/audit_service.dart';
import 'package:joba_admin/features/audit_logs/models/audit_log.dart';
import 'package:joba_admin/features/premium/models/premium.dart';
import 'package:joba_admin/features/users/models/app_user.dart';

/// Production Firebase repository for Premium features, promo codes and transactions.
class FirebasePremiumRepository implements PremiumRepository {
  final FirebaseFirestore _firestore;

  FirebasePremiumRepository([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _promosCollection = 'promo_codes';
  static const String _transactionsCollection = 'transactions';
  static const String _usersCollection = 'users';

  @override
  Future<List<AppUser>> fetchPremiumUsers() async {
    try {
      final snap = await _firestore
          .collection(_usersCollection)
          .where('plan', isEqualTo: 'premium')
          .get();

      return snap.docs
          .map((doc) => AppUser.fromMap(doc.data(), docId: doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching premium users: $e');
      return [];
    }
  }

  @override
  Future<List<PromoCode>> fetchPromos() async {
    try {
      final snap = await _firestore
          .collection(_promosCollection)
          .orderBy('expiresAt', descending: true)
          .get();

      return snap.docs
          .map((doc) => PromoCode.fromMap(doc.data(), docId: doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching promo codes: $e');
      // Fallback query without order by in case index is pending
      try {
        final fallback = await _firestore.collection(_promosCollection).get();
        return fallback.docs
            .map((doc) => PromoCode.fromMap(doc.data(), docId: doc.id))
            .toList();
      } catch (_) {
        return [];
      }
    }
  }

  @override
  Future<void> createPromo(PromoCode promo) async {
    final cleanCode = promo.code.trim().toUpperCase();
    final docRef = _firestore.collection(_promosCollection).doc(cleanCode);

    final existing = await docRef.get();
    if (existing.exists) {
      throw Exception('Promo code "$cleanCode" already exists.');
    }

    final data = promo.toMap();
    data['code'] = cleanCode;
    data['createdAt'] = FieldValue.serverTimestamp();

    await docRef.set(data);

    await AuditService.log(
      module: 'Premium & Payments',
      action: AuditAction.created,
      details: 'Created promo code $cleanCode (${promo.percentOff}% off, expires ${promo.expiresAt.toIso8601String().split('T')[0]})',
    );
  }

  @override
  Future<void> togglePromo(String code, bool active) async {
    final cleanCode = code.trim().toUpperCase();
    await _firestore.collection(_promosCollection).doc(cleanCode).update({
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await AuditService.log(
      module: 'Premium & Payments',
      action: AuditAction.updated,
      details: '${active ? 'Activated' : 'Deactivated'} promo code $cleanCode',
    );
  }

  @override
  Future<void> deletePromo(String code) async {
    final cleanCode = code.trim().toUpperCase();
    await _firestore.collection(_promosCollection).doc(cleanCode).delete();

    await AuditService.log(
      module: 'Premium & Payments',
      action: AuditAction.deleted,
      details: 'Deleted promo code $cleanCode',
    );
  }

  @override
  Future<List<Transaction>> fetchTransactions({int limit = 100}) async {
    try {
      final snap = await _firestore
          .collection(_transactionsCollection)
          .orderBy('date', descending: true)
          .limit(limit)
          .get();

      return snap.docs
          .map((doc) => Transaction.fromMap(doc.data(), docId: doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      try {
        final fallback = await _firestore
            .collection(_transactionsCollection)
            .limit(limit)
            .get();
        return fallback.docs
            .map((doc) => Transaction.fromMap(doc.data(), docId: doc.id))
            .toList();
      } catch (_) {
        return [];
      }
    }
  }
}
