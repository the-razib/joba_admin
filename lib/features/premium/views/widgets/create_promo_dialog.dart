import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/app_toast.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/features/premium/controllers/premium_controller.dart';
import 'package:joba_admin/features/premium/models/premium.dart';

/// Modal dialog for creating and activating a new promo code with validation and expiry picker.
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
  final _percentController = TextEditingController(text: '20');
  DateTime _expiresAt = DateTime.now().add(const Duration(days: 30));
  bool _isSubmitting = false;

  @override
  void dispose() {
    _codeController.dispose();
    _percentController.dispose();
    super.dispose();
  }

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiresAt.isAfter(now) ? _expiresAt : now.add(const Duration(days: 30)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() {
        _expiresAt = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
      });
    }
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      AppToast.error('Validation Error', 'Please enter a promo code.');
      return;
    }

    final percent = int.tryParse(_percentController.text.trim()) ?? 0;
    if (percent < 1 || percent > 100) {
      AppToast.error('Validation Error', 'Discount percent must be between 1% and 100%.');
      return;
    }

    if (_expiresAt.isBefore(DateTime.now())) {
      AppToast.error('Validation Error', 'Expiry date must be in the future.');
      return;
    }

    setState(() => _isSubmitting = true);

    final controller = Get.find<PremiumController>();
    final success = await controller.addPromo(
      PromoCode(
        code: code,
        percentOff: percent,
        expiresAt: _expiresAt,
        active: true,
        usedCount: 0,
      ),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create Promo Code',
                    style: TextStyle(
                      color: context.palette.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Promo Code',
                  hintText: 'e.g. EID2026, SUMMER50',
                  prefixIcon: Icon(Icons.local_offer_outlined, size: 18),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _percentController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Discount Percentage (%)',
                  hintText: '20',
                  prefixIcon: Icon(Icons.percent_outlined, size: 18),
                  suffixText: '%',
                ),
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: _pickExpiryDate,
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Valid Until',
                    prefixIcon: Icon(Icons.event_outlined, size: 18),
                    suffixIcon: Icon(Icons.calendar_today, size: 16),
                  ),
                  child: Text(
                    formatDate(_expiresAt),
                    style: TextStyle(
                      color: context.palette.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Create Promo'),
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
