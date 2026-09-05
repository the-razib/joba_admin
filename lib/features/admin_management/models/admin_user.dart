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

  static AdminRole fromString(dynamic value) {
    if (value == null) return AdminRole.viewer;
    final str = value.toString().toLowerCase().trim();
    if (str == 'superadmin' || str == 'super_admin' || str == 'super admin') {
      return AdminRole.superAdmin;
    }
    if (str == 'editor') {
      return AdminRole.editor;
    }
    return AdminRole.viewer;
  }
}

class AdminUser {
  const AdminUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    this.active = true,
  });

  final String uid;
  final String name;
  final String email;
  final AdminRole role;
  final String? photoUrl;
  final bool active;

  factory AdminUser.fromFirebase({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
    Map<String, dynamic>? firestoreData,
    AdminRole? roleFromClaim,
  }) {
    final role = roleFromClaim ??
        AdminRole.fromString(firestoreData?['role']);
    final name = firestoreData?['name'] as String? ??
        displayName ??
        (email.contains('@') ? email.split('@').first : 'Admin');
    final active = firestoreData?['active'] as bool? ?? true;

    return AdminUser(
      uid: uid,
      name: name,
      email: email,
      role: role,
      photoUrl: photoUrl ?? firestoreData?['photoUrl'] as String?,
      active: active,
    );
  }

  bool get canManageContent =>
      role == AdminRole.superAdmin || role == AdminRole.editor;

  bool get canManageAdmins => role == AdminRole.superAdmin;

  AdminUser copyWith({
    String? uid,
    String? name,
    String? email,
    AdminRole? role,
    String? photoUrl,
    bool? active,
    bool clearPhoto = false,
  }) {
    return AdminUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      photoUrl: clearPhoto ? null : (photoUrl ?? this.photoUrl),
      active: active ?? this.active,
    );
  }
}

