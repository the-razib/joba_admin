import 'dart:async';
import 'package:flutter/material.dart';
import 'package:joba_admin/core/utils/app_toast.dart';
import 'package:joba_admin/features/disease_checkup/models/screener_admin_model.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/widgets/bilingual_text_field.dart';
import 'package:joba_admin/core/widgets/image_upload_field.dart';

class ScreenerEditorDialog extends StatefulWidget {
  final ScreenerAdminModel? initialScreener;
  final FutureOr<void> Function(ScreenerAdminModel screener, bool isNew) onSave;

  const ScreenerEditorDialog({
    super.key,
    this.initialScreener,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    ScreenerAdminModel? screener,
    required FutureOr<void> Function(ScreenerAdminModel screener, bool isNew)
    onSave,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          ScreenerEditorDialog(initialScreener: screener, onSave: onSave),
    );
  }

  @override
  State<ScreenerEditorDialog> createState() => _ScreenerEditorDialogState();
}

class _ScreenerEditorDialogState extends State<ScreenerEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _idCtrl;
  late final TextEditingController _nameBnCtrl;
  late final TextEditingController _nameEnCtrl;
  late final TextEditingController _subBnCtrl;
  late final TextEditingController _subEnCtrl;
  late final TextEditingController _sourceCtrl;
  late final TextEditingController _imagePathCtrl;
  late bool _enabled;
  late bool _isNew;
  ImagePick? _pickedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.initialScreener;
    _isNew = s == null;
    _idCtrl = TextEditingController(text: s?.id ?? '');
    _nameBnCtrl = TextEditingController(text: s?.nameBn ?? '');
    _nameEnCtrl = TextEditingController(text: s?.nameEn ?? '');
    _subBnCtrl = TextEditingController(text: s?.subtitleBn ?? '');
    _subEnCtrl = TextEditingController(text: s?.subtitleEn ?? '');
    _sourceCtrl = TextEditingController(text: s?.source ?? '');
    _imagePathCtrl = TextEditingController(text: s?.imagePath ?? '');
    _enabled = s?.enabled ?? true;
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _nameBnCtrl.dispose();
    _nameEnCtrl.dispose();
    _subBnCtrl.dispose();
    _subEnCtrl.dispose();
    _sourceCtrl.dispose();
    _imagePathCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    if (_nameBnCtrl.text.trim().isEmpty || _nameEnCtrl.text.trim().isEmpty) {
      AppToast.warning(
        'Missing title',
        'Both বাংলা and English names are required.',
      );
      return;
    }
    if (_isNew && _idCtrl.text.trim().isEmpty) {
      AppToast.warning(
        'Missing ID',
        'Screener ID is required.',
      );
      return;
    }

    final initial = widget.initialScreener;
    final id = _isNew
        ? _idCtrl.text.trim().toLowerCase().replaceAll(' ', '_')
        : initial!.id;
    final defaultTiers = initial?.riskTiers.isNotEmpty == true
        ? initial!.riskTiers
        : _defaultRiskTiers;
    final screener = ScreenerAdminModel(
      id: id,
      nameBn: _nameBnCtrl.text.trim(),
      nameEn: _nameEnCtrl.text.trim(),
      subtitleBn: _subBnCtrl.text.trim(),
      subtitleEn: _subEnCtrl.text.trim(),
      source: _sourceCtrl.text.trim(),
      imagePath: _pickedImage?.path ?? _imagePathCtrl.text.trim(),
      accentColorHex: initial?.accentColorHex ?? '#E65671',
      displayOrder: initial?.displayOrder ?? 0,
      enabled: _enabled,
      questions: initial?.questions ?? const [],
      riskTiers: defaultTiers,
      totalCompletions: initial?.totalCompletions ?? 0,
      createdAt: initial?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() => _isSaving = true);
    await widget.onSave(screener, _isNew);
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
                            _isNew ? 'New Health Screener' : 'Edit Screener',
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
                      'Configure diagnostic screener title, clinical guidelines, and illustration/icon.',
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
                            if (_isNew) ...[
                              Text(
                                'Screener ID *',
                                style: TextStyle(
                                  color: palette.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _idCtrl,
                                decoration: const InputDecoration(
                                  hintText: 'e.g. pcos, endometriosis, thyroid',
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            BilingualField(
                              label: 'Screener Name *',
                              bnController: _nameBnCtrl,
                              enController: _nameEnCtrl,
                              hintBn: 'নাম (যেমন: PCOS স্ক্রিনার)',
                              hintEn: 'Screener name (e.g. PCOS Screener)',
                            ),
                            const SizedBox(height: 16),
                            BilingualField(
                              label: 'Subtitle / Overview',
                              bnController: _subBnCtrl,
                              enController: _subEnCtrl,
                              hintBn:
                                  'অনিয়মিত পিরিয়ড বা হরমোনজনিত লক্ষণ যাচাই করুন…',
                              hintEn:
                                  'Screen for irregular periods and hormonal imbalance…',
                              maxLines: 2,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Clinical Guideline Reference',
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _sourceCtrl,
                              decoration: const InputDecoration(
                                hintText:
                                    'e.g. Rotterdam Criteria, ESHRE, DSM-5, NICE Guidelines',
                              ),
                            ),
                            const SizedBox(height: 16),
                            ImageUploadField(
                              label: 'Screener Illustration / Icon (SVG / PNG)',
                              currentPath: _imagePathCtrl.text.isNotEmpty
                                  ? _imagePathCtrl.text
                                  : null,
                              height: 110,
                              onChanged: (pick) {
                                setState(() {
                                  _pickedImage = pick;
                                  _imagePathCtrl.text = pick?.path ?? '';
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: palette.inputFill,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: palette.border),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Published & Visible in App',
                                          style: TextStyle(
                                            color: palette.textPrimary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          _enabled
                                              ? 'Active for all mobile users'
                                              : 'Hidden / Inactive draft',
                                          style: TextStyle(
                                            color: palette.textSecondary,
                                            fontSize: 11.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: _enabled,
                                    activeThumbColor: AppColors.primary,
                                    onChanged: _isSaving
                                        ? null
                                        : (v) => setState(() => _enabled = v),
                                  ),
                                ],
                              ),
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
                              : Text(
                                  _isNew ? 'Create Screener' : 'Save Changes',
                                ),
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

  static const _defaultRiskTiers = [
    RiskTierAdminConfig(
      key: RiskTierKey.low,
      labelBn: 'স্বাভাবিক পরিসীমা',
      labelEn: 'Low Risk / Normal Range',
      descriptionBn:
          'আপনার নির্বাচিত উত্তরগুলোতে উল্লেখযোগ্য কোনো ঝুঁকির লক্ষণ পাওয়া যায়নি।',
      descriptionEn:
          'No significant risk indicators found. Continue regular cycle tracking.',
      colorHex: '#5FA873',
      minRatio: 0.0,
      maxRatio: 0.33,
    ),
    RiskTierAdminConfig(
      key: RiskTierKey.moderate,
      labelBn: 'মাঝারি ইঙ্গিত',
      labelEn: 'Moderate Indication',
      descriptionBn: 'কিছু লক্ষণ মিলেছে। উপসর্গগুলো পর্যবেক্ষণ করুন।',
      descriptionEn:
          'Some symptoms matched. Track symptom timeline and consult a doctor.',
      colorHex: '#FFC96B',
      minRatio: 0.34,
      maxRatio: 0.66,
    ),
    RiskTierAdminConfig(
      key: RiskTierKey.high,
      labelBn: 'লক্ষণীয় ইঙ্গিত',
      labelEn: 'High Indication',
      descriptionBn: 'একাধিক লক্ষণ মিলেছে। বিশেষজ্ঞ ডাক্তারের পরামর্শ নিন।',
      descriptionEn:
          'Multiple key indicators matched. Clinical evaluation is strongly recommended.',
      colorHex: '#FF7B88',
      minRatio: 0.67,
      maxRatio: 1.0,
    ),
  ];
}
