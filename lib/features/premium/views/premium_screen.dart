import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/widgets/page_header.dart';
import 'package:joba_admin/features/premium/controllers/premium_controller.dart';
import 'package:joba_admin/features/premium/views/widgets/create_promo_dialog.dart';
import 'package:joba_admin/features/premium/views/widgets/premium_promos_table.dart';
import 'package:joba_admin/features/premium/views/widgets/premium_stats_grid.dart';
import 'package:joba_admin/features/premium/views/widgets/premium_tab_bar.dart';
import 'package:joba_admin/features/premium/views/widgets/premium_transactions_table.dart';
import 'package:joba_admin/features/premium/views/widgets/premium_users_table.dart';

/// Premium Screen - Management dashboard for subscriptions, promo codes, and payment transactions.
class PremiumScreen extends GetView<PremiumController> {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool canManage = Get.isRegistered<AuthService>()
        ? Get.find<AuthService>().canManageContent
        : true;
    final mobile = Responsive.isMobile(context);

    return Obx(() {
      if (controller.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return SingleChildScrollView(
        padding: EdgeInsets.all(mobile ? 14 : 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Responsive.contentMax),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'Premium & Payments',
                  subtitle: 'Subscriptions, promo codes and transactions',
                  actions: [
                    OutlinedButton.icon(
                      onPressed: () => controller.refreshData(),
                      icon: const Icon(Icons.refresh_outlined, size: 16),
                      label: mobile ? const SizedBox() : const Text('Refresh'),
                    ),
                    if (canManage) ...[
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => CreatePromoDialog.show(context),
                        icon: const Icon(Icons.add, size: 17),
                        label: mobile
                            ? const SizedBox()
                            : const Text('Create Promo Code'),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                const PremiumStatsGrid(),
                const SizedBox(height: 16),
                const PremiumTabBar(),
                const SizedBox(height: 14),
                Obx(
                  () => switch (controller.tab.value) {
                    0 => const PremiumUsersTable(),
                    1 => const PremiumPromosTable(),
                    _ => const PremiumTransactionsTable(),
                  },
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
