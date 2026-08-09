import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/models/audit_log.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/adaptive_data_table.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/core/widgets/charts.dart';
import 'package:joba_admin/core/widgets/detail_panel.dart';
import 'package:joba_admin/core/widgets/filter_bar.dart';
import 'package:joba_admin/core/widgets/section_card.dart';
import 'package:joba_admin/core/widgets/stat_card.dart';
import 'package:joba_admin/features/audit_logs/controllers/audit_logs_controller.dart';

class AuditLogsScreen extends GetView<AuditLogsController> {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 14 : 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Responsive.contentMax),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _stats(context),
                const SizedBox(height: 16),
                Responsive.isDesktop(context)
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _tableCard(context)),
                          const SizedBox(width: 16),
                          Expanded(flex: 1, child: _rightColumn(context)),
                        ],
                      )
                    : Column(
                        children: [
                          _tableCard(context),
                          const SizedBox(height: 16),
                          _rightColumn(context),
                        ],
                      ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _stats(BuildContext context) {
    final stats = [
      (
        Icons.receipt_long_outlined,
        'Total Logs',
        '18,742',
        18.6,
        'vs last 7 days',
        AppColors.primary,
      ),
      (
        Icons.group_outlined,
        'Users',
        '6,421',
        12.4,
        'vs last 7 days',
        AppColors.purple,
      ),
      (
        Icons.settings_outlined,
        'Admin Actions',
        '9,356',
        15.3,
        'vs last 7 days',
        AppColors.warning,
      ),
      (
        Icons.verified_user_outlined,
        'Security Events',
        '${controller.securityEvents + 960}',
        22.7,
        'vs last 7 days',
        AppColors.info,
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.pick(
          context,
          mobile: 2,
          tablet: 4,
          desktop: 4,
        ),
        mainAxisExtent: 104,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: stats.length,
      itemBuilder: (_, i) => StatCard(
        icon: stats[i].$1,
        label: stats[i].$2,
        value: stats[i].$3,
        deltaPercent: stats[i].$4,
        compareLabel: stats[i].$5,
        iconColor: stats[i].$6,
      ),
    );
  }

  Widget _tableCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: FilterBar(
              searchController: controller.searchController,
              searchHint: 'Search by admin, user, action, module or IP...',
              onSearchChanged: (_) => controller.searchTick.value++,
              filters: [
                FilterOption(
                  label: 'All Modules',
                  options: controller.modules,
                  selected: controller.moduleFilter.value,
                  onChanged: (v) => controller.moduleFilter.value = v,
                ),
                FilterOption(
                  label: 'All Actions',
                  options: AuditLogsController.actionOptions,
                  selected: controller.actionFilter.value,
                  onChanged: (v) => controller.actionFilter.value = v,
                ),
              ],
            ),
          ),
          Obx(() {
            controller.searchTick.value;
            return AdaptiveDataTable<AuditLog>(
              rows: controller.filtered,
              onRowTap: (l) => _openDetail(context, l),
              cardBuilder: (context, l) => _mobileCard(context, l),
              columns: [
                AdaptiveColumn<AuditLog>(
                  label: 'Time',
                  flex: 3,
                  tabletHidden: true,
                  build: (context, l) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatDate(l.time),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.palette.textPrimary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _timeOf(l.time),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.palette.textSecondary,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
                AdaptiveColumn<AuditLog>(
                  label: 'Admin / User',
                  flex: 5,
                  build: (context, l) => Row(
                    children: [
                      AvatarCircle(name: l.adminName, size: 32),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.adminName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.palette.textPrimary,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              l.adminRole,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AdaptiveColumn<AuditLog>(
                  label: 'Action',
                  flex: 3,
                  build: (context, l) => _actionBadge(l.action),
                ),
                AdaptiveColumn<AuditLog>(
                  label: 'Module',
                  flex: 3,
                  tabletHidden: true,
                  build: (context, l) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.apps_outlined,
                        size: 14,
                        color: AppColors.purple,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          l.module,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.palette.textPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AdaptiveColumn<AuditLog>(
                  label: 'Details',
                  flex: 5,
                  build: (context, l) => Text(
                    l.details,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.palette.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                ),
                AdaptiveColumn<AuditLog>(
                  label: 'IP Address',
                  flex: 3,
                  tabletHidden: true,
                  build: (context, l) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.ip,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.palette.textPrimary,
                          fontSize: 11.5,
                        ),
                      ),
                      Text(
                        l.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.palette.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                AdaptiveColumn<AuditLog>(
                  label: 'Status',
                  flex: 2,
                  build: (context, l) => l.status == AuditStatus.success
                      ? const PillBadge(
                          label: 'Success',
                          color: AppColors.success,
                        )
                      : const PillBadge(
                          label: 'Failed',
                          color: AppColors.danger,
                        ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  String _timeOf(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.hour < 12 ? 'AM' : 'PM'}';
  }

  PillBadge _actionBadge(AuditAction a) => switch (a) {
    AuditAction.created => const PillBadge(
      label: 'Created',
      color: AppColors.success,
    ),
    AuditAction.updated => const PillBadge(
      label: 'Updated',
      color: AppColors.info,
    ),
    AuditAction.deleted => const PillBadge(
      label: 'Deleted',
      color: AppColors.danger,
    ),
    AuditAction.viewed => const PillBadge(
      label: 'Viewed',
      color: AppColors.textSecondaryLight,
    ),
    AuditAction.downloaded => const PillBadge(
      label: 'Downloaded',
      color: AppColors.success,
    ),
    AuditAction.exported => const PillBadge(
      label: 'Exported',
      color: AppColors.warning,
    ),
    AuditAction.failedLogin => const PillBadge(
      label: 'Failed Login',
      color: AppColors.danger,
    ),
  };

  Widget _mobileCard(BuildContext context, AuditLog l) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AvatarCircle(name: l.adminName, size: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.adminName,
                        style: TextStyle(
                          color: context.palette.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${l.module} • ${formatDate(l.time)}',
                        style: TextStyle(
                          color: context.palette.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                _actionBadge(l.action),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l.details,
              style: TextStyle(
                color: context.palette.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rightColumn(BuildContext context) {
    return Column(
      children: [
        SectionCard(
          title: 'Activity Overview',
          child: Obx(
            () => ActivityLineChart(
              values: controller.activityValues.isEmpty
                  ? const [1, 2, 3]
                  : controller.activityValues,
              labels: controller.activityLabels.isEmpty
                  ? const ['a', 'b', 'c']
                  : controller.activityLabels,
              height: 160,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Action Breakdown',
          child: Obx(
            () => DonutChart(
              centerValue: '${controller.all.length}',
              centerLabel: 'Total Logs',
              size: 150,
              slices: [
                DonutSlice(
                  'Created',
                  controller.countAction(AuditAction.created).toDouble(),
                  AppColors.primary,
                ),
                DonutSlice(
                  'Updated',
                  controller.countAction(AuditAction.updated).toDouble(),
                  AppColors.info,
                ),
                DonutSlice(
                  'Deleted',
                  controller.countAction(AuditAction.deleted).toDouble(),
                  AppColors.accent,
                ),
                DonutSlice(
                  'Viewed',
                  controller.countAction(AuditAction.viewed).toDouble(),
                  AppColors.warning,
                ),
                DonutSlice(
                  'Others',
                  (controller.countAction(AuditAction.downloaded) +
                          controller.countAction(AuditAction.exported) +
                          controller.countAction(AuditAction.failedLogin))
                      .toDouble(),
                  const Color(0xFF9AA5A1),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final latest = controller.all.isEmpty
              ? null
              : (controller.filtered.isNotEmpty
                    ? controller.filtered.first
                    : controller.all.first);
          if (latest == null) return const SizedBox();
          return SectionCard(
            title: 'Recent Log Details',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        latest.details,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.palette.textPrimary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _actionBadge(latest.action),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${latest.adminName} (${latest.adminRole}) • ${latest.ip}',
                  style: TextStyle(
                    color: context.palette.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _openDetail(context, latest),
                    child: const Text('View Full Details'),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _openDetail(BuildContext context, AuditLog l) {
    showDetailPanel(
      context,
      title: 'Log Details',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AvatarCircle(name: l.adminName, size: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.adminName,
                        style: TextStyle(
                          color: context.palette.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${l.adminRole} • ${formatDateTime(l.time)}',
                        style: TextStyle(
                          color: context.palette.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _actionBadge(l.action),
              ],
            ),
            const SizedBox(height: 20),
            for (final row in [
              ('Module', l.module),
              ('Action', l.action.name),
              ('Details', l.details),
              ('IP Address', l.ip),
              ('Location', l.location),
              ('Status', l.status.name),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        row.$1,
                        style: TextStyle(
                          color: context.palette.textSecondary,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row.$2,
                        style: TextStyle(
                          color: context.palette.textPrimary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
