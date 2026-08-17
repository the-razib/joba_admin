import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/core/widgets/confirm_dialog.dart';
import 'package:joba_admin/features/disease_checkup/controllers/admin_screener_controller.dart';
import 'package:joba_admin/features/disease_checkup/views/widgets/screener_editor_dialog.dart';

class ScreenerListPane extends GetView<AdminScreenerController> {
  final bool isMobileDrillDown;

  const ScreenerListPane({super.key, this.isMobileDrillDown = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Add Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 360;
                const title = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Screening Tests',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                );
                final addButton = ElevatedButton.icon(
                  onPressed: () {
                    ScreenerEditorDialog.show(
                      context,
                      onSave: (screener, isNew) =>
                          controller.saveScreener(screener, isNew: isNew),
                    );
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Test'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                );
                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: title,
                      ),
                      const SizedBox(height: 10),
                      Align(alignment: Alignment.centerRight, child: addButton),
                    ],
                  );
                }
                return Row(
                  children: [
                    const Expanded(child: title),
                    const SizedBox(width: 8),
                    addButton,
                  ],
                );
              },
            ),
          ),

          // Search & Filter Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final search = TextField(
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                );
                final filter = Obx(
                  () => DropdownButton<String>(
                    value: controller.statusFilter.value,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All')),
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(
                        value: 'inactive',
                        child: Text('Inactive'),
                      ),
                    ],
                    onChanged: (v) =>
                        controller.statusFilter.value = v ?? 'all',
                  ),
                );
                if (constraints.maxWidth < 330) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      search,
                      const SizedBox(height: 8),
                      Align(alignment: Alignment.centerRight, child: filter),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: search),
                    const SizedBox(width: 8),
                    filter,
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),

          // List of Screeners
          Expanded(
            child: Obx(() {
              final list = controller.filteredScreeners;
              if (list.isEmpty) {
                return const Center(child: Text('No screeners found.'));
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: list.length,
                separatorBuilder: (ctx, idx) => const Divider(height: 1),
                itemBuilder: (ctx, index) {
                  final s = list[index];
                  final isSelected =
                      controller.selectedScreener.value?.id == s.id;

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
                            ? AppColors.primary.withValues(alpha: 0.06)
                            : Colors.transparent,
                        border: Border(
                          left: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Icon / Image
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
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
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 2,
                                  children: [
                                    Text(
                                      '${s.activeQuestionsCount} questions',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    Text(
                                      '${s.totalCompletions} checkups',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
                                  onSave: (updated, isNew) => controller
                                      .saveScreener(updated, isNew: isNew),
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
                                    Text('Edit Metadata'),
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
                                    Text(s.enabled ? 'Disable' : 'Enable'),
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
