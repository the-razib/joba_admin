import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/push_notifications/models/push_notification.dart';
import 'package:joba_admin/features/push_notifications/controllers/push_controller.dart';

/// Choice chips for filtering notifications by channel (All, Push, In-App, Both).
class PushChannelFilter extends GetView<PushController> {
  const PushChannelFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.channelFilter.value;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ChoiceChip(
            selected: active == null,
            label: const Text('All', style: TextStyle(fontSize: 12)),
            onSelected: (_) => controller.setChannelFilter(null),
          ),
          for (final c in NotificationChannel.values)
            ChoiceChip(
              selected: active == c,
              avatar: Icon(
                c.icon,
                size: 14,
                color: active == c ? Colors.white : c.color,
              ),
              label: Text(c.label, style: const TextStyle(fontSize: 12)),
              onSelected: (_) => controller.setChannelFilter(c),
            ),
        ],
      );
    });
  }
}
