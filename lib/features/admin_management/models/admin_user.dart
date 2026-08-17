import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_colors.dart';

enum AdminRole {
  superAdmin('Super Admin'),
  editor('Editor'),
  viewer('Viewer');

  const AdminRole(this.label);
  final String label;

  Color get color => switch (this) {
        AdminRole.superAdmin => AppColors.primary,
        AdminRole.editor => AppColors.accent,
        AdminRole.viewer => Colors.grey,
      };

  IconData get icon => switch (this) {
        AdminRole.superAdmin => Icons.shield_outlined,
        AdminRole.editor => Icons.edit_note_outlined,
        AdminRole.viewer => Icons.visibility_outlined,
      };
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
