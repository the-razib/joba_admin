import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/features/users/controllers/users_controller.dart';
import 'package:joba_admin/features/users/views/widgets/users_filter_bar.dart';
import 'package:joba_admin/features/users/views/widgets/users_stats_grid.dart';
import 'package:joba_admin/features/users/views/widgets/users_table_card.dart';

/// Users Directory Screen - Manage and view all registered Joba mobile application users.
class UsersScreen extends GetView<UsersController> {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 14 : 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Responsive.contentMax),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UsersStatsGrid(),
                SizedBox(height: 16),
                UsersFilterBar(),
                SizedBox(height: 14),
                UsersTableCard(),
              ],
            ),
          ),
        ),
      );
    });
  }
}
