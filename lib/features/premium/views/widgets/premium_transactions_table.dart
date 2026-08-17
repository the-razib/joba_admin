import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/premium/models/premium.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/adaptive_data_table.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/features/premium/controllers/premium_controller.dart';

/// Card containing the data table for payment transactions.
class PremiumTransactionsTable extends GetView<PremiumController> {
  const PremiumTransactionsTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: AdaptiveDataTable<Transaction>(
        rows: controller.transactions,
        cardBuilder: (context, t) => Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(
                Icons.receipt_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${t.userName} • ৳${t.amountBdt}',
                      style: TextStyle(
                        color: context.palette.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${t.method} • ${formatDate(t.date)}',
                      style: TextStyle(
                        color: context.palette.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              PillBadge(label: t.status.label, color: t.status.color),
            ],
          ),
        ),
        columns: [
          AdaptiveColumn<Transaction>(
            label: 'Transaction',
            flex: 5,
            build: (context, t) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.id,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.palette.textPrimary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  t.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.palette.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          AdaptiveColumn<Transaction>(
            label: 'Amount',
            flex: 2,
            build: (context, t) => Text(
              '৳${t.amountBdt}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.palette.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          AdaptiveColumn<Transaction>(
            label: 'Method',
            flex: 3,
            build: (context, t) => Text(
              t.method,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.palette.textSecondary,
                fontSize: 12.5,
              ),
            ),
          ),
          AdaptiveColumn<Transaction>(
            label: 'Date',
            flex: 3,
            tabletHidden: true,
            build: (context, t) => Text(
              formatDate(t.date),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.palette.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          AdaptiveColumn<Transaction>(
            label: 'Status',
            flex: 3,
            build: (context, t) =>
                PillBadge(label: t.status.label, color: t.status.color),
          ),
        ],
      ),
    );
  }
}
