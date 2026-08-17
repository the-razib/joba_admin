import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_theme.dart';

/// Information footer setting expectations about data freshness and Cloud Monitoring sampling.
class UsageSourceNote extends StatelessWidget {
  const UsageSourceNote({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: Text(
              'Sample data. Live figures come from Cloud Monitoring via an authenticated Cloud Function (Phase 3). Read and write counts lag by a few minutes; stored bytes are sampled once daily. Costs are estimated from list prices — the invoiced amount comes from your billing export.',
              style: TextStyle(
                color: context.palette.textSecondary,
                fontSize: 11.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
