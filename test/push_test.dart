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
    int delivered = 0,
    int opened = 0,
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
    delivered: delivered,
    opened: opened,
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

    test('open rate is zero rather than NaN with nothing delivered', () {
      expect(campaign().openRate, 0);
      expect(campaign(delivered: 200, opened: 50).openRate, 25);
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
    test('seeds from the repository', () async {
      final c = await loaded();
      expect(c.loading.value, isFalse);
      expect(c.all, hasLength(5));
      expect(c.sentCount, 4);
      expect(c.totalDelivered, 71300);
      expect(c.totalOpened, 35940);
      expect(c.countWithImage(), 2);
      expect(c.openRate, closeTo(50.4, 0.1));
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

      await c.sendDraft('PN-001');

      final sent = c.all.firstWhere((p) => p.id == 'PN-001');
      expect(sent.status, PushStatus.sent);
      expect(sent.delivered, 18000, reason: 'bangladesh audience');
      expect(sent.sentAt, isNotNull);
      expect(c.sentCount, 5);
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

      expect(c.all.first.id, bad.id);
      expect(c.all.first.status, PushStatus.draft);
      expect(c.all.first.delivered, 0);
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
      expect(c.all.first.id, fresh.id);

      await c.save(fresh.copyWith(titleEn: 'Edited'), send: false);
      expect(c.all, hasLength(6), reason: 'replaced, not appended');
      expect(c.all.first.titleEn, 'Edited');
    });

    test('resend adds to the delivered total', () async {
      final c = await loaded();
      await c.resend('PN-003');
      // 15200 seeded + 15000 accepted for the free audience.
      expect(c.all.firstWhere((p) => p.id == 'PN-003').delivered, 30200);
    });

    test('remove drops the campaign', () async {
      final c = await loaded();
      c.remove('PN-002');
      expect(c.all, hasLength(4));
      expect(c.all.map((p) => p.id), isNot(contains('PN-002')));
    });
  });

  group('screen', () {
    testWidgets('renders the header, stats and campaigns', (tester) async {
      await pumpPush(tester);

      expect(find.text('Push Notifications'), findsWidgets);
      expect(find.text('Total Sent'), findsOneWidget);
      expect(find.text('Open Rate'), findsWidgets);
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

    testWidgets('image-only without an image blocks sending', (tester) async {
      await pumpPush(tester);
      await tester.tap(find.text('New Notification'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'শিরোনাম');
      await tester.enterText(find.byType(TextField).at(1), 'Title');
      await tester.enterText(find.byType(TextField).at(2), 'বার্তা');
      await tester.enterText(find.byType(TextField).at(3), 'Body');
      await tester.pumpAndSettle();

      var send = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Send Now'),
      );
      expect(send.onPressed, isNotNull, reason: 'a valid push is sendable');

      await tester.tap(channelSegment('In-App'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, 'Image only'));
      await tester.pumpAndSettle();

      expect(find.text('Image *'), findsOneWidget);
      send = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Send Now'),
      );
      expect(send.onPressed, isNull);
    });
  });
}
