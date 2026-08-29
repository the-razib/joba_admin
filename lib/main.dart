import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/article_repository.dart';
import 'package:joba_admin/core/repositories/audit_log_repository.dart';
import 'package:joba_admin/core/repositories/avatar_repository.dart';
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
    runApp(FirebaseBootstrapErrorApp(error: initError));
    return;
  }

  Get.put(ThemeService());
  Get.put(AuthService());
  runApp(const JobaAdminApp());
}

/// Fallback error widget shown if Firebase fails to initialize
class FirebaseBootstrapErrorApp extends StatelessWidget {
  final String? error;
  const FirebaseBootstrapErrorApp({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFEF4444),
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Firebase Initialization Failed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  error ?? 'Unable to connect to Firebase services.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => main(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Retry Connection'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
    Get.lazyPut<UserRepository>(() => MockUserRepository());
    Get.lazyPut<ArticleRepository>(() => MockArticleRepository());
    Get.lazyPut<AvatarRepository>(() => MockAvatarRepository());
    Get.lazyPut<ReportRepository>(() => MockReportRepository());
    Get.lazyPut<AuditLogRepository>(() => MockAuditLogRepository());
    Get.lazyPut<UsageRepository>(() => MockUsageRepository());
    Get.lazyPut<PushRepository>(() => MockPushRepository());
    Get.lazyPut<ScreenerRepository>(() => MockScreenerRepository());

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
