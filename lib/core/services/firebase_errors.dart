import 'package:firebase_core/firebase_core.dart';

/// Centralized human-readable error mapper for Firebase operations across all modules.
class FirebaseErrors {
  FirebaseErrors._();

  /// Maps any exception/error into a clean user-facing error message.
  static String messageOf(dynamic error) {
    if (error is FirebaseException) {
      return switch (error.code) {
        'permission-denied' =>
          'Permission denied. Your role may lack authorization for this action.',
        'not-found' => 'Requested document or item could not be found.',
        'already-exists' => 'An item with this identifier already exists.',
        'resource-exhausted' =>
          'Quota exceeded or rate limit reached. Please try again later.',
        'failed-precondition' =>
          'Operation rejected by database constraints or missing index.',
        'unavailable' =>
          'Service temporarily unavailable. Please verify network connection.',
        'unauthenticated' =>
          'Your session has expired. Please sign in again.',
        'cancelled' => 'Operation was cancelled.',
        'deadline-exceeded' => 'Request timed out. Please try again.',
        _ => error.message ?? 'A Firebase error occurred (${error.code}).',
      };
    }

    return error?.toString() ?? 'An unexpected error occurred.';
  }
}
