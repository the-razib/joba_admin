enum AdminRole {
  superAdmin('Super Admin'),
  editor('Editor'),
  viewer('Viewer');

  const AdminRole(this.label);
  final String label;
}

class AdminUser {
  const AdminUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
  });

  final String uid;
  final String name;
  final String email;
  final AdminRole role;
  final String? photoUrl;

  bool get canManageContent =>
      role == AdminRole.superAdmin || role == AdminRole.editor;

  bool get canManageAdmins => role == AdminRole.superAdmin;
}
