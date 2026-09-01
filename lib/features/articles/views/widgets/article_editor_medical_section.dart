import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/reading_time_calculator.dart';

/// Editor section for Medical Reviewer verification and auto-calculated reading time.
class ArticleEditorMedicalSection extends StatelessWidget {
  final bool isMedicallyReviewed;
  final TextEditingController medicalReviewerBn;
  final TextEditingController medicalReviewerEn;
  final TextEditingController readingTime;
  final TextEditingController contentBn;
  final TextEditingController contentEn;
  final ValueChanged<bool> onReviewedChanged;
  final VoidCallback? onAutoCalculateReadingTime;

  const ArticleEditorMedicalSection({
    super.key,
    required this.isMedicallyReviewed,
    required this.medicalReviewerBn,
    required this.medicalReviewerEn,
    required this.readingTime,
    required this.contentBn,
    required this.contentEn,
    required this.onReviewedChanged,
    this.onAutoCalculateReadingTime,
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        Row(
                          children: [
                            Text(
                              'Reading Time (min)',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: palette.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            Tooltip(
                              message:
                                  'Standard Reading Speed:\n• বাংলা: ১৬০ শব্দ/মিনিট\n• English: 200 words/min',
                              child: Icon(
                                Icons.info_outline_rounded,
                                size: 14,
                                color: palette.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: readingTime,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Auto',
                            prefixIcon:
                                const Icon(Icons.timer_outlined, size: 18),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.auto_awesome_rounded,
                                  size: 17, color: AppColors.primary),
                              tooltip: 'Recalculate from text length',
                              onPressed: () {
                                final calculated =
                                    ReadingTimeCalculator.calculate(
                                  contentBn: contentBn.text,
                                  contentEn: contentEn.text,
                                );
                                readingTime.text = '$calculated';
                                if (onAutoCalculateReadingTime != null) {
                                  onAutoCalculateReadingTime!();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Dynamic word count & speed helper badge
              AnimatedBuilder(
                animation: Listenable.merge([contentBn, contentEn]),
                builder: (context, _) {
                  final bnWords =
                      ReadingTimeCalculator.countWords(contentBn.text);
                  final enWords =
                      ReadingTimeCalculator.countWords(contentEn.text);
                  final autoMin = ReadingTimeCalculator.calculate(
                    contentBn: contentBn.text,
                    contentEn: contentEn.text,
                  );

                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.18),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.speed_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'টেক্সট দৈর্ঘ্য: $bnWords শব্দ (বাংলা @ 160 wpm) • $enWords words (English @ 200 wpm) ➔ আনুমানিক $autoMin মিনিট',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: palette.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
