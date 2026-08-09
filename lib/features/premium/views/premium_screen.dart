import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/models/app_user.dart';
import 'package:joba_admin/core/models/premium.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/adaptive_data_table.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/core/widgets/page_header.dart';
import 'package:joba_admin/core/widgets/stat_card.dart';
import 'package:joba_admin/features/premium/controllers/premium_controller.dart';

class PremiumScreen extends GetView<PremiumController> {
  const PremiumScreen({super.key});

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
                PageHeader(
                  title: 'Premium & Payments',
                  subtitle: 'Subscriptions, promo codes and transactions',
                  actions: [
                    ElevatedButton.icon(
                      onPressed: () => _promoDialog(context),
                      icon: const Icon(Icons.add, size: 17),
                      label: Responsive.isMobile(context)
                          ? const SizedBox()
                          : const Text('Create Promo Code'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _stats(context),
                const SizedBox(height: 16),
                _tabs(context),
                const SizedBox(height: 14),
                Obx(
                  () => switch (controller.tab.value) {
                    0 => _usersTable(context),
                    1 => _promosTable(context),
                    _ => _txTable(context),
                  },
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _stats(BuildContext context) {
    final stats = [
      (
        Icons.workspace_premium_outlined,
        'Premium Users',
        '${controller.users.length}',
        10.1,
        'vs last 7 days',
        AppColors.warning,
      ),
      (
        Icons.payments_outlined,
        'Revenue (30d)',
        '৳${compactNumber(controller.monthlyRevenue)}',
        14.8,
        'vs last 30 days',
        AppColors.primary,
      ),
      (
        Icons.local_offer_outlined,
        'Active Promos',
        '${controller.promos.where((p) => p.active).length}',
        null,
        '',
        AppColors.accent,
      ),
      (
        Icons.receipt_outlined,
        'Transactions',
        '${controller.transactions.length}',
        6.2,
        'vs last 7 days',
        AppColors.info,
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.pick(
          context,
          mobile: 2,
          tablet: 4,
          desktop: 4,
        ),
        mainAxisExtent: 104,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: stats.length,
      itemBuilder: (_, i) => StatCard(
        icon: stats[i].$1,
        label: stats[i].$2,
        value: stats[i].$3,
        deltaPercent: stats[i].$4,
        compareLabel: stats[i].$5,
        iconColor: stats[i].$6,
      ),
    );
  }

  Widget _tabs(BuildContext context) {
    const labels = ['Premium Users', 'Promo Codes', 'Transactions'];
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: context.palette.inputFill,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < labels.length; i++)
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => controller.tab.value = i,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: controller.tab.value == i
                        ? context.palette.card
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: controller.tab.value == i
                          ? AppColors.primary
                          : context.palette.textSecondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _usersTable(BuildContext context) {
    return Card(
      child: AdaptiveDataTable<AppUser>(
        rows: controller.users,
        cardBuilder: (context, u) => Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              AvatarCircle(name: u.name, size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u.name,
                      style: TextStyle(
                        color: context.palette.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Since ${formatDate(u.joinedAt)}',
                      style: TextStyle(
                        color: context.palette.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              userPlanBadge(u.plan),
            ],
          ),
        ),
        columns: [
          AdaptiveColumn<AppUser>(
            label: 'User',
            flex: 5,
            build: (context, u) => Row(
              children: [
                AvatarCircle(name: u.name, size: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        u.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.palette.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        u.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.palette.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AdaptiveColumn<AppUser>(
            label: 'Plan',
            flex: 2,
            build: (context, u) => userPlanBadge(u.plan),
          ),
          AdaptiveColumn<AppUser>(
            label: 'Member Since',
            flex: 3,
            build: (context, u) => Text(
              formatDate(u.joinedAt),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.palette.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          AdaptiveColumn<AppUser>(
            label: 'Renews',
            flex: 3,
            tabletHidden: true,
            build: (context, u) => Text(
              formatDate(u.joinedAt.add(const Duration(days: 365))),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.palette.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          AdaptiveColumn<AppUser>(
            label: 'Status',
            flex: 2,
            build: (context, u) =>
                const PillBadge(label: 'Active', color: AppColors.success),
          ),
        ],
      ),
    );
  }

  Widget _promosTable(BuildContext context) {
    return Card(
      child: AdaptiveDataTable<PromoCode>(
        rows: controller.promos,
        cardBuilder: (context, p) => Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(
                Icons.local_offer_outlined,
                color: AppColors.accent,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.code,
                      style: TextStyle(
                        color: context.palette.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${p.percentOff}% off • ${p.usedCount} uses',
                      style: TextStyle(
                        color: context.palette.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: p.active,
                activeThumbColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (_) => controller.togglePromo(p.code),
              ),
            ],
          ),
        ),
        columns: [
          AdaptiveColumn<PromoCode>(
            label: 'Code',
            flex: 4,
            build: (context, p) => Text(
              p.code,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.palette.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          AdaptiveColumn<PromoCode>(
            label: 'Discount',
            flex: 2,
            build: (context, p) => Text(
              '${p.percentOff}%',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          AdaptiveColumn<PromoCode>(
            label: 'Used',
            flex: 2,
            build: (context, p) => Text(
              '${p.usedCount}×',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.palette.textSecondary,
                fontSize: 12.5,
              ),
            ),
          ),
          AdaptiveColumn<PromoCode>(
            label: 'Expires',
            flex: 3,
            build: (context, p) => Text(
              formatDate(p.expiresAt),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.palette.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          AdaptiveColumn<PromoCode>(
            label: 'Active',
            width: 64,
            build: (context, p) => Switch(
              value: p.active,
              activeThumbColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (_) => controller.togglePromo(p.code),
            ),
          ),
        ],
      ),
    );
  }

  Widget _txTable(BuildContext context) {
    return Card(
      child: AdaptiveDataTable<Transaction>(
        rows: controller.transactions,
        cardBuilder: (context, t) => Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(
                Icons.receipt_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${t.userName} • ৳${t.amountBdt}',
                      style: TextStyle(
                        color: context.palette.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${t.method} • ${formatDate(t.date)}',
                      style: TextStyle(
                        color: context.palette.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              _txBadge(t.status),
            ],
          ),
        ),
        columns: [
          AdaptiveColumn<Transaction>(
            label: 'Transaction',
            flex: 5,
            build: (context, t) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.id,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.palette.textPrimary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  t.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.palette.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          AdaptiveColumn<Transaction>(
            label: 'Amount',
            flex: 2,
            build: (context, t) => Text(
              '৳${t.amountBdt}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.palette.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          AdaptiveColumn<Transaction>(
            label: 'Method',
            flex: 3,
            build: (context, t) => Text(
              t.method,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.palette.textSecondary,
                fontSize: 12.5,
              ),
            ),
          ),
          AdaptiveColumn<Transaction>(
            label: 'Date',
            flex: 3,
            tabletHidden: true,
            build: (context, t) => Text(
              formatDate(t.date),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.palette.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          AdaptiveColumn<Transaction>(
            label: 'Status',
            flex: 3,
            build: (context, t) => _txBadge(t.status),
          ),
        ],
      ),
    );
  }

  PillBadge _txBadge(TxStatus s) => switch (s) {
    TxStatus.success => const PillBadge(
      label: 'Success',
      color: AppColors.success,
    ),
    TxStatus.refunded => const PillBadge(
      label: 'Refunded',
      color: AppColors.warning,
    ),
    TxStatus.pending => const PillBadge(
      label: 'Pending',
      color: AppColors.info,
    ),
  };

  void _promoDialog(BuildContext context) {
    final code = TextEditingController();
    final percent = TextEditingController(text: '10');
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Promo Code',
                  style: TextStyle(
                    color: context.palette.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: code,
                  decoration: const InputDecoration(hintText: 'CODE'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: percent,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Discount %'),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final c = code.text.trim().toUpperCase();
                        final p = int.tryParse(percent.text) ?? 0;
                        if (c.isEmpty || p <= 0) return;
                        controller.addPromo(
                          PromoCode(
                            code: c,
                            percentOff: p,
                            expiresAt: DateTime.now().add(
                              const Duration(days: 30),
                            ),
                          ),
                        );
                        Navigator.of(context).pop();
                        Get.snackbar(
                          'Promo created',
                          '$c ($p% off) is live (mock).',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      child: const Text('Create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
