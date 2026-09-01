import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/features/articles/controllers/articles_controller.dart';

/// Top header bar for the articles module with tab switcher (Articles / Categories & Tags) and Add Article button.
class ArticlesWorkspaceHeader extends GetView<ArticlesController> {
  const ArticlesWorkspaceHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final bool canManage = Get.isRegistered<AuthService>()
        ? Get.find<AuthService>().canManageContent
        : true;
    final mobile = Responsive.isMobile(context);

    if (mobile) {
      return Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TabToggle(
              labels: const ['Articles', 'Categories & Tags'],
              selected: controller.tab.value,
              onSelected: (i) => controller.tab.value = i,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => controller.refreshData(),
                  icon: const Icon(Icons.refresh_outlined, size: 16),
                  label: const Text('Refresh'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
                const Spacer(),
                if (controller.tab.value == 0 && canManage)
                  ElevatedButton.icon(
                    onPressed: controller.startAdd,
                    icon: const Icon(Icons.add, size: 17),
                    label: const Text('Add Article'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    return Obx(
      () => Row(
        children: [
          _TabToggle(
            labels: const ['Articles', 'Categories & Tags'],
            selected: controller.tab.value,
            onSelected: (i) => controller.tab.value = i,
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () => controller.refreshData(),
            icon: const Icon(Icons.refresh_outlined, size: 16),
            label: const Text('Refresh'),
          ),
          if (controller.tab.value == 0 && canManage) ...[
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: controller.startAdd,
              icon: const Icon(Icons.add, size: 17),
              label: const Text('Add Article'),
            ),
          ],
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
    final mobile = Responsive.isMobile(context);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.palette.inputFill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: mobile ? MainAxisSize.max : MainAxisSize.min,
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (mobile)
              Expanded(
                child: _buildItem(context, i),
              )
            else
              _buildItem(context, i),
          ],
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, int i) {
    final mobile = Responsive.isMobile(context);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => onSelected(i),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          horizontal: mobile ? 6 : 14,
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
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: mobile ? 11.5 : 12.5,
            fontWeight: FontWeight.w600,
            color: selected == i
                ? AppColors.primary
                : context.palette.textSecondary,
          ),
        ),
      ),
    );
  }
}
