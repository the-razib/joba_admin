import 'package:flutter/material.dart';
import 'package:joba_admin/features/admin_management/models/admin_user.dart';
import 'package:joba_admin/core/widgets/badges.dart';

/// Reusable pill badge displaying the admin's assigned role with its thematic color and icon.
class AdminRoleBadge extends StatelessWidget {
  final AdminRole role;

  const AdminRoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return PillBadge(
      label: role.label,
      color: role.color,
      icon: role.icon,
    );
  }
}
