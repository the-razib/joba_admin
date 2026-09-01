import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/adaptive_data_table.dart';
import 'package:joba_admin/core/widgets/empty_state.dart';
import 'package:joba_admin/core/widgets/filter_bar.dart';
import 'package:joba_admin/core/widgets/pagination_bar.dart';
import 'package:joba_admin/features/premium/controllers/premium_controller.dart';
import 'package:joba_admin/features/premium/models/premium.dart';

/// Card containing search, paginated data table and pagination bar for active & inactive Promo Codes.
class PremiumPromosTable extends GetView<PremiumController> {
  const PremiumPromosTable({super.key});

  Future<void> _confirmDelete(BuildContext context, String code) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Promo Code'),
        content: Text('Are you sure you want to permanently delete promo code "$code"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.deletePromo(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canManage = Get.isRegistered<AuthService>()
        ? Get.find<AuthService>().canManageContent
        : true;

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: FilterBar(
              searchController: controller.searchController,
              searchHint: 'Search promo codes...',
              onSearchChanged: (_) => controller.searchTick.value++,
            ),
          ),
          Obx(() {
            controller.searchTick.value;
            return AdaptiveDataTable<PromoCode>(
              rows: controller.paginatedPromos,
              empty: const EmptyState(
                icon: Icons.local_offer_outlined,
                title: 'No promo codes found',
                subtitle:
                    'Create discount codes to offer promotional pricing for users.',
              ),
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
                            '${p.percentOff}% off • ${p.usedCount} uses • Expires ${formatDate(p.expiresAt)}',
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
                      onChanged: canManage ? (_) => controller.togglePromo(p.code) : null,
                    ),
                    if (canManage) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                        tooltip: 'Delete promo',
                        onPressed: () => _confirmDelete(context, p.code),
                      ),
                    ],
                  ],
                ),
              ),
              columns: [
                AdaptiveColumn<PromoCode>(
                  label: 'Code',
                  flex: 4,
                  build: (context, p) => Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          p.code,
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
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
                      color: AppColors.success,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AdaptiveColumn<PromoCode>(
                  label: 'Redemptions',
                  flex: 2,
                  build: (context, p) => Text(
                    '${p.usedCount} uses',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.palette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                AdaptiveColumn<PromoCode>(
                  label: 'Expires',
                  flex: 3,
                  tabletHidden: true,
                  build: (context, p) {
                    final isExpired = p.expiresAt.isBefore(DateTime.now());
                    return Text(
                      formatDate(p.expiresAt),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isExpired ? AppColors.danger : context.palette.textSecondary,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
                AdaptiveColumn<PromoCode>(
                  label: 'Active',
                  flex: 2,
                  build: (context, p) => Switch(
                    value: p.active,
                    activeThumbColor: AppColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: canManage ? (_) => controller.togglePromo(p.code) : null,
                  ),
                ),
                if (canManage)
                  AdaptiveColumn<PromoCode>(
                    label: '',
                    width: 44,
                    align: Alignment.centerRight,
                    build: (context, p) => IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                      tooltip: 'Delete promo',
                      onPressed: () => _confirmDelete(context, p.code),
                    ),
                  ),
              ],
            );
          }),
          Obx(() {
            final total = controller.filteredPromos.length;
            if (total == 0) return const SizedBox.shrink();
            return PaginationBar(
              page: controller.page.value,
              totalItems: total,
              pageSize: controller.pageSize.value,
              onPageChanged: (p) => controller.page.value = p,
              onPageSizeChanged: (s) {
                controller.pageSize.value = s;
                controller.page.value = 1;
              },
            );
          }),
        ],
      ),
    );
  }
}
