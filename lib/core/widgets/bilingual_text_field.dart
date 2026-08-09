import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';

/// Paired বাংলা / English inputs used by the article & notification forms.
class BilingualField extends StatelessWidget {
  const BilingualField({
    super.key,
    required this.label,
    required this.bnController,
    required this.enController,
    this.maxLines = 1,
    this.hintBn,
    this.hintEn,
  });

  final String label;
  final TextEditingController bnController;
  final TextEditingController enController;
  final int maxLines;
  final String? hintBn;
  final String? hintEn;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        _langField(
          context,
          chip: 'BN',
          chipColor: AppColors.accent,
          controller: bnController,
          hint: hintBn ?? 'বাংলায় লিখুন…',
          style: AppTheme.bengali(context, fontSize: 14),
        ),
        const SizedBox(height: 8),
        _langField(
          context,
          chip: 'EN',
          chipColor: AppColors.info,
          controller: enController,
          hint: hintEn ?? 'Write in English…',
          style: TextStyle(color: palette.textPrimary, fontSize: 14),
        ),
      ],
    );
  }

  Widget _langField(
    BuildContext context, {
    required String chip,
    required Color chipColor,
    required TextEditingController controller,
    required String hint,
    required TextStyle style,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: style,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: chipColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            chip,
            style: TextStyle(
              color: chipColor,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
