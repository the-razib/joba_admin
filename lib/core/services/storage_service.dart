import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:joba_admin/core/utils/logging/logger.dart';
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
    AppLoggerHelper.info('[StorageService] 📤 Uploading $name (${bytes.length} bytes) to $path');
    final ref = storage.ref().child(path);

    final metadata = SettableMetadata(
      contentType: contentType ?? _inferContentType(sanitizedName),
      customMetadata: {
        'uploadedAt': now.toIso8601String(),
        'originalName': name,
      },
    );

    final uploadTask = await ref.putData(bytes, metadata);
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    AppLoggerHelper.success('StorageService', 'Uploaded $name -> $downloadUrl');
    return downloadUrl;
  }

  /// Uploads binary data to an explicit full path and returns the download URL.
  Future<String> uploadBytesToPath({
    required String fullPath,
    required Uint8List bytes,
    String? contentType,
  }) async {
    AppLoggerHelper.info('[StorageService] 📤 Uploading (${bytes.length} bytes) to $fullPath');
    final ref = storage.ref().child(fullPath);
    final metadata = SettableMetadata(
      contentType: contentType ?? _inferContentType(fullPath),
      customMetadata: {
        'uploadedAt': DateTime.now().toIso8601String(),
      },
    );
    final uploadTask = await ref.putData(bytes, metadata);
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    AppLoggerHelper.success('StorageService', 'Uploaded to $fullPath -> $downloadUrl');
    return downloadUrl;
  }

  /// Deletes a file from Storage by its download URL or reference path.
  Future<void> deleteFile(String urlOrPath) async {
    try {
      AppLoggerHelper.info('[StorageService] 🗑️ Deleting file: $urlOrPath');
      if (urlOrPath.startsWith('http')) {
        try {
          final ref = storage.refFromURL(urlOrPath);
          await ref.delete();
          AppLoggerHelper.success('StorageService', 'File deleted successfully via refFromURL: $urlOrPath');
          return;
        } catch (e) {
          AppLoggerHelper.warning('[StorageService] refFromURL failed ($e), trying path extraction fallback...');
          final uri = Uri.tryParse(urlOrPath);
          if (uri != null && uri.path.contains('/o/')) {
            final rawPath = uri.path.split('/o/').last;
            final decodedPath = Uri.decodeComponent(rawPath);
            final ref = storage.ref().child(decodedPath);
            await ref.delete();
            AppLoggerHelper.success('StorageService', 'File deleted successfully via path fallback: $decodedPath');
            return;
          }
        }
      } else {
        final ref = storage.ref().child(urlOrPath);
        await ref.delete();
        AppLoggerHelper.success('StorageService', 'File deleted successfully: $urlOrPath');
      }
    } catch (e) {
      AppLoggerHelper.warning('[StorageService] Delete file warning: $e');
    }
  }

  /// Deletes an entire folder and all nested files/subfolders recursively from Storage.
  Future<void> deleteFolder(String folderPath) async {
    try {
      AppLoggerHelper.info('[StorageService] 🗑️ Deleting folder: $folderPath');
      final ref = storage.ref().child(folderPath);
      await _deleteFolderRecursively(ref);
      AppLoggerHelper.success('StorageService', 'Folder deleted successfully: $folderPath');
    } catch (e) {
      AppLoggerHelper.warning('[StorageService] Delete folder warning ($folderPath): $e');
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
      AppLoggerHelper.warning('[StorageService] Recursive delete warning: $e');
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
