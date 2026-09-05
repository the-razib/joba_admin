import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/services/audit_service.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/utils/app_toast.dart';
import 'package:joba_admin/core/utils/logging/logger.dart';
import 'package:joba_admin/features/audit_logs/models/audit_log.dart';
import 'package:joba_admin/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService auth = Get.find();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final loading = false.obs;
  final obscure = true.obs;

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final email = emailController.text.trim();
    AppLoggerHelper.info('[AuthController] 🔑 Submitting admin credentials for $email');
    loading.value = true;
    final result = await auth.login(
      email,
      passwordController.text,
    );
    loading.value = false;
    if (result.isSuccess) {
      AppLoggerHelper.success('AuthController', 'Admin authenticated: $email -> navigating to shell');
      AuditService.log(
        module: 'Authentication',
        action: AuditAction.viewed,
        details: 'Admin signed in successfully ($email)',
        status: AuditStatus.success,
        adminName: auth.user.value?.name ?? email,
      );
      Get.offAllNamed(AppRoutes.shell);
    } else {
      AppLoggerHelper.warning('[AuthController] Login failed for $email: ${result.errorMessage}');
      AuditService.log(
        module: 'Authentication',
        action: AuditAction.failedLogin,
        details: 'Failed login attempt for $email: ${result.errorMessage ?? "Invalid credentials"}',
        status: AuditStatus.failed,
        adminName: email,
      );
      AppToast.error(
        'Login Failed',
        result.errorMessage ?? 'Invalid email or password.',
      );
    }
  }

  void fillCredentials(String email, String password) {
    emailController.text = email;
    passwordController.text = password;
  }
}
