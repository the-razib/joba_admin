import 'package:cloud_functions/cloud_functions.dart';
import 'package:joba_admin/core/services/firebase_errors.dart';
import 'package:joba_admin/core/utils/logging/logger.dart';

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
    AppLoggerHelper.info('[FunctionsService] ⚡ Calling Cloud Function "$name" with data: $data');
    try {
      final callable = _functions.httpsCallable(name);
      final result = await callable.call(data);
      AppLoggerHelper.success('FunctionsService', 'Function "$name" completed successfully');
      return result.data as T;
    } catch (e, st) {
      final message = FirebaseErrors.messageOf(e);
      AppLoggerHelper.failure('FunctionsService', 'Function "$name" failed: $message', error: e, stackTrace: st);
      throw FunctionsException(
        message,
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
