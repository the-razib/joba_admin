import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/usage/controllers/usage_controller.dart';

/// Range picker toggle for 7d, 30d, 90d usage windows.
class UsageRangePicker extends GetView<UsageController> {
  const UsageRangePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SegmentedButton<int>(
        showSelectedIcon: false,
        style: const ButtonStyle(visualDensity: VisualDensity.compact),
        segments: [
          for (final d in UsageController.ranges)
            ButtonSegment(value: d, label: Text('${d}d')),
        ],
        selected: {controller.rangeDays.value},
        onSelectionChanged: (s) => controller.setRange(s.first),
      ),
    );
  }
}
