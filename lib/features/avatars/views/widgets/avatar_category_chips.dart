import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/features/avatars/controllers/avatars_controller.dart';

/// Horizontal list of category filter chips with badge counters for avatar categories.
class AvatarCategoryChips extends GetView<AvatarsController> {
  const AvatarCategoryChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: controller.categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final c = controller.categories[i];
            final sel = controller.selectedCategoryId.value == c.id;
            return FilterChip(
              selected: sel,
              avatar: Text(
                '${controller.countFor(c.id)}',
                style: TextStyle(
                  fontSize: 11,
                  color: sel ? Colors.white : AppColors.primary,
                ),
              ),
              label: Text(
                c.name,
                style: const TextStyle(fontSize: 12.5),
              ),
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: sel ? Colors.white : context.palette.textPrimary,
              ),
              onSelected: (_) => controller.selectCategory(c.id),
            );
          },
        ),
      ),
    );
  }
}
