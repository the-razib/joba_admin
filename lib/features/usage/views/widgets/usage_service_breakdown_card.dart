import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/section_card.dart';
import 'package:joba_admin/features/usage/controllers/usage_controller.dart';

/// Card showing cost breakdown distributed across Firebase services.
class UsageServiceBreakdownCard extends GetView<UsageController> {
  const UsageServiceBreakdownCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final costs = controller.serviceCosts;
      final total = costs.fold<double>(0, (a, e) => a + e.$2);

      return SectionCard(
        title: 'Cost by service',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (service, cost) in costs) ...[
              Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: service.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      service.label,
                      style: TextStyle(
                        color: context.palette.textPrimary,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  Text(
                    usd(cost),
                    style: TextStyle(
                      color: context.palette.textPrimary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 42,
                    child: Text(
                      total == 0
                          ? '—'
                          : '${(cost / total * 100).toStringAsFixed(0)}%',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: context.palette.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      );
    });
  }
}
