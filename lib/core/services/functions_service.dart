import 'package:cloud_functions/cloud_functions.dart';
import 'package:joba_admin/core/services/firebase_errors.dart';

/// Central wrapper for executing Firebase Cloud Functions.
///
/// Handles regional dispatch (`asia-south1`), error sanitization,
/// and type-safe payload returns.
class FunctionsService {
  final FirebaseFunctions _functions;

  FunctionsService([FirebaseFunctions? functions])
      : _functions = functions ??
            FirebaseFunctions.instanceFor(region: 'asia-south1');

  /// Calls a named Callable Cloud Function and returns the payload of type [T].
  Future<T> call<T>(String name, [Map<String, dynamic>? data]) async {
    try {
      final callable = _functions.httpsCallable(name);
      final result = await callable.call(data);
      return result.data as T;
    } catch (e) {
      throw FunctionsException(
        FirebaseErrors.messageOf(e),
        originalError: e,
      );
    }
  }
}

class FunctionsException implements Exception {
  final String message;
  final dynamic originalError;

  const FunctionsException(this.message, {this.originalError});

  @override
  String toString() => message;
}
