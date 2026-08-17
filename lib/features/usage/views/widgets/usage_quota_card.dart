import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/usage/models/usage_metrics.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/section_card.dart';
import 'package:joba_admin/features/usage/controllers/usage_controller.dart';

/// Card showing remaining daily free allowance thresholds and consumption bars.
class UsageQuotaCard extends GetView<UsageController> {
  const UsageQuotaCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: "Today's free allowance",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final q in controller.quotas) ...[
            _QuotaRow(quota: q),
            const SizedBox(height: 14),
          ],
          Text(
            'Blaze keeps the daily free tier — you are only billed on the excess above these lines.',
            style: TextStyle(
              color: context.palette.textSecondary,
              fontSize: 11.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuotaRow extends StatelessWidget {
  const _QuotaRow({required this.quota});

  final QuotaLine quota;

  @override
  Widget build(BuildContext context) {
    final color = quota.isOver
        ? AppColors.danger
        : quota.isNear
            ? AppColors.warning
            : AppColors.success;

    String fmt(num v) =>
        quota.unitIsBytes ? dataSizeLabel(v) : groupedNumber(v);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                quota.label,
                style: TextStyle(
                  color: context.palette.textPrimary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${fmt(quota.used)} / ${fmt(quota.limit)}',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: quota.fraction,
            minHeight: 7,
            backgroundColor: context.palette.border,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
