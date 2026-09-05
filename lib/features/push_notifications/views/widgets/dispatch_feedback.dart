import 'package:joba_admin/core/repositories/push_repository.dart';
import 'package:joba_admin/core/utils/app_toast.dart';

/// Report a real dispatch outcome to the admin.
///
/// Every send path routes through here so the wording cannot drift between the
/// table, the detail panel and the composer — and so the three cases that used
/// to be reported identically are now distinguished:
///  - the callable failed outright,
///  - the audience matched no devices,
///  - the message was accepted for N devices.
///
/// [failureReason] is the controller's `lastError`. It is shown verbatim because
/// the actual cause matters: an undeployed `adminSendPush`, a missing role claim
/// and a Firestore rule rejection all leave the campaign as a draft, and a
/// generic "could not send" gives the admin nothing to act on.
void reportDispatch(
  DispatchResult? result, {
  bool resend = false,
  String? failureReason,
}) {
  final verb = resend ? 'Resent' : 'Sent';

  if (result == null) {
    AppToast.error(
      'Not sent',
      failureReason ??
          'The campaign could not be dispatched. It is still saved as a draft.',
    );
    return;
  }

  if (result.error != null) {
    AppToast.error('Dispatch failed', result.error!);
    return;
  }

  if (result.isPublish) {
    // Nothing was pushed, and saying "sent to 0 devices" would read as a
    // failure. An in-app campaign appears the next time each user opens the app.
    AppToast.success(
      resend ? 'Republished' : 'Published',
      'This in-app campaign will appear the next time users open the app.',
    );
    return;
  }

  if (result.reachedNobody) {
    // Silence here would read as success. An empty audience is the single most
    // likely surprise, especially for `premium` before premium ships.
    AppToast.warning(
      'Reached no devices',
      'No registered devices matched '
          '${result.audienceLabel ?? 'this audience'}. Nothing was sent.',
    );
    return;
  }

  final detail = StringBuffer('Accepted by FCM for ${result.accepted} device')
    ..write(result.accepted == 1 ? '' : 's');
  if (result.rejected > 0) {
    detail.write(', ${result.rejected} rejected');
  }
  detail.write('.');

  AppToast.success(verb, detail.toString());
}
