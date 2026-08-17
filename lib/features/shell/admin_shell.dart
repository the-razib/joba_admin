import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/features/admin_management/views/admin_management_screen.dart';
import 'package:joba_admin/features/app_settings/views/settings_screen.dart';
import 'package:joba_admin/features/articles/views/articles_screen.dart';
import 'package:joba_admin/features/audit_logs/views/audit_logs_screen.dart';
import 'package:joba_admin/features/avatars/views/avatars_screen.dart';
import 'package:joba_admin/features/cycle_data/views/cycle_data_screen.dart';
import 'package:joba_admin/features/dashboard/views/dashboard_screen.dart';
import 'package:joba_admin/features/disease_checkup/views/admin_screener_screen.dart';
import 'package:joba_admin/features/premium/views/premium_screen.dart';
import 'package:joba_admin/features/push_notifications/views/push_screen.dart';
import 'package:joba_admin/features/reminders/views/reminders_screen.dart';
import 'package:joba_admin/features/reports/views/reports_screen.dart';
import 'package:joba_admin/features/shell/nav_items.dart';
import 'package:joba_admin/features/shell/shell_controller.dart';
import 'package:joba_admin/features/shell/widgets/mobile_bottom_nav.dart';
import 'package:joba_admin/features/shell/widgets/sidebar.dart';
import 'package:joba_admin/features/shell/widgets/top_bar.dart';
import 'package:joba_admin/features/usage/views/usage_screen.dart';
import 'package:joba_admin/features/users/views/users_screen.dart';

class AdminShell extends GetView<ShellController> {
  const AdminShell({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = Responsive.isMobile(context);
    return Scaffold(
      key: controller.scaffoldKey,
      drawer: mobile ? const Drawer(width: 280, child: Sidebar()) : null,
      body: mobile ? _mobileBody() : _desktopBody(context),
      bottomNavigationBar: mobile ? const MobileBottomNav() : null,
    );
  }

  Widget _mobileBody() {
    return Column(
      children: [
        const TopBar(),
        Expanded(child: Obx(() => _pageFor(controller.current))),
      ],
    );
  }

  Widget _desktopBody(BuildContext context) {
    return Obx(() {
      final rail =
          Responsive.isTablet(context) || controller.sidebarCollapsed.value;
      return Row(
        children: [
          Sidebar(rail: rail),
          Expanded(
            child: Column(
              children: [
                const TopBar(),
                Expanded(child: _pageFor(controller.current)),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _pageFor(NavId id) {
    switch (id) {
      case NavId.dashboard:
        return const DashboardScreen();
      case NavId.users:
        return const UsersScreen();
      case NavId.articles:
        return const ArticlesScreen();
      case NavId.avatars:
        return const AvatarsScreen();
      case NavId.cycleData:
        return const CycleDataScreen();
      case NavId.diseaseCheckup:
        return const AdminScreenerScreen();
      case NavId.reminders:
        return const RemindersScreen();
      case NavId.push:
        return const PushScreen();
      case NavId.reports:
        return const ReportsScreen();
      case NavId.premium:
        return const PremiumScreen();
      case NavId.settings:
        return const SettingsScreen();
      case NavId.admins:
        return const AdminManagementScreen();
      case NavId.audit:
        return const AuditLogsScreen();
      case NavId.usage:
        return const UsageScreen();
    }
  }
}
