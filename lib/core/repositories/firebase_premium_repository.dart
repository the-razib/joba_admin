import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:joba_admin/core/repositories/premium_repository.dart';
import 'package:joba_admin/core/services/audit_service.dart';
import 'package:joba_admin/core/utils/logging/logger.dart';
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
    AppLoggerHelper.info('[PremiumRepository] 💎 Querying premium tier users...');
    try {
      final snap = await _firestore
          .collection(_usersCollection)
          .where('plan', isEqualTo: 'premium')
          .get();

      final list = snap.docs
          .map((doc) => AppUser.fromMap(doc.data(), docId: doc.id))
          .toList();
      AppLoggerHelper.success('PremiumRepository', 'Fetched ${list.length} premium users');
      return list;
    } catch (e, st) {
      AppLoggerHelper.failure('PremiumRepository', 'Error fetching premium users: $e', error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<List<PromoCode>> fetchPromos() async {
    AppLoggerHelper.info('[PremiumRepository] 🎟️ Fetching promo codes...');
    try {
      final snap = await _firestore
          .collection(_promosCollection)
          .orderBy('expiresAt', descending: true)
          .get();

      final list = snap.docs
          .map((doc) => PromoCode.fromMap(doc.data(), docId: doc.id))
          .toList();
      AppLoggerHelper.success('PremiumRepository', 'Fetched ${list.length} promo codes');
      return list;
    } catch (e) {
      AppLoggerHelper.warning('PremiumRepository', 'Error fetching ordered promo codes, using fallback: $e');
      // Fallback query without order by in case index is pending
      try {
        final fallback = await _firestore.collection(_promosCollection).get();
        final list = fallback.docs
            .map((doc) => PromoCode.fromMap(doc.data(), docId: doc.id))
            .toList();
        AppLoggerHelper.success('PremiumRepository', 'Fetched ${list.length} promo codes (unordered fallback)');
        return list;
      } catch (err, st) {
        AppLoggerHelper.failure('PremiumRepository', 'Fallback failed for promo codes: $err', error: err, stackTrace: st);
        return [];
      }
    }
  }

  @override
  Future<void> createPromo(PromoCode promo) async {
    final cleanCode = promo.code.trim().toUpperCase();
    AppLoggerHelper.info('[PremiumRepository] 🎟️ Creating promo code $cleanCode (${promo.percentOff}% off)...');
    final docRef = _firestore.collection(_promosCollection).doc(cleanCode);

    final existing = await docRef.get();
    if (existing.exists) {
      AppLoggerHelper.warning('PremiumRepository', 'Promo code "$cleanCode" already exists.');
      throw Exception('Promo code "$cleanCode" already exists.');
    }

    final data = promo.toMap();
    data['code'] = cleanCode;
    data['createdAt'] = FieldValue.serverTimestamp();

    await docRef.set(data);
    AppLoggerHelper.success('PremiumRepository', 'Promo code $cleanCode saved to Firestore');

    await AuditService.log(
      module: 'Premium & Payments',
      action: AuditAction.created,
      details: 'Created promo code $cleanCode (${promo.percentOff}% off, expires ${promo.expiresAt.toIso8601String().split('T')[0]})',
    );
  }

  @override
  Future<void> togglePromo(String code, bool active) async {
    final cleanCode = code.trim().toUpperCase();
    AppLoggerHelper.info('[PremiumRepository] 🔄 Toggling promo code $cleanCode to active: $active');
    await _firestore.collection(_promosCollection).doc(cleanCode).update({
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    AppLoggerHelper.success('PremiumRepository', 'Promo code $cleanCode active status updated to $active');

    await AuditService.log(
      module: 'Premium & Payments',
      action: AuditAction.updated,
      details: '${active ? 'Activated' : 'Deactivated'} promo code $cleanCode',
    );
  }

  @override
  Future<void> deletePromo(String code) async {
    final cleanCode = code.trim().toUpperCase();
    AppLoggerHelper.info('[PremiumRepository] 🗑️ Deleting promo code $cleanCode...');
    await _firestore.collection(_promosCollection).doc(cleanCode).delete();
    AppLoggerHelper.success('PremiumRepository', 'Promo code $cleanCode deleted from Firestore');

    await AuditService.log(
      module: 'Premium & Payments',
      action: AuditAction.deleted,
      details: 'Deleted promo code $cleanCode',
    );
  }

  @override
  Future<List<Transaction>> fetchTransactions({int limit = 100}) async {
    AppLoggerHelper.info('[PremiumRepository] 💳 Querying transactions (limit: $limit)...');
    try {
      final snap = await _firestore
          .collection(_transactionsCollection)
          .orderBy('date', descending: true)
          .limit(limit)
          .get();

      final list = snap.docs
          .map((doc) => Transaction.fromMap(doc.data(), docId: doc.id))
          .toList();
      AppLoggerHelper.success('PremiumRepository', 'Fetched ${list.length} transactions');
      return list;
    } catch (e) {
      AppLoggerHelper.warning('PremiumRepository', 'Transactions ordered fetch failed, trying fallback: $e');
      try {
        final fallback = await _firestore
            .collection(_transactionsCollection)
            .limit(limit)
            .get();
        final list = fallback.docs
            .map((doc) => Transaction.fromMap(doc.data(), docId: doc.id))
            .toList();
        AppLoggerHelper.success('PremiumRepository', 'Fetched ${list.length} transactions (fallback)');
        return list;
      } catch (err, st) {
        AppLoggerHelper.failure('PremiumRepository', 'Error fetching transactions fallback: $err', error: err, stackTrace: st);
        return [];
      }
    }
  }
}
