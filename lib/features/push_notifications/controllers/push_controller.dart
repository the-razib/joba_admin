import 'package:get/get.dart';
import 'package:joba_admin/core/models/push_notification.dart';
import 'package:joba_admin/core/repositories/push_repository.dart';
import 'package:uuid/uuid.dart';

class PushController extends GetxController {
  final PushRepository repo = Get.find();

  final all = <PushNotification>[].obs;
  final loading = true.obs;

  /// `null` = no channel filter.
  final channelFilter = Rxn<NotificationChannel>();

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    loading.value = true;
    all.assignAll(await repo.seed());
    loading.value = false;
  }

  void setChannelFilter(NotificationChannel? c) => channelFilter.value = c;

  /// A campaign sent to `both` belongs in the Push list and the In-App list,
  /// so filtering matches on capability rather than equality.
  List<PushNotification> get visible {
    final f = channelFilter.value;
    if (f == null) return all.toList();
    return all.where((p) {
      return switch (f) {
        NotificationChannel.push => p.channel.hasPush,
        NotificationChannel.inApp => p.channel.hasInApp,
        NotificationChannel.both => p.channel == NotificationChannel.both,
      };
    }).toList();
  }

  List<PushNotification> get sent =>
      all.where((p) => p.status == PushStatus.sent).toList();

  int get sentCount => sent.length;

  int get totalDelivered => sent.fold(0, (a, p) => a + p.delivered);

  int get totalOpened => sent.fold(0, (a, p) => a + p.opened);

  double get openRate =>
      totalDelivered == 0 ? 0 : totalOpened / totalDelivered * 100;

  int countWithImage() => all.where((p) => p.hasImage).length;

  void remove(String id) => all.removeWhere((p) => p.id == id);

  Future<void> sendDraft(String id) async {
    final i = all.indexWhere((p) => p.id == id);
    if (i < 0) return;
    // Guard here as well as in the UI: the detail panel's Send button is
    // reachable for drafts saved before a validation rule existed.
    if (!all[i].canSend) return;
    final result = await repo.dispatch(all[i]);
    all[i] = all[i].copyWith(
      status: PushStatus.sent,
      sentAt: DateTime.now(),
      delivered: result.accepted,
      opened: 0,
    );
  }

  Future<void> resend(String id) async {
    final i = all.indexWhere((p) => p.id == id);
    if (i < 0) return;
    final p = all[i];
    final result = await repo.dispatch(p);
    all[i] = p.copyWith(
      sentAt: DateTime.now(),
      delivered: p.delivered + result.accepted,
    );
  }

  Future<void> save(PushNotification n, {required bool send}) async {
    final i = all.indexWhere((p) => p.id == n.id);
    if (i >= 0) {
      all[i] = n;
    } else {
      all.insert(0, n);
    }
    if (!send) return;
    await sendDraft(n.id);
  }

  PushNotification draft({
    required String titleBn,
    required String titleEn,
    required String bodyBn,
    required String bodyEn,
    required PushAudience audience,
    required NotificationChannel channel,
    required InAppLayout inAppLayout,
    String? id,
    String? imageUrl,
    String? actionLabelBn,
    String? actionLabelEn,
    String? actionUrl,
  }) => PushNotification(
    id: id ?? 'PN-${const Uuid().v4().substring(0, 4)}',
    titleBn: titleBn,
    titleEn: titleEn,
    bodyBn: bodyBn,
    bodyEn: bodyEn,
    audience: audience,
    channel: channel,
    inAppLayout: inAppLayout,
    imageUrl: imageUrl,
    actionLabelBn: actionLabelBn,
    actionLabelEn: actionLabelEn,
    actionUrl: actionUrl,
  );
}
