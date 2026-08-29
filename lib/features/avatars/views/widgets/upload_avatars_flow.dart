import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/repositories/avatar_repository.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
import 'package:joba_admin/features/avatars/controllers/avatars_controller.dart';

Future<void> uploadAvatarsFlow(BuildContext context) async {
  final controller = Get.find<AvatarsController>();
  final result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    type: FileType.custom,
    allowedExtensions: const ['png', 'jpg', 'jpeg', 'webp'],
    withData: true,
  );

  if (result == null || result.files.isEmpty) return;

  final uploadItems = result.files
      .where((f) => f.bytes != null)
      .map(
        (f) => AvatarUploadItem(
          id: f.name.replaceAll(RegExp(r'\.(png|jpg|jpeg|webp)$'), ''),
          filename: f.name,
          bytes: f.bytes!,
        ),
      )
      .toList();

  if (!context.mounted || uploadItems.isEmpty) return;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Obx(() {
              final isUploading = controller.uploading.value;

              if (isUploading) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Uploading to Firebase Storage...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Publishing ${uploadItems.length} avatar(s). Please wait...',
                        style: const TextStyle(
                          color: AppColors.textSecondaryLight,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final currentCategory = controller.categories.firstWhereOrNull(
                (c) => c.id == controller.selectedCategoryId.value,
              );

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Publish ${uploadItems.length} avatar(s)?',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'They will be uploaded to Firebase Storage and added to "${currentCategory?.name ?? 'Category'}".',
                    style: const TextStyle(
                      color: AppColors.textSecondaryLight,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final item in uploadItems)
                            AvatarCircle(
                              name: item.id,
                              bytes: item.bytes,
                              size: 56,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final catId = controller.selectedCategoryId.value;
                          await controller.uploadBatch(catId, uploadItems);
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        },
                        child: const Text('Publish'),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ),
      );
    },
  );
}
