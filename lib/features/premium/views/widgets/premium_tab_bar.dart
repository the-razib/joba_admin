import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/features/premium/controllers/premium_controller.dart';

/// Tab selector for switching between Premium Users, Promo Codes, and Transactions.
class PremiumTabBar extends GetView<PremiumController> {
  const PremiumTabBar({super.key});

  static const tabLabels = ['Premium Users', 'Promo Codes', 'Transactions'];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: context.palette.inputFill,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < tabLabels.length; i++)
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
                      tabLabels[i],
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
      ),
    );
  }
}
