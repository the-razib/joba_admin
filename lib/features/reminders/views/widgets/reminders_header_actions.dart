import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/reminders/controllers/reminders_controller.dart';

/// Action buttons in PageHeader for resetting and saving the reminder sequence.
class RemindersHeaderActions extends GetView<RemindersController> {
  const RemindersHeaderActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dirty = controller.isDirty;
      final saving = controller.saving.value;
      return Wrap(
        spacing: 10,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          OutlinedButton.icon(
            onPressed: dirty && !saving ? controller.resetOrder : null,
            icon: const Icon(Icons.restart_alt, size: 17),
            label: const Text('Reset'),
          ),
          ElevatedButton.icon(
            onPressed: dirty && !saving ? controller.saveOrder : null,
            icon: saving
                ? const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check, size: 17),
            label: Text(saving ? 'Saving…' : 'Save Order'),
          ),
        ],
      );
    });
  }
}
