import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/models/screener_admin_model.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/widgets/bilingual_text_field.dart';

class QuestionEditorDialog extends StatefulWidget {
  final ScreenerQuestionAdmin? initialQuestion;
  final Future<void> Function(ScreenerQuestionAdmin question, bool isNew)
  onSave;

  const QuestionEditorDialog({
    super.key,
    this.initialQuestion,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    ScreenerQuestionAdmin? question,
    required Future<void> Function(ScreenerQuestionAdmin question, bool isNew)
    onSave,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          QuestionEditorDialog(initialQuestion: question, onSave: onSave),
    );
  }

  @override
  State<QuestionEditorDialog> createState() => _QuestionEditorDialogState();
}

class _QuestionEditorDialogState extends State<QuestionEditorDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _bnCtrl;
  late final TextEditingController _enCtrl;
  late int _points;
  late bool _isActive;
  late bool _isNew;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final q = widget.initialQuestion;
    _isNew = q == null;

    _bnCtrl = TextEditingController(text: q?.questionBn ?? '');
    _enCtrl = TextEditingController(text: q?.questionEn ?? '');
    _points = q?.points ?? 1;
    _isActive = q?.isActive ?? true;
  }

  @override
  void dispose() {
    _bnCtrl.dispose();
    _enCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    if (_bnCtrl.text.trim().isEmpty || _enCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Missing question text',
        'Both বাংলা and English question texts are required.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final id =
        widget.initialQuestion?.id ??
        'q_${DateTime.now().millisecondsSinceEpoch}';

    final question = ScreenerQuestionAdmin(
      id: id,
      questionBn: _bnCtrl.text.trim(),
      questionEn: _enCtrl.text.trim(),
      points: _points,
      order: widget.initialQuestion?.order ?? 0,
      isActive: _isActive,
    );

    setState(() => _isSaving = true);
    await widget.onSave(question, _isNew);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final media = MediaQuery.of(context);
    final compact = media.size.width < 520;
    final padding = compact ? 16.0 : 24.0;

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
            padding: EdgeInsets.all(padding),
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
                            _isNew ? 'Add Symptom Question' : 'Edit Question',
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
                      'Write clear, clinical symptom criteria for self-assessment in both languages.',
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
                              label: 'Symptom Question Text *',
                              bnController: _bnCtrl,
                              enController: _enCtrl,
                              hintBn:
                                  'লক্ষণভিত্তিক প্রশ্ন লিখুন… (যেমন: মাসিক চক্র অনিয়মিত)',
                              hintEn:
                                  'Clinical symptom statement (e.g. Irregular menstrual cycle)',
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final stack = constraints.maxWidth < 520;
                                final pointsField = _buildPointsField(palette);
                                final statusField = _buildStatusField(palette);
                                if (stack) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      pointsField,
                                      const SizedBox(height: 14),
                                      statusField,
                                    ],
                                  );
                                }
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: pointsField),
                                    const SizedBox(width: 14),
                                    Expanded(child: statusField),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        TextButton(
                          onPressed: _isSaving
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
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
                              : Text(_isNew ? 'Add Question' : 'Save Question'),
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

  Widget _buildPointsField(AppPalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Symptom Weight / Points',
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<int>(
          initialValue: _points,
          decoration: const InputDecoration(),
          dropdownColor: palette.card,
          borderRadius: BorderRadius.circular(12),
          menuMaxHeight: 220,
          elevation: 8,
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          isExpanded: true,
          selectedItemBuilder: (context) => const [
            Align(
              alignment: Alignment.centerLeft,
              child: Text('1 Point', overflow: TextOverflow.ellipsis),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('2 Points', overflow: TextOverflow.ellipsis),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('3 Points', overflow: TextOverflow.ellipsis),
            ),
          ],
          items: const [
            DropdownMenuItem(
              value: 1,
              child: Text(
                '1 Point (Standard Criteria)',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DropdownMenuItem(
              value: 2,
              child: Text(
                '2 Points (Key Indicator)',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DropdownMenuItem(
              value: 3,
              child: Text(
                '3 Points (Critical Flag)',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          onChanged: _isSaving ? null : (v) => setState(() => _points = v ?? 1),
        ),
      ],
    );
  }

  Widget _buildStatusField(AppPalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question Status',
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: palette.inputFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isActive ? 'Active' : 'Disabled',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Switch(
                value: _isActive,
                activeThumbColor: AppColors.primary,
                onChanged: _isSaving
                    ? null
                    : (v) => setState(() => _isActive = v),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
