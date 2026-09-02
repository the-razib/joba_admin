import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:joba_admin/core/repositories/screener_repository.dart';
import 'package:joba_admin/core/services/audit_service.dart';
import 'package:joba_admin/core/services/storage_service.dart';
import 'package:joba_admin/features/audit_logs/models/audit_log.dart';
import 'package:joba_admin/features/disease_checkup/models/screener_admin_model.dart';

/// Firebase Firestore + Storage implementation of [ScreenerRepository].
///
/// Communicates with the shared Firestore collection `screeners/{screenerId}`
/// and uploads cover graphics to Firebase Storage.
class FirebaseScreenerRepository implements ScreenerRepository {
  final FirebaseFirestore _firestore;
  final StorageService _storageService;

  FirebaseScreenerRepository({
    FirebaseFirestore? firestore,
    StorageService? storageService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storageService = storageService ?? StorageService();

  static const String _collection = 'screeners';

  @override
  Future<List<ScreenerAdminModel>> getScreeners() async {
    try {
      final snap = await _firestore
          .collection(_collection)
          .orderBy('displayOrder')
          .get();

      if (snap.docs.isEmpty) {
        debugPrint(
          'ℹ️ [FirebaseScreenerRepository] Empty collection, auto-seeding clinical screeners...',
        );
        await _autoSeedInitialScreeners();
        final seededSnap = await _firestore
            .collection(_collection)
            .orderBy('displayOrder')
            .get();
        return seededSnap.docs
            .map((doc) => ScreenerAdminModel.fromMap(doc.data(), doc.id))
            .toList();
      }

      return snap.docs
          .map((doc) => ScreenerAdminModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('⚠️ [FirebaseScreenerRepository] getScreeners failed: $e');
      // Fallback query without orderBy if index is building
      try {
        final fallbackSnap = await _firestore.collection(_collection).get();
        if (fallbackSnap.docs.isNotEmpty) {
          final list = fallbackSnap.docs
              .map((doc) => ScreenerAdminModel.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
          return list;
        }
      } catch (_) {}
      rethrow;
    }
  }

  /// Automatically seeds initial clinical screeners into Firestore if the collection is empty.
  Future<void> _autoSeedInitialScreeners() async {
    final batch = _firestore.batch();
    final seeds = MockScreenerRepository.initialClinicalScreeners;
    for (final screener in seeds) {
      final docRef = _firestore.collection(_collection).doc(screener.id);
      final map = screener.toMap();
      map['createdAt'] = FieldValue.serverTimestamp();
      map['updatedAt'] = FieldValue.serverTimestamp();
      batch.set(docRef, map);
    }
    await batch.commit();
    debugPrint(
      '✅ [FirebaseScreenerRepository] Successfully seeded ${seeds.length} clinical screeners to Firestore.',
    );
  }

  @override
  Future<ScreenerAdminModel?> getScreenerById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return ScreenerAdminModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      debugPrint('❌ [FirebaseScreenerRepository] getScreenerById($id) failed: $e');
      return null;
    }
  }

  @override
  Future<ScreenerAdminModel> createScreener(
    ScreenerAdminModel screener, {
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    var finalScreener = screener;

    // Upload cover image to storage if provided
    if (imageBytes != null && imageBytes.isNotEmpty) {
      final ext = imageName?.split('.').last ?? 'jpg';
      final downloadUrl = await _storageService.uploadBytes(
        folder: 'screeners/${screener.id}',
        name: imageName ?? 'cover.jpg',
        bytes: imageBytes,
        contentType: 'image/$ext',
      );
      finalScreener = finalScreener.copyWith(imagePath: downloadUrl);
    }

    final data = finalScreener.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore.collection(_collection).doc(finalScreener.id).set(data);

    await AuditService.log(
      module: 'Disease Checkup',
      action: AuditAction.created,
      details:
          'Created screener "${finalScreener.nameEn}" (${finalScreener.id})',
    );

    return finalScreener;
  }

  @override
  Future<ScreenerAdminModel> updateScreener(
    ScreenerAdminModel screener, {
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    var finalScreener = screener;

    // Upload new image if provided
    if (imageBytes != null && imageBytes.isNotEmpty) {
      final ext = imageName?.split('.').last ?? 'jpg';
      final downloadUrl = await _storageService.uploadBytes(
        folder: 'screeners/${screener.id}',
        name: imageName ?? 'cover.jpg',
        bytes: imageBytes,
        contentType: 'image/$ext',
      );
      finalScreener = finalScreener.copyWith(imagePath: downloadUrl);
    }

    final data = finalScreener.toMap();
    data['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore
        .collection(_collection)
        .doc(finalScreener.id)
        .set(data, SetOptions(merge: true));

    await AuditService.log(
      module: 'Disease Checkup',
      action: AuditAction.updated,
      details:
          'Updated screener "${finalScreener.nameEn}" (${finalScreener.id})',
    );

    return finalScreener;
  }

  @override
  Future<bool> deleteScreener(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();

      // Clean up storage assets under screeners/$id
      try {
        await _storageService.deleteFolder('screeners/$id');
      } catch (e) {
        debugPrint('Storage cleanup for screener $id non-fatal: $e');
      }

      await AuditService.log(
        module: 'Disease Checkup',
        action: AuditAction.deleted,
        details: 'Deleted screener ID: $id',
      );

      return true;
    } catch (e) {
      debugPrint('❌ [FirebaseScreenerRepository] deleteScreener($id) failed: $e');
      return false;
    }
  }

  @override
  Future<bool> toggleScreenerActive(String id, bool enabled) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'enabled': enabled,
        'isActive': enabled,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await AuditService.log(
        module: 'Disease Checkup',
        action: AuditAction.updated,
        details: '${enabled ? 'Enabled' : 'Disabled'} screener ID: $id',
      );

      return true;
    } catch (e) {
      debugPrint(
        '❌ [FirebaseScreenerRepository] toggleScreenerActive($id) failed: $e',
      );
      return false;
    }
  }

  @override
  Future<void> updateScreenersOrder(List<ScreenerAdminModel> screeners) async {
    try {
      final batch = _firestore.batch();
      for (int i = 0; i < screeners.length; i++) {
        final docRef = _firestore.collection(_collection).doc(screeners[i].id);
        batch.update(docRef, {
          'displayOrder': i + 1,
          'order': i + 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();

      await AuditService.log(
        module: 'Disease Checkup',
        action: AuditAction.updated,
        details: 'Reordered ${screeners.length} screeners display order',
      );
    } catch (e) {
      debugPrint(
        '❌ [FirebaseScreenerRepository] updateScreenersOrder failed: $e',
      );
    }
  }
}
