import 'package:flutter/material.dart';

enum NavId {
  dashboard,
  users,
  cycleData,
  diseaseCheckup,
  articles,
  avatars,
  reminders,
  push,
  reports,
  premium,
  settings,
  legal,
  admins,
  audit,
  usage,
  sathiAi,
}

class NavItem {
  const NavItem({
    required this.id,
    required this.label,
    required this.icon,
    this.administration = false,
  });

  final NavId id;
  final String label;
  final IconData icon;
  final bool administration;
}

/// Information architecture mirrors the approved mockups, plus the new
/// Avatar Management module.
const navItems = [
  NavItem(
    id: NavId.dashboard,
    label: 'Dashboard',
    icon: Icons.space_dashboard_outlined,
  ),
  NavItem(id: NavId.users, label: 'Users', icon: Icons.people_outline),
  NavItem(
    id: NavId.cycleData,
    label: 'Cycle Data',
    icon: Icons.monitor_heart_outlined,
  ),
  NavItem(
    id: NavId.diseaseCheckup,
    label: 'Disease Checkup',
    icon: Icons.health_and_safety_outlined,
  ),
  NavItem(id: NavId.articles, label: 'Articles', icon: Icons.article_outlined),
  NavItem(
    id: NavId.avatars,
    label: 'Avatar Management',
    icon: Icons.face_outlined,
  ),
  NavItem(
    id: NavId.reminders,
    label: 'Reminders',
    icon: Icons.notifications_active_outlined,
  ),
  NavItem(
    id: NavId.push,
    label: 'Push Notifications',
    icon: Icons.campaign_outlined,
  ),
  NavItem(
    id: NavId.reports,
    label: 'Reports & Feedback',
    icon: Icons.rate_review_outlined,
  ),
  NavItem(
    id: NavId.premium,
    label: 'Premium & Payments',
    icon: Icons.card_membership_outlined,
  ),
  NavItem(
    id: NavId.settings,
    label: 'App Settings',
    icon: Icons.settings_outlined,
  ),
  NavItem(
    id: NavId.legal,
    label: 'Legal & Policies',
    icon: Icons.policy_outlined,
  ),
  NavItem(
    id: NavId.sathiAi,
    label: 'Sathi AI Control',
    icon: Icons.auto_awesome_outlined,
    administration: true,
  ),
  NavItem(
    id: NavId.admins,
    label: 'Admin Management',
    icon: Icons.admin_panel_settings_outlined,
    administration: true,
  ),
  NavItem(
    id: NavId.audit,
    label: 'Audit Logs',
    icon: Icons.receipt_long_outlined,
    administration: true,
  ),
  NavItem(
    id: NavId.usage,
    label: 'Usage & Cost',
    icon: Icons.query_stats_outlined,
    administration: true,
  ),
];
