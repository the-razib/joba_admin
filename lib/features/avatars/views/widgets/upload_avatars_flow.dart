import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
import 'package:joba_admin/features/avatars/controllers/avatars_controller.dart';

/// Opens FilePicker and presents the upload confirmation preview dialog.
Future<void> uploadAvatarsFlow(BuildContext context) async {
  final controller = Get.find<AvatarsController>();
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
