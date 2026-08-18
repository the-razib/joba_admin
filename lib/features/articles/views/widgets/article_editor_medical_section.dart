import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_theme.dart';

/// Editor section for Medical Reviewer verification and reading time.
class ArticleEditorMedicalSection extends StatelessWidget {
  final bool isMedicallyReviewed;
  final TextEditingController medicalReviewerBn;
  final TextEditingController medicalReviewerEn;
  final TextEditingController readingTime;
  final ValueChanged<bool> onReviewedChanged;

  const ArticleEditorMedicalSection({
    super.key,
    required this.isMedicallyReviewed,
    required this.medicalReviewerBn,
    required this.medicalReviewerEn,
    required this.readingTime,
    required this.onReviewedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1EAE8D).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    color: Color(0xFF1EAE8D),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medical Verification & Reviewer',
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Appears as verified doctor badge on mobile article details',
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isMedicallyReviewed,
                  activeTrackColor: const Color(0xFF1EAE8D),
                  onChanged: onReviewedChanged,
                ),
              ],
            ),
            if (isMedicallyReviewed) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Bengali Doctor Name
              Text(
                'Reviewer Doctor Name (বাংলা)',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: palette.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: medicalReviewerBn,
                style: AppTheme.bengali(context),
                decoration: const InputDecoration(
                  hintText: 'যেমন: ডাঃ সাবরিনা সুলতানা',
                  prefixIcon: Icon(Icons.person_outline, size: 18),
                ),
              ),
              const SizedBox(height: 12),

              // English Doctor Name & Reading Time in Row
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Doctor Name (English)',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: palette.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: medicalReviewerEn,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Dr. Sabrina Sultana',
                            prefixIcon: Icon(Icons.person_outline, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reading Time (min)',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: palette.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: readingTime,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '3',
                            prefixIcon: Icon(Icons.timer_outlined, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
