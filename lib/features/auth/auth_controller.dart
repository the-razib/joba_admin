import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService auth = Get.find();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController(text: 'admin@joba.app');
  final passwordController = TextEditingController(text: 'admin123');
  final loading = false.obs;
  final obscure = true.obs;

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    loading.value = true;
    final ok = await auth.login(
      emailController.text,
      passwordController.text,
    );
    loading.value = false;
    if (ok) {
      Get.offAllNamed(AppRoutes.shell);
    } else {
      Get.snackbar(
        'Login failed',
        'Invalid email or password. Try a demo account below.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void fillDemo(String email, String password) {
    emailController.text = email;
    passwordController.text = password;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
