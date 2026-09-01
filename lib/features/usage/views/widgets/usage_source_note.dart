import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/features/usage/controllers/usage_controller.dart';

/// Information footer setting expectations about data freshness and Cloud Monitoring sampling.
class UsageSourceNote extends StatelessWidget {
  const UsageSourceNote({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<UsageController>() ? Get.find<UsageController>() : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.palette.textSecondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.palette.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 17,
            color: context.palette.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Obx(() {
              final lastUpdated = controller?.lastUpdated;
              final updatedStr = lastUpdated != null
                  ? 'Last analytics rollup: ${formatDate(lastUpdated)}.'
                  : '';

              return Text(
                'Live consumption data aggregated from Cloud Firestore rollups and Firebase Blaze pricing. Document reads, writes, and stored bytes are tracked daily. Invoiced totals reflect official Google Cloud billing exports. $updatedStr',
                style: TextStyle(
                  color: context.palette.textSecondary,
                  fontSize: 11.5,
                  height: 1.5,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
