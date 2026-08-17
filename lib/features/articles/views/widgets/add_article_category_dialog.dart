import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/features/articles/controllers/articles_controller.dart';

/// Modal dialog for adding a new bilingual article category.
class AddArticleCategoryDialog extends StatefulWidget {
  const AddArticleCategoryDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const AddArticleCategoryDialog(),
    );
  }

  @override
  State<AddArticleCategoryDialog> createState() =>
      _AddArticleCategoryDialogState();
}

class _AddArticleCategoryDialogState extends State<AddArticleCategoryDialog> {
  final _bnController = TextEditingController();
  final _enController = TextEditingController();

  @override
  void dispose() {
    _bnController.dispose();
    _enController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ArticlesController>();

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Category',
                style: TextStyle(
                  color: context.palette.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _bnController,
                style: AppTheme.bengali(context),
                decoration: const InputDecoration(hintText: 'নাম (বাংলা)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _enController,
                decoration: const InputDecoration(hintText: 'Name (English)'),
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
                      if (_bnController.text.trim().isEmpty ||
                          _enController.text.trim().isEmpty) {
                        return;
                      }
                      controller.addCategory(
                        nameBn: _bnController.text.trim(),
                        nameEn: _enController.text.trim(),
                      );
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
    );
  }
}
