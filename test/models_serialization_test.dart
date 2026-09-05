import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:flutter_test/flutter_test.dart';
import 'package:joba_admin/features/admin_management/models/admin_profile.dart';
import 'package:joba_admin/features/admin_management/models/admin_user.dart';
import 'package:joba_admin/features/articles/models/article.dart';
import 'package:joba_admin/features/articles/models/article_category.dart';
import 'package:joba_admin/features/audit_logs/models/audit_log.dart';
import 'package:joba_admin/features/avatars/models/avatar_item.dart';
import 'package:joba_admin/features/premium/models/premium.dart';
import 'package:joba_admin/features/push_notifications/models/push_notification.dart';
import 'package:joba_admin/features/reminders/models/reminder_template.dart';
import 'package:joba_admin/features/reports/models/report.dart';
import 'package:joba_admin/features/usage/models/usage_metrics.dart';
import 'package:joba_admin/features/users/models/app_user.dart';

void main() {
  group('Model Serialization Round-trip Tests (toMap / fromMap)', () {
    test('AppUser round-trip serialization', () {
      final now = DateTime(2026, 8, 29, 12, 0, 0);
      final user = AppUser(
        uid: 'user_123',
        name: 'Farhana Akter',
        email: 'farhana@example.com',
        status: UserStatus.active,
        plan: UserPlan.premium,
        country: 'Bangladesh',
        countryCode: 'BD',
        joinedAt: now.subtract(const Duration(days: 30)),
        lastActive: now,
        language: 'bn',
        averageCycleLength: 28,
        averagePeriodDuration: 5,
        cycleGoal: 'track',
        birthYear: 1998,
        reminders: const [ReminderKind.pad, ReminderKind.periodPrep],
      );

      final map = user.toMap();
      expect(map['joinedAt'], isA<Timestamp>());
      expect(map['lastActive'], isA<Timestamp>());
      expect(map['status'], 'active');
      expect(map['plan'], 'premium');

      final deserialized = AppUser.fromMap(map, docId: 'user_123');
      expect(deserialized.uid, user.uid);
      expect(deserialized.name, user.name);
      expect(deserialized.email, user.email);
      expect(deserialized.status, user.status);
      expect(deserialized.plan, user.plan);
      expect(deserialized.countryCode, user.countryCode);
      expect(deserialized.reminders, user.reminders);
    });

    test('Article and ArticleCategory round-trip serialization', () {
      final now = DateTime(2026, 8, 29, 10, 0, 0);
      const category = ArticleCategory(
        id: 'period',
        nameBn: 'পিরিয়ড',
        nameEn: 'Period',
        subtitleBn: 'হাইজিন',
        subtitleEn: 'Hygiene',
        imagePath: 'assets/images/period.jpg',
        isFullWidth: true,
        order: 1,
        active: true,
      );

      final catMap = category.toMap();
      final deserializedCat = ArticleCategory.fromMap(catMap, docId: 'period');
      expect(deserializedCat.id, category.id);
      expect(deserializedCat.nameBn, category.nameBn);
      expect(deserializedCat.nameEn, category.nameEn);
      expect(deserializedCat.isFullWidth, category.isFullWidth);

      final article = Article(
        id: 'art_101',
        categoryId: 'period',
        titleBn: 'পিরিয়ডের যত্ন',
        titleEn: 'Period Self-Care',
        subtitleBn: 'টিপস',
        subtitleEn: 'Tips',
        contentBn: 'বিস্তারিত তথ্য',
        contentEn: 'Detailed info',
        imagePath: 'https://storage.googleapis.com/articles/image.png',
        audioBnPath: 'https://storage.googleapis.com/articles/audio_bn.mp3',
        tags: const ['period', 'health'],
        status: ArticleStatus.published,
        featured: true,
        displayOrder: 2,
        views: 1500,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now,
      );

      final artMap = article.toMap();
      expect(artMap['createdAt'], isA<Timestamp>());
      expect(artMap['updatedAt'], isA<Timestamp>());

      final deserializedArt = Article.fromMap(artMap, docId: 'art_101');
      expect(deserializedArt.id, article.id);
      expect(deserializedArt.titleBn, article.titleBn);
      expect(deserializedArt.titleEn, article.titleEn);
      expect(deserializedArt.imagePath, article.imagePath);
      expect(deserializedArt.audioBnPath, article.audioBnPath);
      expect(deserializedArt.status, article.status);
    });

    test('AvatarItem and AvatarCategory round-trip serialization', () {
      const cat = AvatarCategory(id: 'modern', name: 'Modern', order: 0);
      final catMap = cat.toMap();
      final deserializedCat = AvatarCategory.fromMap(catMap, docId: 'modern');
      expect(deserializedCat.name, cat.name);

      final item = AvatarItem(
        id: 'avatar_01.png',
        categoryId: 'modern',
        assetPath: 'assets/avatars/avatar_01.png',
        order: 1,
        active: true,
        pendingBytes: [1, 2, 3], // Should NOT be serialized
      );

      final itemMap = item.toMap();
      expect(itemMap.containsKey('pendingBytes'), isFalse);

      final deserializedItem = AvatarItem.fromMap(itemMap, docId: 'avatar_01.png');
      expect(deserializedItem.id, item.id);
      expect(deserializedItem.categoryId, item.categoryId);
      expect(deserializedItem.assetPath, item.assetPath);
      expect(deserializedItem.pendingBytes, isNull);
    });

    test('Report round-trip serialization', () {
      final now = DateTime(2026, 8, 29, 9, 30, 0);
      final report = Report(
        id: 'RP-001',
        type: ReportType.bug,
        subject: 'Crash on calendar',
        description: 'App freezes when tapping calendar tab',
        userName: 'Meherun Nisa',
        userEmail: 'meherun@example.com',
        status: ReportStatus.inProgress,
        priority: ReportPriority.high,
        date: now,
        deviceModel: 'Pixel 8',
        os: 'Android 14',
      );

      final map = report.toMap();
      expect(map['date'], isA<Timestamp>());
      expect(map['status'], 'inProgress');

      final deserialized = Report.fromMap(map, docId: 'RP-001');
      expect(deserialized.id, report.id);
      expect(deserialized.type, report.type);
      expect(deserialized.subject, report.subject);
      expect(deserialized.status, report.status);
      expect(deserialized.priority, report.priority);
      expect(deserialized.deviceModel, report.deviceModel);
    });

    test('AuditLog round-trip serialization', () {
      final now = DateTime(2026, 8, 29, 8, 0, 0);
      final log = AuditLog(
        id: 'AL-100',
        time: now,
        adminName: 'Super Admin',
        adminRole: 'superAdmin',
        action: AuditAction.updated,
        module: 'Settings',
        details: 'Updated notification threshold',
        ip: '192.168.1.1',
        location: 'Dhaka, Bangladesh',
        status: AuditStatus.success,
      );

      final map = log.toMap();
      expect(map['time'], isA<Timestamp>());
      expect(map['action'], 'updated');

      final deserialized = AuditLog.fromMap(map, docId: 'AL-100');
      expect(deserialized.id, log.id);
      expect(deserialized.adminName, log.adminName);
      expect(deserialized.action, log.action);
      expect(deserialized.module, log.module);
      expect(deserialized.status, log.status);
    });

    test('PushNotification round-trip serialization', () {
      final now = DateTime(2026, 8, 29, 7, 0, 0);
      final push = PushNotification(
        id: 'PN-001',
        titleBn: 'নতুন রিমাইন্ডার',
        titleEn: 'New Reminder Alert',
        bodyBn: 'আপনার পিরিয়ডের সময় আসন্ন।',
        bodyEn: 'Your cycle approaches.',
        audience: PushAudience.all,
        channel: NotificationChannel.both,
        inAppLayout: InAppLayout.modal,
        imageUrl: 'https://example.com/banner.png',
        actionLabelBn: 'দেখুন',
        actionLabelEn: 'View',
        actionUrl: 'joba://home',
        status: PushStatus.sent,
        sentAt: now,
        createdAt: now,
        createdBy: 'admin-uid',
        sentCount: 10000,
        failedCount: 210,
        messageId: 'projects/joba/messages/1',
      );

      final map = push.toMap();
      expect(map['sentAt'], isA<Timestamp>());
      expect(map['channel'], 'both');

      final deserialized = PushNotification.fromMap(map, docId: 'PN-001');
      expect(deserialized.id, push.id);
      expect(deserialized.titleBn, push.titleBn);
      expect(deserialized.titleEn, push.titleEn);
      expect(deserialized.channel, push.channel);
      expect(deserialized.inAppLayout, push.inAppLayout);
      expect(deserialized.sentCount, push.sentCount);
      expect(deserialized.failedCount, push.failedCount);
      expect(deserialized.messageId, push.messageId);
      expect(deserialized.createdBy, push.createdBy);
      expect(deserialized.actionLabelEn, push.actionLabelEn);
      expect(deserialized.status, PushStatus.sent);
    });

    test('PromoCode and Transaction round-trip serialization', () {
      final now = DateTime(2026, 8, 29, 6, 0, 0);
      final promo = PromoCode(
        code: 'SUMMER50',
        percentOff: 50,
        expiresAt: now.add(const Duration(days: 30)),
        active: true,
        usedCount: 120,
      );

      final promoMap = promo.toMap();
      expect(promoMap['expiresAt'], isA<Timestamp>());
      final deserializedPromo = PromoCode.fromMap(promoMap, docId: 'SUMMER50');
      expect(deserializedPromo.code, promo.code);
      expect(deserializedPromo.percentOff, promo.percentOff);

      final tx = Transaction(
        id: 'TX-998',
        userName: 'Sadia Islam',
        amountBdt: 499,
        method: 'bKash',
        date: now,
        status: TxStatus.success,
      );

      final txMap = tx.toMap();
      expect(txMap['date'], isA<Timestamp>());
      final deserializedTx = Transaction.fromMap(txMap, docId: 'TX-998');
      expect(deserializedTx.id, tx.id);
      expect(deserializedTx.amountBdt, tx.amountBdt);
      expect(deserializedTx.method, tx.method);
      expect(deserializedTx.status, tx.status);
    });

    test('AdminProfile round-trip serialization', () {
      final now = DateTime(2026, 8, 29, 5, 0, 0);
      final profile = AdminProfile(
        uid: 'adm_777',
        name: 'Editor Admin',
        email: 'editor@joba.app',
        role: AdminRole.editor,
        lastActive: now,
        active: true,
      );

      final map = profile.toMap();
      expect(map['lastActive'], isA<Timestamp>());
      expect(map['role'], 'editor');

      final deserialized = AdminProfile.fromMap(map, docId: 'adm_777');
      expect(deserialized.uid, profile.uid);
      expect(deserialized.name, profile.name);
      expect(deserialized.role, profile.role);
      expect(deserialized.active, profile.active);
    });

    test('UsageDay round-trip serialization', () {
      final now = DateTime(2026, 8, 29, 0, 0, 0);
      final usage = UsageDay(
        date: now,
        reads: 120000,
        writes: 35000,
        deletes: 2000,
        firestoreStoredBytes: 1024 * 1024 * 500,
        storageStoredBytes: 1024 * 1024 * 1000,
        storageObjects: 5000,
        egressBytes: 1024 * 1024 * 200,
        functionInvocations: 80000,
      );

      final map = usage.toMap();
      expect(map['date'], isA<Timestamp>());

      final deserialized = UsageDay.fromMap(map);
      expect(deserialized.reads, usage.reads);
      expect(deserialized.writes, usage.writes);
      expect(deserialized.deletes, usage.deletes);
      expect(deserialized.firestoreStoredBytes, usage.firestoreStoredBytes);
    });

    test('ReminderTemplate round-trip serialization', () {
      final now = DateTime(2026, 8, 29, 4, 0, 0);
      final template = ReminderTemplate(
        id: 'reminders',
        order: const [ReminderKind.medicine, ReminderKind.pad, ReminderKind.periodPrep],
        updatedAt: now,
        updatedBy: 'admin@joba.com',
      );

      final map = template.toMap();
      expect(map['updatedAt'], isA<Timestamp>());
      expect(map['order'], ['medicine', 'pad', 'periodPrep']);

      final deserialized = ReminderTemplate.fromMap(map, docId: 'reminders');
      expect(deserialized.id, template.id);
      expect(deserialized.order, template.order);
      expect(deserialized.updatedBy, template.updatedBy);
    });
  });
}
