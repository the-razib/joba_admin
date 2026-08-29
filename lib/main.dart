import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/article_repository.dart';
import 'package:joba_admin/core/repositories/audit_log_repository.dart';
import 'package:joba_admin/core/repositories/avatar_repository.dart';
import 'package:joba_admin/core/repositories/firebase_avatar_repository.dart';
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
import 'package:joba_admin/features/premium/controllers/premium_controller.dart';
import 'package:joba_admin/features/push_notifications/controllers/push_controller.dart';
import 'package:joba_admin/features/reminders/controllers/reminders_controller.dart';
import 'package:joba_admin/features/reports/controllers/reports_controller.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseInitialized = false;
  String? initError;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirestoreService.configure();
    firebaseInitialized = true;
  } catch (e) {
    initError = e.toString();
    debugPrint('⚠️ [Firebase Bootstrap] Initialization failed: $e');
  }

  if (!firebaseInitialized) {
    runApp(
      FirebaseBootstrapErrorApp(
        error: initError,
        onRetry: () => main(),
      ),
    );
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
    const bool useMocks = bool.fromEnvironment('USE_MOCKS', defaultValue: false);
    final bool enableMocks = useMocks || !hasFirebase;

    Get.lazyPut<UserRepository>(() => enableMocks ? MockUserRepository() : MockUserRepository());
    Get.lazyPut<ArticleRepository>(() => enableMocks ? MockArticleRepository() : MockArticleRepository());
    Get.lazyPut<AvatarRepository>(() => enableMocks ? MockAvatarRepository() : FirebaseAvatarRepository());
    Get.lazyPut<ReportRepository>(() => enableMocks ? MockReportRepository() : MockReportRepository());
    Get.lazyPut<AuditLogRepository>(() => enableMocks ? MockAuditLogRepository() : MockAuditLogRepository());
    Get.lazyPut<UsageRepository>(() => enableMocks ? MockUsageRepository() : MockUsageRepository());
    Get.lazyPut<PushRepository>(() => enableMocks ? MockPushRepository() : MockPushRepository());
    Get.lazyPut<ScreenerRepository>(() => enableMocks ? MockScreenerRepository() : MockScreenerRepository());

    Get.lazyPut(() => ShellController());
    Get.lazyPut(() => AuthController());
    Get.lazyPut(() => DashboardController());
    Get.lazyPut(() => UsersController());
    Get.lazyPut(() => AdminScreenerController());
    Get.lazyPut(() => ArticlesController());
    Get.lazyPut(() => AvatarsController());
    Get.lazyPut(() => ReportsController());
    Get.lazyPut(() => AuditLogsController());
    Get.lazyPut(() => PushController());
    Get.lazyPut(() => CycleDataController());
    Get.lazyPut(() => RemindersController());
    Get.lazyPut(() => PremiumController());
    Get.lazyPut(() => SettingsController());
    Get.lazyPut(() => AdminManagementController());
    Get.lazyPut(() => UsageController());
  }
}
