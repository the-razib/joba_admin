import 'package:get/get.dart';
import 'package:joba_admin/core/models/admin_profile.dart';
import 'package:joba_admin/core/models/admin_user.dart';
import 'package:uuid/uuid.dart';

class AdminManagementController extends GetxController {
  final admins = <AdminProfile>[].obs;

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    admins.assignAll([
      AdminProfile(uid: 'adm-001', name: 'Md. Razib Hasan', email: 'admin@joba.app', role: AdminRole.superAdmin, lastActive: now.subtract(const Duration(minutes: 4))),
      AdminProfile(uid: 'adm-002', name: 'Farha Islam', email: 'editor@joba.app', role: AdminRole.editor, lastActive: now.subtract(const Duration(hours: 2))),
      AdminProfile(uid: 'adm-003', name: 'Sakib Ahmed', email: 'viewer@joba.app', role: AdminRole.viewer, lastActive: now.subtract(const Duration(days: 1))),
      AdminProfile(uid: 'adm-004', name: 'Tanvir Hasan', email: 'tanvir@joba.app', role: AdminRole.editor, lastActive: now.subtract(const Duration(days: 3)), active: false),
      AdminProfile(uid: 'adm-005', name: 'Moumita Rahi', email: 'moumita@joba.app', role: AdminRole.viewer, lastActive: now.subtract(const Duration(hours: 26))),
    ]);
  }

  void invite({
    required String name,
    required String email,
    required AdminRole role,
  }) {
    admins.insert(
      0,
      AdminProfile(
        uid: const Uuid().v4().substring(0, 8),
        name: name,
        email: email,
        role: role,
        lastActive: DateTime.now(),
        active: false, // activated on first sign-in (Phase 3)
      ),
    );
  }

  void setRole(String uid, AdminRole role) {
    final i = admins.indexWhere((a) => a.uid == uid);
    if (i >= 0) admins[i] = admins[i].copyWith(role: role);
  }

  void toggleActive(String uid) {
    final i = admins.indexWhere((a) => a.uid == uid);
    if (i >= 0) admins[i] = admins[i].copyWith(active: !admins[i].active);
  }
}
