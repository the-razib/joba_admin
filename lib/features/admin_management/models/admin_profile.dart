import 'package:joba_admin/features/admin_management/models/admin_user.dart';

/// Admin team member. Phase 3: `admins/{uid}` with custom claims.
class AdminProfile {
  const AdminProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.lastActive,
    this.active = true,
  });

  final String uid;
  final String name;
  final String email;
  final AdminRole role;
  final DateTime lastActive;
  final bool active;

  AdminProfile copyWith({AdminRole? role, bool? active}) => AdminProfile(
        uid: uid,
        name: name,
        email: email,
        role: role ?? this.role,
        lastActive: lastActive,
        active: active ?? this.active,
      );
}
