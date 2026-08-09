import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/models/avatar_item.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
import 'package:joba_admin/core/widgets/confirm_dialog.dart';
import 'package:joba_admin/core/widgets/empty_state.dart';
import 'package:joba_admin/core/widgets/page_header.dart';
import 'package:joba_admin/features/avatars/controllers/avatars_controller.dart';

class AvatarsScreen extends GetView<AvatarsController> {
  const AvatarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final list = controller.avatarsFor(controller.selectedCategoryId.value);
      return SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 14 : 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Responsive.contentMax),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'Avatar Management',
                  subtitle: 'Preset avatars shown in the app\'s profile picker',
                  actions: [
                    OutlinedButton.icon(
                      onPressed: () => _addCategoryDialog(context),
                      icon: const Icon(
                        Icons.create_new_folder_outlined,
                        size: 17,
                      ),
                      label: Responsive.isMobile(context)
                          ? const SizedBox()
                          : const Text('Add Category'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _uploadFlow(context),
                      icon: const Icon(Icons.upload_file_outlined, size: 17),
                      label: Responsive.isMobile(context)
                          ? const SizedBox()
                          : const Text('Upload Avatars'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 17,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Phase 1 shows the avatars bundled with the app. In Phase 3, uploads go to Firebase Storage and are served from the avatars collection.',
                          style: TextStyle(
                            color: context.palette.textSecondary,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
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
                          color: sel
                              ? Colors.white
                              : context.palette.textPrimary,
                        ),
                        onSelected: (_) => controller.selectCategory(c.id),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                if (list.isEmpty)
                  const Card(
                    child: EmptyState(
                      icon: Icons.face_outlined,
                      title: 'No avatars in this category',
                      subtitle: 'Use Upload Avatars to add the first one.',
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: Responsive.pick(
                        context,
                        mobile: 3,
                        tablet: 5,
                        desktop: 6,
                      ),
                      mainAxisExtent: 168,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: list.length,
                    itemBuilder: (_, i) => _avatarCard(context, list[i]),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _avatarCard(BuildContext context, AvatarItem a) {
    final palette = context.palette;
    final name = a.id.replaceAll(RegExp(r'\.(png|jpg|jpeg|webp)$'), '');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Opacity(
              opacity: a.active ? 1 : 0.35,
              child: AvatarCircle(
                name: name,
                assetPath: a.assetPath.isEmpty ? null : a.assetPath,
                bytes: a.pendingBytes,
                size: 74,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name.replaceAll('_', ' '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    a.active ? 'Active' : 'Hidden',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: a.active
                          ? AppColors.success
                          : palette.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ),
                Switch(
                  value: a.active,
                  activeThumbColor: AppColors.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (_) => controller.toggleActive(a.id),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  tooltip: 'Delete',
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: AppColors.danger,
                  ),
                  onPressed: () async {
                    final ok = await showConfirmDialog(
                      context,
                      title: 'Delete avatar?',
                      message:
                          'Users currently using this avatar will fall back to the default.',
                      confirmLabel: 'Delete',
                      danger: true,
                    );
                    if (ok) controller.remove(a.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadFlow(BuildContext context) async {
    final pal = context.palette;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final picked = result.files
        .where((f) => f.bytes != null)
        .map(
          (f) => controller.newItem(
            categoryId: controller.selectedCategoryId.value,
            bytes: f.bytes!,
          ),
        )
        .toList();
    if (picked.isEmpty) return;

    await Get.dialog<void>(
      Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Publish ${picked.length} avatar(s)?',
                  style: TextStyle(
                    color: pal.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'They will be added to "${controller.categories.firstWhereOrNull((c) => c.id == controller.selectedCategoryId.value)?.name ?? ''}" (mock until Phase 3).',
                  style: TextStyle(color: pal.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final p in picked)
                      AvatarCircle(name: p.id, bytes: p.pendingBytes, size: 56),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        controller.addPicked(picked);
                        Navigator.of(context).pop();
                        Get.snackbar(
                          'Avatars added',
                          '${picked.length} avatar(s) published (mock).',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      child: const Text('Publish'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addCategoryDialog(BuildContext context) {
    final name = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Avatar Category',
                  style: TextStyle(
                    color: context.palette.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: name,
                  decoration: const InputDecoration(
                    hintText: 'Category name (e.g. Cartoon)',
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        controller.addCategory(name.text);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
