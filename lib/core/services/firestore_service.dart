import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Central Firestore and Firebase Services Access Point for Joba Admin.
///
/// Configured for an online-only administration panel:
/// - In-memory cache only (bounded to 20MB)
/// - No local offline persistence (always fetches fresh data from server)
/// - Supports optional local emulator routing when USE_EMULATORS=true
class FirestoreService {
  FirestoreService._();

  static FirebaseFirestore get db => FirebaseFirestore.instance;

  static const bool useEmulators =
      bool.fromEnvironment('USE_EMULATORS', defaultValue: false);

  /// Configures Firestore cache and optional local emulators.
  static void configure() {
    db.settings = const Settings(
      persistenceEnabled: false,
      cacheSizeBytes: 20 * 1024 * 1024, // 20 MB in-memory cache
    );

    if (useEmulators) {
      if (kDebugMode) {
        print('⚡ [FirestoreService] Connecting to local Firebase Emulators...');
      }
      try {
        db.useFirestoreEmulator('localhost', 8080);
        FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
        FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
        FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ [FirestoreService] Emulator connection error: $e');
        }
      }
    }
  }
}
