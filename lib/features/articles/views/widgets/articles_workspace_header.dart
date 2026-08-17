import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/features/articles/controllers/articles_controller.dart';

/// Top header bar for the articles module with tab switcher (Articles / Categories & Tags) and Add Article button.
class ArticlesWorkspaceHeader extends GetView<ArticlesController> {
  const ArticlesWorkspaceHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          _TabToggle(
            labels: const ['Articles', 'Categories & Tags'],
            selected: controller.tab.value,
            onSelected: (i) => controller.tab.value = i,
          ),
          const Spacer(),
          if (controller.tab.value == 0)
            ElevatedButton.icon(
              onPressed: controller.startAdd,
              icon: const Icon(Icons.add, size: 17),
              label: Responsive.isMobile(context)
                  ? const SizedBox()
                  : const Text('Add Article'),
            ),
        ],
      ),
    );
  }
}

class _TabToggle extends StatelessWidget {
  const _TabToggle({
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              onTap: () => onSelected(i),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected == i
                      ? context.palette.card
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: selected == i
                        ? AppColors.primary
                        : context.palette.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
