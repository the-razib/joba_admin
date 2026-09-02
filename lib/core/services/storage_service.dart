import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/// Central Firebase Storage Service for asset and media uploads.
///
/// Follows structured path conventions: `{folder}/{yyyy-MM}/{uuid}_{sanitized_name}`
class StorageService {
  final FirebaseStorage? _storage;

  StorageService([FirebaseStorage? storage]) : _storage = storage;

  FirebaseStorage get storage => _storage ?? FirebaseStorage.instance;

  /// Uploads binary data and returns the public download URL.
  Future<String> uploadBytes({
    required String folder,
    required String name,
    required Uint8List bytes,
    String? contentType,
  }) async {
    final now = DateTime.now();
    final yearMonth =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final sanitizedName = name
        .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')
        .toLowerCase();
    final uniqueId = const Uuid().v4().substring(0, 8);

    final path = '$folder/$yearMonth/${uniqueId}_$sanitizedName';
    final ref = storage.ref().child(path);

    final metadata = SettableMetadata(
      contentType: contentType ?? _inferContentType(sanitizedName),
      customMetadata: {
        'uploadedAt': now.toIso8601String(),
        'originalName': name,
      },
    );

    final uploadTask = await ref.putData(bytes, metadata);
    return await uploadTask.ref.getDownloadURL();
  }

  /// Deletes a file from Storage by its download URL or reference path.
  Future<void> deleteFile(String urlOrPath) async {
    try {
      if (urlOrPath.startsWith('http')) {
        final ref = storage.refFromURL(urlOrPath);
        await ref.delete();
      } else {
        final ref = storage.ref().child(urlOrPath);
        await ref.delete();
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [StorageService] Delete file warning: $e');
      }
    }
  }

  /// Deletes an entire folder and all nested files/subfolders recursively from Storage.
  Future<void> deleteFolder(String folderPath) async {
    try {
      final ref = storage.ref().child(folderPath);
      await _deleteFolderRecursively(ref);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [StorageService] Delete folder warning ($folderPath): $e');
      }
    }
  }

  Future<void> _deleteFolderRecursively(Reference ref) async {
    try {
      final listResult = await ref.listAll();
      for (final item in listResult.items) {
        try {
          await item.delete();
        } catch (_) {}
      }
      for (final prefix in listResult.prefixes) {
        await _deleteFolderRecursively(prefix);
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [StorageService] Recursive delete warning: $e');
      }
    }
  }

  String _inferContentType(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    return switch (ext) {
      'png' => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      'webp' => 'image/webp',
      'svg' => 'image/svg+xml',
      'mp3' => 'audio/mpeg',
      'wav' => 'audio/wav',
      'm4a' => 'audio/mp4',
      'json' => 'application/json',
      _ => 'application/octet-stream',
    };
  }
}
