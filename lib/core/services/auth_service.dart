import 'package:get/get.dart';
import 'package:joba_admin/core/models/admin_user.dart';

/// Mock admin auth. Phase 3: Firebase Auth + custom claims for roles.
class AuthService extends GetxService {
  final user = Rx<AdminUser?>(null);

  static const demoAccounts = [
    ('admin@joba.app', 'admin123', 'Super Admin'),
    ('editor@joba.app', 'editor123', 'Editor'),
    ('viewer@joba.app', 'viewer123', 'Viewer'),
  ];

  Future<bool> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final e = email.trim().toLowerCase();
    if (e == 'admin@joba.app' && password == 'admin123') {
      user.value = const AdminUser(
        uid: 'adm-001',
        name: 'Md. Razib Hasan',
        email: 'admin@joba.app',
        role: AdminRole.superAdmin,
      );
      return true;
    }
    if (e == 'editor@joba.app' && password == 'editor123') {
      user.value = const AdminUser(
        uid: 'adm-002',
        name: 'Farha Islam',
        email: 'editor@joba.app',
        role: AdminRole.editor,
      );
      return true;
    }
    if (e == 'viewer@joba.app' && password == 'viewer123') {
      user.value = const AdminUser(
        uid: 'adm-003',
        name: 'Sakib Ahmed',
        email: 'viewer@joba.app',
        role: AdminRole.viewer,
      );
      return true;
    }
    return false;
  }

  void logout() => user.value = null;
}
