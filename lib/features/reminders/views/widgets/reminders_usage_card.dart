import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/widgets/charts.dart';
import 'package:joba_admin/core/widgets/section_card.dart';
import 'package:joba_admin/features/reminders/controllers/reminders_controller.dart';

/// Card showing distribution of reminder adoption via DonutChart.
class RemindersUsageCard extends GetView<RemindersController> {
  const RemindersUsageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Reminder Usage',
      child: Obx(
        () => DonutChart(
          centerValue: '${controller.trackerCount}',
          centerLabel: 'Trackers',
          size: 160,
          slices: [
            for (final (kind, count) in controller.kindCounts)
              DonutSlice(kind.label, count.toDouble(), kind.themeColor),
          ],
        ),
      ),
    );
  }
}
