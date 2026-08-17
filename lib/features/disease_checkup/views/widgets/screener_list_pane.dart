import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/core/widgets/confirm_dialog.dart';
import 'package:joba_admin/features/disease_checkup/controllers/admin_screener_controller.dart';
import 'package:joba_admin/features/disease_checkup/views/widgets/screener_editor_dialog.dart';

class ScreenerListPane extends GetView<AdminScreenerController> {
  final bool isMobileDrillDown;

  const ScreenerListPane({super.key, this.isMobileDrillDown = false});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Add Screener Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Screening Tests',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    ScreenerEditorDialog.show(
                      context,
                      onSave: (screener, isNew) =>
                          controller.saveScreener(screener, isNew: isNew),
                    );
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Screener'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search and Status Filter on the SAME ROW
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => controller.searchQuery.value = val,
                    decoration: InputDecoration(
                      hintText: 'Search screeners...',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.2),
                        ),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 9,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Obx(
                  () => Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: palette.inputFill,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.statusFilter.value,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: palette.textPrimary,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All')),
                          DropdownMenuItem(
                            value: 'active',
                            child: Text('Active'),
                          ),
                          DropdownMenuItem(
                            value: 'inactive',
                            child: Text('Inactive'),
                          ),
                        ],
                        onChanged: (v) =>
                            controller.statusFilter.value = v ?? 'all',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),

          // List of Screeners with instant reactive selection
          Expanded(
            child: Obx(() {
              final list = controller.filteredScreeners;
              final selectedId = controller.selectedScreenerId.value;

              if (list.isEmpty) {
                return const Center(child: Text('No screeners found.'));
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: list.length,
                separatorBuilder: (ctx, idx) => const Divider(height: 1),
                itemBuilder: (ctx, index) {
                  final s = list[index];
                  final isSelected = selectedId == s.id;

                  return InkWell(
                    onTap: () {
                      controller.selectScreener(s);
                      if (isMobileDrillDown) {
                        controller.mobileTab.value = 1;
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.10)
                            : Colors.transparent,
                        border: Border(
                          left: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 4,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Screener Image / Icon
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.18)
                                  : AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: _buildScreenerImage(s.imagePath),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Titles & Clinical Source
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        s.nameEn,
                                        style: TextStyle(
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                          fontSize: 14,
                                          color: isSelected
                                              ? AppColors.primary
                                              : palette.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (!s.enabled)
                                      const PillBadge(
                                        label: 'Disabled',
                                        color: Colors.grey,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${s.nameBn} • ${s.source}',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: palette.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${s.activeQuestionsCount} questions • ${s.totalCompletions} checkups',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: palette.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // Selected Indicator Icon
                          if (isSelected)
                            const Padding(
                              padding: EdgeInsets.only(right: 6),
                              child: Icon(
                                Icons.check_circle,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),

                          // Quick Actions Menu
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 18),
                            tooltip: 'Actions',
                            onSelected: (val) async {
                              if (val == 'edit') {
                                ScreenerEditorDialog.show(
                                  context,
                                  screener: s,
                                  onSave: (updated, isNew) {
                                    controller.saveScreener(
                                      updated,
                                      isNew: isNew,
                                    );
                                  },
                                );
                              } else if (val == 'toggle') {
                                controller.toggleScreenerActive(
                                  s.id,
                                  !s.enabled,
                                );
                              } else if (val == 'delete') {
                                final confirmed = await showConfirmDialog(
                                  context,
                                  title: 'Delete Screener',
                                  message:
                                      'Are you sure you want to delete "${s.nameEn}" and its questionnaires?',
                                  confirmLabel: 'Delete',
                                  danger: true,
                                );
                                if (confirmed) {
                                  controller.deleteScreener(s.id);
                                }
                              }
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 16),
                                    SizedBox(width: 8),
                                    Text('Edit Screener'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'toggle',
                                child: Row(
                                  children: [
                                    Icon(
                                      s.enabled
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 16,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      s.enabled ? 'Deactivate' : 'Activate',
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      size: 16,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenerImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width: 22,
        height: 22,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.health_and_safety_outlined,
          color: AppColors.primary,
          size: 18,
        ),
      );
    } else if (imagePath.isNotEmpty) {
      return Image.asset(
        imagePath,
        width: 22,
        height: 22,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.health_and_safety_outlined,
          color: AppColors.primary,
          size: 18,
        ),
      );
    }
    return const Icon(
      Icons.health_and_safety_outlined,
      color: AppColors.primary,
      size: 18,
    );
  }
}
