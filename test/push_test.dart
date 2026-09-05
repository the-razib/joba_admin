import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/push_notifications/models/push_notification.dart';
import 'package:joba_admin/core/repositories/push_repository.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/features/push_notifications/controllers/push_controller.dart';
import 'package:joba_admin/features/push_notifications/views/push_screen.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put<PushRepository>(MockPushRepository());
  });

  tearDown(Get.reset);

  /// A valid push campaign by default, so each test only states the one field
  /// it is actually about.
  PushNotification campaign({
    String titleBn = 'শিরোনাম',
    String titleEn = 'Title',
    String bodyBn = 'বার্তা',
    String bodyEn = 'Body',
    PushAudience audience = PushAudience.all,
    NotificationChannel channel = NotificationChannel.push,
    InAppLayout inAppLayout = InAppLayout.modal,
    String? imageUrl,
    String? actionLabelBn,
    String? actionLabelEn,
    String? actionUrl,
    PushStatus status = PushStatus.draft,
    int sentCount = 0,
    int failedCount = 0,
  }) => PushNotification(
    id: 'PN-TEST',
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
    status: status,
    sentCount: sentCount,
    failedCount: failedCount,
  );

  /// `Get.put` fires `onInit`, whose seed load is async; drain the queue so
  /// `all` is populated before asserting.
  Future<PushController> loaded() async {
    final c = Get.put(PushController());
    await pumpEventQueue();
    return c;
  }

  Future<void> pumpPush(
    WidgetTester tester, {
    Size size = const Size(1440, 900),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    Get.put(PushController());
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: PushScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The composer opens as an overlay above the list, so bare text finders
  /// also match the table behind it. Channel names must be scoped to the
  /// composer's own picker.
  Finder channelSegment(String label) => find.descendant(
    of: find.byType(SegmentedButton<NotificationChannel>),
    matching: find.text(label),
  );

  group('validation', () {
    test('a complete push campaign can send', () {
      final c = campaign();
      expect(c.issues, isEmpty);
      expect(c.canSend, isTrue);
    });

    test('both languages are required for the title', () {
      expect(campaign(titleEn: '').issues, hasLength(1));
      expect(campaign(titleBn: '   ').canSend, isFalse);
    });

    test('a push always needs a body', () {
      expect(campaign(bodyEn: '').canSend, isFalse);
    });

    test('an image-only in-app dialog does not need a body', () {
      final c = campaign(
        channel: NotificationChannel.inApp,
        inAppLayout: InAppLayout.imageOnly,
        bodyBn: '',
        bodyEn: '',
        imageUrl: 'https://example.com/a.png',
      );
      expect(c.issues, isEmpty);
    });

    test('an image-only layout without an image is blocked', () {
      final c = campaign(
        channel: NotificationChannel.inApp,
        inAppLayout: InAppLayout.imageOnly,
      );
      expect(c.canSend, isFalse);
      expect(c.issues.join(' '), contains('needs an image'));
    });

    test('a non-HTTPS image is blocked', () {
      // FCM drops these silently rather than erroring, so catch it here.
      final c = campaign(imageUrl: 'http://example.com/a.png');
      expect(c.issues.join(' '), contains('https://'));
      expect(campaign(imageUrl: 'gs://bucket/a.png').canSend, isFalse);
    });

    test('an action button needs both a label and a destination', () {
      expect(campaign(actionLabelEn: 'Open').canSend, isFalse);
      expect(campaign(actionUrl: 'joba://premium').canSend, isFalse);
      final ok = campaign(
        actionLabelBn: 'খুলুন',
        actionLabelEn: 'Open',
        actionUrl: 'joba://premium',
      );
      expect(ok.canSend, isTrue);
      expect(ok.hasAction, isTrue);
    });

    test('acceptance rate is zero rather than NaN with nothing attempted', () {
      expect(campaign().acceptanceRate, 0);
      expect(campaign(sentCount: 150, failedCount: 50).acceptanceRate, 75);
      expect(campaign(sentCount: 150, failedCount: 50).totalAttempted, 200);
    });

    test('copyWith preserves the English action label', () {
      // Regression: actionLabelEn was declared but never forwarded, so every
      // copyWith silently erased it — including on the dispatch path.
      final original = campaign(
        actionLabelBn: 'খুলুন',
        actionLabelEn: 'Open',
        actionUrl: 'joba://premium',
      );
      final copied = original.copyWith(status: PushStatus.sent);

      expect(copied.actionLabelEn, 'Open');
      expect(copied.actionLabelBn, 'খুলুন');
      expect(copied.actionUrl, 'joba://premium');
    });

    test('a draft map never carries delivery state', () {
      // The Cloud Function owns these; letting the panel write them would let a
      // stale edit overwrite a real dispatch result.
      final map = campaign(status: PushStatus.sent, sentCount: 99).toDraftMap();

      expect(map.containsKey('status'), isFalse);
      expect(map.containsKey('sentCount'), isFalse);
      expect(map.containsKey('failedCount'), isFalse);
      expect(map.containsKey('sentAt'), isFalse);
      expect(map.containsKey('messageId'), isFalse);
    });

    test('actionType is derived for the mobile handler', () {
      expect(campaign().toDraftMap()['actionType'], 'none');
      expect(
        campaign(
          actionLabelBn: 'খুলুন',
          actionLabelEn: 'Open',
          actionUrl: 'joba://premium',
        ).toDraftMap()['actionType'],
        'screen',
      );
    });
  });

  group('warnings', () {
    test('a long push title warns about lock-screen truncation', () {
      final c = campaign(titleEn: 'A' * (kPushTitleSoftLimit + 5));
      expect(c.canSend, isTrue, reason: 'advice, not a blocker');
      expect(c.warnings.join(' '), contains('truncates'));
    });

    test('a push image warns about the iOS extension', () {
      final c = campaign(imageUrl: 'https://example.com/a.png');
      expect(c.warnings.join(' '), contains('Notification Service Extension'));
    });

    test('an in-app-only image does not warn about iOS', () {
      // The extension only matters for OS-delivered notifications.
      final c = campaign(
        channel: NotificationChannel.inApp,
        imageUrl: 'https://example.com/a.png',
      );
      expect(c.warnings, isEmpty);
    });
  });

  group('controller', () {
    test('loads from the repository', () async {
      final c = await loaded();
      expect(c.loading.value, isFalse);
      expect(c.all, hasLength(5));
      expect(c.sentCampaignCount, 4);
      expect(c.totalAccepted, 71300);
      expect(c.totalRejected, 1420);
      expect(c.countWithImage(), 2);
      expect(c.acceptanceRate, closeTo(98.0, 0.1));
    });

    test('a dual-channel campaign is visible under both filters', () async {
      final c = await loaded();
      expect(c.visible, hasLength(5));

      c.setChannelFilter(NotificationChannel.push);
      expect(c.visible.map((p) => p.id), contains('PN-005'));
      expect(c.visible, hasLength(4));

      c.setChannelFilter(NotificationChannel.inApp);
      expect(c.visible.map((p) => p.id), contains('PN-005'));
      expect(c.visible, hasLength(2));

      c.setChannelFilter(NotificationChannel.both);
      expect(c.visible.map((p) => p.id), ['PN-005']);

      c.setChannelFilter(null);
      expect(c.visible, hasLength(5));
    });

    test('sending a draft records what the dispatch accepted', () async {
      final c = await loaded();
      final draft = c.all.firstWhere((p) => p.id == 'PN-001');
      expect(draft.status, PushStatus.draft);

      final result = await c.sendDraft('PN-001');

      final sent = c.all.firstWhere((p) => p.id == 'PN-001');
      expect(sent.status, PushStatus.sent);
      expect(result, isNotNull);
      // bangladesh audience: 1800 targeted, 2% rejected.
      expect(result!.targeted, 1800);
      expect(sent.sentCount, 1764);
      expect(sent.failedCount, 36);
      expect(sent.sentAt, isNotNull);
      expect(c.sentCampaignCount, 5);
    });

    test('a campaign in flight cannot be dispatched twice', () async {
      final c = await loaded();
      c.dispatching.add('PN-001');

      expect(await c.sendDraft('PN-001'), isNull);
      expect(await c.resend('PN-001'), isNull);
    });

    test('an invalid draft is refused even from the controller', () async {
      final c = await loaded();
      final bad = c.draft(
        titleBn: 'শিরোনাম',
        titleEn: '',
        bodyBn: 'বার্তা',
        bodyEn: 'Body',
        audience: PushAudience.all,
        channel: NotificationChannel.push,
        inAppLayout: InAppLayout.modal,
      );
      await c.save(bad, send: true);

      // Saved as a draft, but never dispatched.
      expect(c.all, hasLength(6));
      expect(c.all.first.titleEn, '');
      expect(c.all.first.status, PushStatus.draft);
      expect(c.all.first.sentCount, 0);
    });

    test('save inserts a new campaign and replaces an existing one', () async {
      final c = await loaded();
      final fresh = c.draft(
        titleBn: 'নতুন',
        titleEn: 'Fresh',
        bodyBn: 'বার্তা',
        bodyEn: 'Body',
        audience: PushAudience.all,
        channel: NotificationChannel.both,
        inAppLayout: InAppLayout.card,
      );

      await c.save(fresh, send: false);
      expect(c.all, hasLength(6));
      expect(c.all.first.titleEn, 'Fresh');

      // A new campaign gets its id from the backend, not the client.
      final assignedId = c.all.first.id;
      expect(assignedId, isNotEmpty);

      await c.save(
        c.all.first.copyWith(titleEn: 'Edited'),
        send: false,
      );
      expect(c.all, hasLength(6), reason: 'replaced, not appended');
      expect(c.all.firstWhere((p) => p.id == assignedId).titleEn, 'Edited');
    });

    test('resend overwrites the previous dispatch result', () async {
      final c = await loaded();
      await c.resend('PN-003');

      // Each dispatch reports its own outcome; counts are replaced, not summed,
      // which is what the Cloud Function does.
      final campaign = c.all.firstWhere((p) => p.id == 'PN-003');
      expect(campaign.sentCount, 1470, reason: 'free audience: 1500 - 2%');
      expect(campaign.failedCount, 30);
    });

    test('remove drops the campaign', () async {
      final c = await loaded();
      await c.remove('PN-002');
      expect(c.all, hasLength(4));
      expect(c.all.map((p) => p.id), isNot(contains('PN-002')));
    });
  });

  group('screen', () {
    testWidgets('renders the header, stats and campaigns', (tester) async {
      await pumpPush(tester);

      expect(find.text('Push Notifications'), findsWidgets);
      expect(find.text('Campaigns Sent'), findsOneWidget);
      expect(find.text('Acceptance Rate'), findsWidgets);
      expect(find.text('Your period is approaching'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('channel chips filter the table', (tester) async {
      await pumpPush(tester);

      await tester.tap(find.widgetWithText(ChoiceChip, 'In-App'));
      await tester.pumpAndSettle();

      // PN-002 is in-app only, PN-004 is push only.
      expect(find.text('Premium offer inside'), findsOneWidget);
      expect(find.text('Your period is approaching'), findsNothing);

      await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
      await tester.pumpAndSettle();
      expect(find.text('Your period is approaching'), findsOneWidget);
    });

    testWidgets('empty channel shows a placeholder', (tester) async {
      await pumpPush(tester);
      Get.find<PushController>().all.clear();
      await tester.pumpAndSettle();

      expect(
        find.text('No notifications on this channel yet.'),
        findsOneWidget,
      );
    });

    for (final (label, size) in const [
      ('phone', Size(390, 844)),
      ('tablet', Size(834, 1112)),
      ('desktop', Size(1440, 900)),
    ]) {
      testWidgets('lays out without overflow on $label', (tester) async {
        await pumpPush(tester, size: size);
        expect(find.text('Push Notifications'), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('composer', () {
    testWidgets('opens with the push channel selected', (tester) async {
      await pumpPush(tester);

      await tester.tap(find.text('New Notification'));
      await tester.pumpAndSettle();

      expect(find.text('Delivery channel'), findsOneWidget);
      expect(find.text('Title *'), findsOneWidget);
      expect(find.text('Image (optional)'), findsOneWidget);
      // The composer's audience chips use the lowercase enum name; the table
      // behind uppercases it.
      expect(find.widgetWithText(ChoiceChip, 'bangladesh'), findsOneWidget);
      // Layout only matters once in-app is in play.
      expect(find.text('In-app layout'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('choosing in-app reveals the layout picker', (tester) async {
      await pumpPush(tester);
      await tester.tap(find.text('New Notification'));
      await tester.pumpAndSettle();

      await tester.tap(channelSegment('In-App'));
      await tester.pumpAndSettle();

      expect(find.text('In-app layout'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Image only'), findsOneWidget);
    });

    testWidgets('an empty composer cannot send', (tester) async {
      await pumpPush(tester);
      await tester.tap(find.text('New Notification'));
      await tester.pumpAndSettle();

      final send = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Send Now'),
      );
      expect(send.onPressed, isNull);
      expect(find.text('Fix before sending'), findsOneWidget);
    });

    testWidgets('dialog layout is active and other layouts are locked', (
      tester,
    ) async {
      await pumpPush(tester);
      await tester.tap(find.text('New Notification'));
      await tester.pumpAndSettle();

      await tester.tap(channelSegment('In-App'));
      await tester.pumpAndSettle();

      expect(find.text('In-app layout'), findsOneWidget);
      expect(find.text('Dialog only'), findsOneWidget);

      final dialogChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Dialog'),
      );
      expect(dialogChip.selected, isTrue);

      final imageOnlyChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Image only'),
      );
      expect(imageOnlyChip.onSelected, isNull);

      final cardChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Card'),
      );
      expect(cardChip.onSelected, isNull);

      final bannerChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Banner'),
      );
      expect(bannerChip.onSelected, isNull);
    });

    testWidgets('the action is labelled Publish for in-app only', (
      tester,
    ) async {
      await pumpPush(tester);
      await tester.tap(find.text('New Notification'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ElevatedButton, 'Send Now'), findsOneWidget);

      await tester.tap(channelSegment('In-App'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ElevatedButton, 'Publish'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Send Now'), findsNothing);

      // Push + In-App still reaches devices, so it stays "Send Now".
      await tester.tap(channelSegment('Push + In-App'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ElevatedButton, 'Send Now'), findsOneWidget);
    });
  });
}
