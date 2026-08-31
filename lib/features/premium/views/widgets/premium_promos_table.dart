import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/adaptive_data_table.dart';
import 'package:joba_admin/features/premium/controllers/premium_controller.dart';
import 'package:joba_admin/features/premium/models/premium.dart';

/// Card containing the data table for active & inactive Promo Codes.
class PremiumPromosTable extends GetView<PremiumController> {
  const PremiumPromosTable({super.key});

  @override
  Widget build(BuildContext context) {
    final bool canManage = Get.isRegistered<AuthService>()
        ? Get.find<AuthService>().canManageContent
        : true;

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
                onChanged: canManage ? (_) => controller.togglePromo(p.code) : null,
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
              onChanged: canManage ? (_) => controller.togglePromo(p.code) : null,
            ),
          ),
        ],
      ),
    );
  }
}
