import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/reminders/models/reminder_template.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/widgets/section_card.dart';
import 'package:joba_admin/features/reminders/controllers/reminders_controller.dart';
import 'package:joba_admin/features/reminders/views/widgets/reminder_icon_widget.dart';

/// Authentic mobile home screen mockup rendering the actual 1:1 reminder cards.
class RemindersPreviewCard extends GetView<RemindersController> {
  const RemindersPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Home Screen Preview',
      child: Column(
        children: [
          Center(
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2227),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0xFF2E353D), width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phone Status Bar
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '9:41',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1D20),
                            ),
                          ),
                          Container(
                            width: 50,
                            height: 10,
                            decoration: BoxDecoration(
                              color: const Color(0xFF111417),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const Row(
                            children: [
                              Icon(Icons.wifi, size: 12, color: Color(0xFF1A1D20)),
                              SizedBox(width: 4),
                              Icon(Icons.battery_full, size: 13, color: Color(0xFF1A1D20)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Section Title in Mobile App Style
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_active_rounded,
                              size: 13,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'আজকের রিমাইন্ডার ও পরামর্শ',
                              style: TextStyle(
                                color: Color(0xFF1A1D20),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 1:1 Horizontal Scrolling Mobile Cards Preview
                    Obx(
                      () => SizedBox(
                        height: 138,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.order.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final kind = controller.order[i];
                            return _MobileMockReminderCard(
                              kind: kind,
                              rank: i + 1,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Live preview reflecting the exact horizontal card sequence on the Joba mobile home screen.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.palette.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// 1:1 Replica of Mobile App's _VerticalReminderCard
class _MobileMockReminderCard extends StatelessWidget {
  final ReminderKind kind;
  final int rank;

  const _MobileMockReminderCard({
    required this.kind,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final color = kind.themeColor;

    return Container(
      width: 104,
      height: 136,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header: Title + Notification Bell Toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    kind.previewShortTitle,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_active,
                    size: 10,
                    color: color,
                  ),
                ),
              ],
            ),
          ),

          // Illustration Area with the authentic Mobile Asset
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 2, 6, 4),
              child: Center(
                child: ReminderIconWidget(kind: kind, size: 52),
              ),
            ),
          ),

          // Sequence Badge at bottom
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: Center(
              child: Text(
                'Position #$rank',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
