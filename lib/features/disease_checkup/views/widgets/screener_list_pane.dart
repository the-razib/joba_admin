import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/widgets/confirm_dialog.dart';
import 'package:joba_admin/features/disease_checkup/controllers/admin_screener_controller.dart';
import 'package:joba_admin/features/disease_checkup/models/screener_admin_model.dart';
import 'package:joba_admin/features/disease_checkup/views/widgets/screener_editor_dialog.dart';

class ScreenerListPane extends GetView<AdminScreenerController> {
  final bool isMobileDrillDown;

  const ScreenerListPane({super.key, this.isMobileDrillDown = false});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final bool canManage = Get.isRegistered<AuthService>()
        ? Get.find<AuthService>().canManageContent
        : true;
    final bool isSuper = Get.isRegistered<AuthService>()
        ? Get.find<AuthService>().canManageAdmins
        : true;

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
                if (canManage) ...[
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScreenerEditorDialog.show(
                        context,
                        onSave: (screener, isNew, {imageBytes, imageName}) =>
                            controller.saveScreener(
                          screener,
                          isNew: isNew,
                          imageBytes: imageBytes,
                          imageName: imageName,
                        ),
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

          // List of Screeners with instant reactive selection & drag-and-drop reordering
          Expanded(
            child: Obx(() {
              final list = controller.filteredScreeners;
              final selectedId = controller.selectedScreenerId.value;

              if (list.isEmpty) {
                return const Center(child: Text('No screeners found.'));
              }

              final isReorderable =
                  controller.searchQuery.value.trim().isEmpty &&
                  controller.statusFilter.value == 'all';

              if (isReorderable) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: list.length,
                    onReorder: (oldIndex, newIndex) {
                      controller.reorderScreeners(oldIndex, newIndex);
                    },
                    itemBuilder: (ctx, index) {
                      final s = list[index];
                      final isSelected = selectedId == s.id;
                      return _buildScreenerItem(
                        context,
                        s,
                        isSelected: isSelected,
                        index: index,
                        canManage: canManage,
                        isSuper: isSuper,
                        isReorderable: true,
                      );
                    },
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: list.length,
                separatorBuilder: (ctx, idx) => const Divider(height: 1),
                itemBuilder: (ctx, index) {
                  final s = list[index];
                  final isSelected = selectedId == s.id;
                  return _buildScreenerItem(
                    context,
                    s,
                    isSelected: isSelected,
                    index: index,
                    canManage: canManage,
                    isSuper: isSuper,
                    isReorderable: false,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenerItem(
    BuildContext context,
    ScreenerAdminModel s, {
    required bool isSelected,
    required int index,
    required bool canManage,
    required bool isSuper,
    required bool isReorderable,
  }) {
    final palette = context.palette;
    return Container(
      key: ValueKey(s.id),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.16)
            : Colors.transparent,
        border: Border(
          left: BorderSide(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 4.5,
          ),
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: InkWell(
        onTap: () {
          controller.selectScreener(s);
          if (isMobileDrillDown) {
            controller.mobileTab.value = 1;
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          child: Row(
            children: [
              // Drag handle for serial arrangement
              if (isReorderable)
                ReorderableDragStartListener(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(
                      Icons.drag_indicator,
                      size: 18,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),

              // Serial Index Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.22)
                      : Colors.grey.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '#${index + 1}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? AppColors.primary
                        : palette.textSecondary,
                  ),
                ),
              ),

              // Screener Image / Icon (Clean container without forced background if image is uploaded)
              _buildScreenerImageContainer(s, isSelected),
              const SizedBox(width: 10),

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
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.amber.shade400,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              'Inactive',
                              style: TextStyle(
                                color: Colors.amber.shade900,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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

              // Quick Actions Menu
              if (canManage)
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    size: 18,
                    color: Colors.grey,
                  ),
                  onSelected: (val) async {
                    if (val == 'edit') {
                      ScreenerEditorDialog.show(
                        context,
                        screener: s,
                        onSave: (screener, isNew, {imageBytes, imageName}) =>
                            controller.saveScreener(
                          screener,
                          isNew: isNew,
                          imageBytes: imageBytes,
                          imageName: imageName,
                        ),
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
                    if (isSuper)
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
      ),
    );
  }

  Widget _buildScreenerImageContainer(ScreenerAdminModel s, bool isSelected) {
    final hasCustomImage = s.imagePath.trim().isNotEmpty;
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: hasCustomImage
            ? Colors.transparent
            : (isSelected
                ? AppColors.primary.withValues(alpha: 0.18)
                : AppColors.primary.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(10),
        border: hasCustomImage
            ? Border.all(
                color: Colors.grey.withValues(alpha: 0.22),
                width: 1,
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: _buildScreenerImage(s.imagePath),
      ),
    );
  }

  Widget _buildScreenerImage(String imagePath) {
    final trimmed = imagePath.trim();
    if (trimmed.startsWith('http')) {
      return Image.network(
        trimmed,
        width: 38,
        height: 38,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(
            Icons.health_and_safety_outlined,
            color: AppColors.primary,
            size: 18,
          ),
        ),
      );
    } else if (trimmed.isNotEmpty) {
      return Image.asset(
        trimmed,
        width: 38,
        height: 38,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(
            Icons.health_and_safety_outlined,
            color: AppColors.primary,
            size: 18,
          ),
        ),
      );
    }
    return const Center(
      child: Icon(
        Icons.health_and_safety_outlined,
        color: AppColors.primary,
        size: 18,
      ),
    );
  }
}
