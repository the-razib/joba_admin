import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/utils/app_toast.dart';
import 'package:joba_admin/features/premium/models/premium.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/features/premium/controllers/premium_controller.dart';

/// Modal dialog for creating and activating a new promo code.
class CreatePromoDialog extends StatefulWidget {
  const CreatePromoDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const CreatePromoDialog(),
    );
  }

  @override
  State<CreatePromoDialog> createState() => _CreatePromoDialogState();
}

class _CreatePromoDialogState extends State<CreatePromoDialog> {
  final _codeController = TextEditingController();
  final _percentController = TextEditingController(text: '10');

  @override
  void dispose() {
    _codeController.dispose();
    _percentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PremiumController>();

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
                'Create Promo Code',
                style: TextStyle(
                  color: context.palette.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(hintText: 'CODE'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _percentController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Discount %'),
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
                      final code = _codeController.text.trim().toUpperCase();
                      final percent = int.tryParse(_percentController.text) ?? 0;
                      if (code.isEmpty || percent <= 0) return;

                      controller.addPromo(
                        PromoCode(
                          code: code,
                          percentOff: percent,
                          expiresAt: DateTime.now().add(
                            const Duration(days: 30),
                          ),
                        ),
                      );
                      Navigator.of(context).pop();
                      AppToast.success(
                        'Promo created',
                        '$code ($percent% off) is live (mock).',
                      );
                    },
                    child: const Text('Create'),
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
