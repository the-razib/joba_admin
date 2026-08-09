import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/features/auth/login_screen.dart';
import 'package:joba_admin/features/shell/admin_shell.dart';
import 'package:joba_admin/routes/app_routes.dart';

class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return Get.find<AuthService>().user.value == null
        ? const RouteSettings(name: AppRoutes.login)
        : null;
  }
}

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(
      name: AppRoutes.shell,
      page: () => const AdminShell(),
      middlewares: [AuthGuard()],
    ),
  ];
}
