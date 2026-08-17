import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/models/screener_admin_model.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/widgets/bilingual_text_field.dart';

class RiskTierEditorDialog extends StatefulWidget {
  final RiskTierAdminConfig tier;
  final Future<void> Function(RiskTierAdminConfig updatedTier) onSave;

  const RiskTierEditorDialog({
    super.key,
    required this.tier,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required RiskTierAdminConfig tier,
    required Future<void> Function(RiskTierAdminConfig updatedTier) onSave,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => RiskTierEditorDialog(tier: tier, onSave: onSave),
    );
  }

  @override
  State<RiskTierEditorDialog> createState() => _RiskTierEditorDialogState();
}

class _RiskTierEditorDialogState extends State<RiskTierEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelBnCtrl;
  late final TextEditingController _labelEnCtrl;
  late final TextEditingController _descBnCtrl;
  late final TextEditingController _descEnCtrl;
  late final TextEditingController _colorCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.tier;
    _labelBnCtrl = TextEditingController(text: t.labelBn);
    _labelEnCtrl = TextEditingController(text: t.labelEn);
    _descBnCtrl = TextEditingController(text: t.descriptionBn);
    _descEnCtrl = TextEditingController(text: t.descriptionEn);
    _colorCtrl = TextEditingController(text: t.colorHex);
  }

  @override
  void dispose() {
    _labelBnCtrl.dispose();
    _labelEnCtrl.dispose();
    _descBnCtrl.dispose();
    _descEnCtrl.dispose();
    _colorCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    if (_labelBnCtrl.text.trim().isEmpty || _labelEnCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Missing label',
        'Both বাংলা and English tier labels are required.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (_descBnCtrl.text.trim().isEmpty || _descEnCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Missing guidance',
        'Both বাংলা and English clinical advice texts are required.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final updated = widget.tier.copyWith(
      labelBn: _labelBnCtrl.text.trim(),
      labelEn: _labelEnCtrl.text.trim(),
      descriptionBn: _descBnCtrl.text.trim(),
      descriptionEn: _descEnCtrl.text.trim(),
      colorHex: _colorCtrl.text.trim(),
    );
    setState(() => _isSaving = true);
    await widget.onSave(updated);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final media = MediaQuery.of(context);
    final compact = media.size.width < 520;
    return PopScope(
      canPop: !_isSaving,
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 40,
          vertical: compact ? 16 : 24,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 580,
            maxHeight: media.size.height - (compact ? 32 : 48),
          ),
          child: Padding(
            padding: EdgeInsets.all(compact ? 16 : 24),
            child: Form(
              key: _formKey,
              child: AbsorbPointer(
                absorbing: _isSaving,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Risk Tier & Doctor Guidance: ${widget.tier.labelEn}',
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: _isSaving
                              ? null
                              : () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Set the risk meter score ratio threshold and doctor consultation guidance shown to users.',
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BilingualField(
                              label: 'Risk Tier Label *',
                              bnController: _labelBnCtrl,
                              enController: _labelEnCtrl,
                              hintBn:
                                  'লেবেল (যেমন: স্বাভাবিক পরিসীমা, মাঝারি ইঙ্গিত, লক্ষণীয় ইঙ্গিত)',
                              hintEn:
                                  'Label (e.g. Low Risk, Moderate Indication, High Indication)',
                            ),
                            const SizedBox(height: 16),
                            BilingualField(
                              label: 'Doctor Summary & Clinical Guidance *',
                              bnController: _descBnCtrl,
                              enController: _descEnCtrl,
                              hintBn:
                                  'ব্যবহারকারীর ফলাফলের উপর ভিত্তি করে ডাক্তারের পরামর্শ ও পরবর্তী পদক্ষেপ…',
                              hintEn:
                                  'Empathetic clinical guidance, lifestyle recommendations, and doctor consultation advice…',
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final color = _buildColorField(palette);
                                final ratio = _buildRatioField(palette);
                                if (constraints.maxWidth < 520) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      color,
                                      const SizedBox(height: 14),
                                      ratio,
                                    ],
                                  );
                                }
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: color),
                                    const SizedBox(width: 14),
                                    Expanded(child: ratio),
                                  ],
                                );
                              },
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
                          onPressed: _isSaving
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isSaving ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Save Guidance'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorField(AppPalette palette) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Badge / Gauge Hex Color',
        style: TextStyle(
          color: palette.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 6),
      TextFormField(
        controller: _colorCtrl,
        decoration: const InputDecoration(
          hintText: 'e.g. #5FA873, #FFC96B, #FF7B88',
        ),
      ),
    ],
  );

  Widget _buildRatioField(AppPalette palette) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Risk Gauge Threshold',
        style: TextStyle(
          color: palette.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: palette.inputFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: palette.border),
        ),
        child: Text(
          '${(widget.tier.minRatio * 100).toInt()}% - ${(widget.tier.maxRatio * 100).toInt()}% Score Ratio',
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}
