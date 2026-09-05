import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/admin_repository.dart';
import 'package:joba_admin/core/repositories/article_repository.dart';
import 'package:joba_admin/core/repositories/audit_log_repository.dart';
import 'package:joba_admin/core/repositories/avatar_repository.dart';
import 'package:joba_admin/core/repositories/config_repository.dart';
import 'package:joba_admin/core/repositories/firebase_article_repository.dart';
import 'package:joba_admin/core/repositories/firebase_audit_log_repository.dart';
import 'package:joba_admin/core/repositories/firebase_avatar_repository.dart';
import 'package:joba_admin/core/repositories/firebase_legal_repository.dart';
import 'package:joba_admin/core/repositories/firebase_premium_repository.dart';
import 'package:joba_admin/core/repositories/firebase_push_repository.dart';
import 'package:joba_admin/core/repositories/firebase_report_repository.dart';
import 'package:joba_admin/core/repositories/firebase_screener_repository.dart';
import 'package:joba_admin/core/repositories/firebase_usage_repository.dart';
import 'package:joba_admin/core/repositories/firebase_user_repository.dart';
import 'package:joba_admin/core/repositories/legal_repository.dart';
import 'package:joba_admin/core/repositories/premium_repository.dart';
import 'package:joba_admin/core/repositories/push_repository.dart';
import 'package:joba_admin/core/repositories/report_repository.dart';
import 'package:joba_admin/core/repositories/screener_repository.dart';
import 'package:joba_admin/core/repositories/usage_repository.dart';
import 'package:joba_admin/core/repositories/user_repository.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/services/theme_service.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/features/admin_management/controllers/admin_management_controller.dart';
import 'package:joba_admin/features/app_settings/controllers/settings_controller.dart';
import 'package:joba_admin/features/articles/controllers/articles_controller.dart';
import 'package:joba_admin/features/audit_logs/controllers/audit_logs_controller.dart';
import 'package:joba_admin/features/auth/auth_controller.dart';
import 'package:joba_admin/features/avatars/controllers/avatars_controller.dart';
import 'package:joba_admin/features/cycle_data/controllers/cycle_data_controller.dart';
import 'package:joba_admin/features/dashboard/controllers/dashboard_controller.dart';
import 'package:joba_admin/features/disease_checkup/controllers/admin_screener_controller.dart';
import 'package:joba_admin/features/notifications/controllers/admin_notifications_controller.dart';
import 'package:joba_admin/features/premium/controllers/premium_controller.dart';
import 'package:joba_admin/features/push_notifications/controllers/push_controller.dart';
import 'package:joba_admin/features/reminders/controllers/reminders_controller.dart';
import 'package:joba_admin/features/reports/controllers/reports_controller.dart';
import 'package:joba_admin/features/sathi_ai/controllers/sathi_ai_controller.dart';
import 'package:joba_admin/features/shell/shell_controller.dart';
import 'package:joba_admin/features/usage/controllers/usage_controller.dart';
import 'package:joba_admin/features/users/controllers/users_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:joba_admin/core/services/firestore_service.dart';
import 'package:joba_admin/core/services/functions_service.dart';
import 'package:joba_admin/core/services/storage_service.dart';
import 'package:joba_admin/core/widgets/firebase_bootstrap_error_app.dart';
import 'package:joba_admin/firebase_options.dart';
import 'package:joba_admin/routes/app_pages.dart';
import 'package:joba_admin/routes/app_routes.dart';

import 'package:joba_admin/core/utils/logging/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLoggerHelper.info('🚀 Joba Admin Panel starting up...');

  bool firebaseInitialized = false;
  String? initError;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirestoreService.configure();
    firebaseInitialized = true;
    AppLoggerHelper.success('Bootstrap', 'Firebase initialized successfully');
  } catch (e, st) {
    initError = e.toString();
    AppLoggerHelper.failure('Firebase Bootstrap', 'Initialization failed: $e', error: e, stackTrace: st);
  }

  if (!firebaseInitialized) {
    runApp(FirebaseBootstrapErrorApp(error: initError, onRetry: () => main()));
    return;
  }

  Get.put(ThemeService());
  Get.put(AuthService());
  runApp(const JobaAdminApp());
}

class JobaAdminApp extends StatelessWidget {
  const JobaAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        title: 'Joba Admin',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: Get.find<ThemeService>().mode.value,
        initialBinding: _AppBindings(),
        getPages: AppPages.routes,
        initialRoute: AppRoutes.shell,
      ),
    );
  }
}

/// Mock repositories are bound here; Phase 3 swaps them for Firebase
/// implementations without touching any UI code.
class _AppBindings extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut(() => StorageService());
    Get.lazyPut(() => FunctionsService());

    // Flag to force mock implementations during development/testing or headless tests
    final bool hasFirebase = Firebase.apps.isNotEmpty;
    const bool useMocks = bool.fromEnvironment(
      'USE_MOCKS',
      defaultValue: false,
    );
    final bool enableMocks = useMocks || !hasFirebase;

    Get.lazyPut<UserRepository>(
      () => enableMocks ? MockUserRepository() : FirebaseUserRepository(),
      fenix: true,
    );
    Get.lazyPut<ArticleRepository>(
      () => enableMocks ? MockArticleRepository() : FirebaseArticleRepository(),
      fenix: true,
    );
    Get.lazyPut<AvatarRepository>(
      () => enableMocks ? MockAvatarRepository() : FirebaseAvatarRepository(),
      fenix: true,
    );
    Get.lazyPut<ReportRepository>(
      () => enableMocks ? MockReportRepository() : FirebaseReportRepository(),
      fenix: true,
    );
    Get.lazyPut<AuditLogRepository>(
      () =>
          enableMocks ? MockAuditLogRepository() : FirebaseAuditLogRepository(),
      fenix: true,
    );
    Get.lazyPut<UsageRepository>(
      () => enableMocks ? MockUsageRepository() : FirebaseUsageRepository(),
      fenix: true,
    );
    Get.lazyPut<PushRepository>(
      () => enableMocks ? MockPushRepository() : FirebasePushRepository(),
      fenix: true,
    );
    Get.lazyPut<ScreenerRepository>(
      () =>
          enableMocks ? MockScreenerRepository() : FirebaseScreenerRepository(),
      fenix: true,
    );
    Get.lazyPut<ConfigRepository>(
      () => enableMocks ? MockConfigRepository() : FirebaseConfigRepository(),
      fenix: true,
    );
    Get.lazyPut<AdminRepository>(
      () => enableMocks ? MockAdminRepository() : FirebaseAdminRepository(),
      fenix: true,
    );
    Get.lazyPut<PremiumRepository>(
      () => enableMocks ? MockPremiumRepository() : FirebasePremiumRepository(),
      fenix: true,
    );
    Get.lazyPut<LegalRepository>(
      () => enableMocks ? MockLegalRepository() : FirebaseLegalRepository(),
      fenix: true,
    );

    Get.lazyPut(() => ShellController(), fenix: true);
    Get.put(AuthController(), permanent: true);
    Get.lazyPut(() => DashboardController(), fenix: true);
    Get.lazyPut(() => UsersController(), fenix: true);
    Get.lazyPut(() => AdminScreenerController(), fenix: true);
    Get.lazyPut(() => ArticlesController(), fenix: true);
    Get.lazyPut(() => AvatarsController(), fenix: true);
    Get.lazyPut(() => ReportsController(), fenix: true);
    Get.lazyPut(() => AuditLogsController(), fenix: true);
    Get.lazyPut(() => PushController(), fenix: true);
    Get.lazyPut(() => CycleDataController(), fenix: true);
    Get.lazyPut(() => RemindersController(), fenix: true);
    Get.lazyPut(() => PremiumController(), fenix: true);
    Get.lazyPut(() => SettingsController(), fenix: true);
    Get.lazyPut(() => AdminManagementController(), fenix: true);
    Get.lazyPut(() => UsageController(), fenix: true);
    Get.lazyPut(() => SathiAiController(), fenix: true);
    Get.lazyPut(() => AdminNotificationsController(), fenix: true);
  }

}
