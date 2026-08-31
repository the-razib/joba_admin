import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/utils/app_toast.dart';
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
    loading.value = true;
    final result = await auth.login(
      emailController.text.trim(),
      passwordController.text,
    );
    loading.value = false;
    if (result.isSuccess) {
      Get.offAllNamed(AppRoutes.shell);
    } else {
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
