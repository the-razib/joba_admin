import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:joba_admin/core/repositories/avatar_repository.dart';
import 'package:joba_admin/core/services/storage_service.dart';
import 'package:joba_admin/features/avatars/models/avatar_item.dart';
import 'package:uuid/uuid.dart';

/// Firebase Firestore + Storage implementation of [AvatarRepository].
///
/// Syncs preset avatar categories and image assets in real time with the mobile client.
class FirebaseAvatarRepository implements AvatarRepository {
  final FirebaseFirestore _firestore;
  final StorageService _storageService;

  FirebaseAvatarRepository({
    FirebaseFirestore? firestore,
    StorageService? storageService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storageService = storageService ?? StorageService();

  static const String _categoriesCollection = 'avatar_categories';
  static const String _avatarsCollection = 'avatars';

  static const String _storageBucket = 'joba-a913b.firebasestorage.app';
  static const String _storageBase =
      'https://firebasestorage.googleapis.com/v0/b/$_storageBucket/o/avatars%2Fpresets';

  static String _presetUrl(String category, String filename) =>
      '$_storageBase%2F$category%2F$filename?alt=media';

  @override
  Future<List<AvatarCategory>> seedCategories() async {
    return getCategories();
  }

  @override
  Future<List<AvatarCategory>> getCategories() async {
    final snap = await _firestore
        .collection(_categoriesCollection)
        .orderBy('order')
        .get();

    if (snap.docs.isEmpty) {
      await _seedInitialPacks();
      final freshSnap = await _firestore
          .collection(_categoriesCollection)
          .orderBy('order')
          .get();
      return freshSnap.docs
          .map((doc) => AvatarCategory.fromMap(doc.data(), docId: doc.id))
          .toList();
    }

    return snap.docs
        .map((doc) => AvatarCategory.fromMap(doc.data(), docId: doc.id))
        .toList();
  }

  @override
  Future<void> addCategory(String name) async {
    final id = name.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    if (id.isEmpty) return;

    final existing =
        await _firestore.collection(_categoriesCollection).doc(id).get();
    if (existing.exists) return;

    final countSnap =
        await _firestore.collection(_categoriesCollection).get();
    final newOrder = countSnap.size;

    await _firestore.collection(_categoriesCollection).doc(id).set({
      'id': id,
      'name': name.trim(),
      'order': newOrder,
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> toggleCategory(String id) async {
    final docRef = _firestore.collection(_categoriesCollection).doc(id);
    final snap = await docRef.get();
    if (!snap.exists) return;
    final current = snap.data()?['active'] as bool? ?? true;
    await docRef.update({'active': !current});
  }

  @override
  Future<void> deleteCategory(String id) async {
    final batch = _firestore.batch();
    batch.delete(_firestore.collection(_categoriesCollection).doc(id));

    final avatarsSnap = await _firestore
        .collection(_avatarsCollection)
        .where('categoryId', isEqualTo: id)
        .get();

    for (final doc in avatarsSnap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  Future<List<AvatarItem>> getAvatars({
    String? categoryId,
    bool activeOnly = false,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection(_avatarsCollection);

    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }
    if (activeOnly) {
      query = query.where('active', isEqualTo: true);
    }

    final snap = await query.orderBy('order').get();

    if (snap.docs.isEmpty && (categoryId == null || categoryId == 'modern')) {
      final allSnap =
          await _firestore.collection(_avatarsCollection).limit(1).get();
      if (allSnap.docs.isEmpty) {
        await _seedInitialPacks();
        return getAvatars(categoryId: categoryId, activeOnly: activeOnly);
      }
    }

    return snap.docs
        .map((doc) => AvatarItem.fromMap(doc.data(), docId: doc.id))
        .toList();
  }

  @override
  Future<void> uploadAvatars(
    String categoryId,
    List<AvatarUploadItem> items,
  ) async {
    final existingSnap = await _firestore
        .collection(_avatarsCollection)
        .where('categoryId', isEqualTo: categoryId)
        .get();
    var currentOrder = existingSnap.size;

    for (final item in items) {
      final extension = item.filename.contains('.')
          ? item.filename.split('.').last.toLowerCase()
          : 'png';
      final storagePath =
          'avatars/presets/$categoryId/${const Uuid().v4()}_${item.filename}';

      final downloadUrl = await _storageService.uploadBytes(
        folder: 'avatars/presets/$categoryId',
        name: item.filename,
        bytes: Uint8List.fromList(item.bytes),
        contentType: extension == 'jpg' || extension == 'jpeg'
            ? 'image/jpeg'
            : extension == 'webp'
                ? 'image/webp'
                : 'image/png',
      );

      final docId = item.id.isNotEmpty ? item.id : const Uuid().v4();
      await _firestore.collection(_avatarsCollection).doc(docId).set({
        'id': docId,
        'categoryId': categoryId,
        'imageUrl': downloadUrl,
        'assetPath': downloadUrl,
        'storagePath': storagePath,
        'order': currentOrder++,
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<void> toggleAvatar(String id) async {
    final docRef = _firestore.collection(_avatarsCollection).doc(id);
    final snap = await docRef.get();
    if (!snap.exists) return;
    final current = snap.data()?['active'] as bool? ?? true;
    await docRef.update({'active': !current});
  }

  @override
  Future<void> deleteAvatar(String id) async {
    final docRef = _firestore.collection(_avatarsCollection).doc(id);
    final snap = await docRef.get();
    if (!snap.exists) return;

    final storagePath = snap.data()?['storagePath'] as String?;
    if (storagePath != null && storagePath.isNotEmpty) {
      try {
        await _storageService.deleteFile(storagePath);
      } catch (_) {
        // Best-effort delete
      }
    }

    await docRef.delete();
  }

  /// Initial migration / seed helper:
  /// Populates the 4 categories and all 34 live preset avatar documents.
  Future<void> _seedInitialPacks() async {
    final batch = _firestore.batch();

    final categories = [
      {'id': 'modern', 'name': 'Modern', 'order': 0, 'active': true},
      {'id': 'simple', 'name': 'Simple', 'order': 1, 'active': true},
      {'id': 'hijab', 'name': 'Hijab', 'order': 2, 'active': true},
      {'id': 'animal', 'name': 'Animal', 'order': 3, 'active': true},
    ];

    for (final cat in categories) {
      final doc =
          _firestore.collection(_categoriesCollection).doc(cat['id'] as String);
      batch.set(doc, {
        ...cat,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    final avatarPacks = <String, List<String>>{
      'modern': List.generate(
        10,
        (i) => 'modern_avatar_${(i + 1).toString().padLeft(2, '0')}.png',
      ),
      'simple': List.generate(
        13,
        (i) => 'simple_avatar_${(i + 1).toString().padLeft(2, '0')}.png',
      ),
      'hijab': List.generate(
        9,
        (i) => 'hijab_avatar_${(i + 1).toString().padLeft(2, '0')}.png',
      ),
      'animal': List.generate(
        2,
        (i) => 'animal_avatar_${(i + 1).toString().padLeft(2, '0')}.png',
      ),
    };

    avatarPacks.forEach((category, filenames) {
      for (var i = 0; i < filenames.length; i++) {
        final filename = filenames[i];
        final id = filename.replaceAll('.png', '');
        final url = _presetUrl(category, filename);

        final doc = _firestore.collection(_avatarsCollection).doc(id);
        batch.set(doc, {
          'id': id,
          'categoryId': category,
          'imageUrl': url,
          'assetPath': url,
          'storagePath': 'avatars/presets/$category/$filename',
          'order': i,
          'active': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    });

    await batch.commit();
  }

  // Legacy implementations
  @override
  Future<List<AvatarItem>> fetchAvatars(String categoryId) =>
      getAvatars(categoryId: categoryId);

  @override
  Future<void> createCategory(AvatarCategory category) =>
      addCategory(category.name);

  @override
  Future<void> updateCategory(AvatarCategory category) =>
      toggleCategory(category.id);

  @override
  Future<void> saveAvatar(AvatarItem avatar) =>
      toggleAvatar(avatar.id);
}
