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
    return Obx(() {
      final selectedId = controller.selectedCategoryId.value;
      return SizedBox(
        height: 40,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final c in controller.categories) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    key: ValueKey(c.id),
                    selected: selectedId == c.id,
                    showCheckmark: false,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    avatar: Text(
                      '${controller.countFor(c.id)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: selectedId == c.id
                            ? Colors.white
                            : AppColors.primary,
                      ),
                    ),
                    label: Text(
                      c.name,
                      style: const TextStyle(fontSize: 12.5),
                    ),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: selectedId == c.id
                          ? Colors.white
                          : context.palette.textPrimary,
                    ),
                    onSelected: (_) => controller.selectCategory(c.id),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}
