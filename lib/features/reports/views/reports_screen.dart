import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/models/report.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/adaptive_data_table.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/core/widgets/detail_panel.dart';
import 'package:joba_admin/core/widgets/filter_bar.dart';
import 'package:joba_admin/core/widgets/stat_card.dart';
import 'package:joba_admin/features/reports/controllers/reports_controller.dart';

class ReportsScreen extends GetView<ReportsController> {
  const ReportsScreen({super.key});

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
                Card(
                  child: Column(
                    children: [
                      _typeTabs(context),
                      Divider(height: 1, color: context.palette.border),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: FilterBar(
                          searchController: controller.searchController,
                          searchHint: 'Search by user, type, or subject...',
                          onSearchChanged: (_) => controller.searchTick.value++,
                          filters: [
                            FilterOption(
                              label: 'All Status',
                              options: const [
                                'All Status',
                                'Pending',
                                'In Progress',
                                'Resolved',
                              ],
                              selected: controller.statusFilter.value,
                              onChanged: (v) =>
                                  controller.statusFilter.value = v,
                            ),
                          ],
                        ),
                      ),
                      Obx(() {
                        controller.searchTick.value;
                        final list = controller.filtered;
                        return AdaptiveDataTable<Report>(
                          rows: list,
                          onRowTap: (r) => _openDetail(context, r.id),
                          cardBuilder: (context, r) => _mobileCard(context, r),
                          columns: [
                            AdaptiveColumn<Report>(
                              label: 'Report',
                              flex: 8,
                              build: (context, r) => Row(
                                children: [
                                  _typeIcon(r.type),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          r.subject,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: context.palette.textPrimary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          r.description,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color:
                                                context.palette.textSecondary,
                                            fontSize: 11.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AdaptiveColumn<Report>(
                              label: 'Type',
                              flex: 4,
                              tabletHidden: true,
                              build: (context, r) => reportTypeBadge(r.type),
                            ),
                            AdaptiveColumn<Report>(
                              label: 'User',
                              flex: 5,
                              build: (context, r) => Row(
                                children: [
                                  AvatarCircle(name: r.userName, size: 30),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      r.userName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: context.palette.textPrimary,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AdaptiveColumn<Report>(
                              label: 'Status',
                              flex: 3,
                              build: (context, r) =>
                                  reportStatusBadge(r.status),
                            ),
                            AdaptiveColumn<Report>(
                              label: 'Priority',
                              flex: 3,
                              tabletHidden: true,
                              build: (context, r) =>
                                  reportPriorityBadge(r.priority),
                            ),
                            AdaptiveColumn<Report>(
                              label: 'Date',
                              flex: 3,
                              tabletHidden: true,
                              build: (context, r) => Text(
                                formatDate(r.date),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: context.palette.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            AdaptiveColumn<Report>(
                              label: '',
                              width: 44,
                              align: Alignment.centerRight,
                              build: (context, r) => IconButton(
                                tooltip: 'View',
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(
                                  Icons.visibility_outlined,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                onPressed: () => _openDetail(context, r.id),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _stats(BuildContext context) {
    return Obx(() {
      final stats = [
        (
          Icons.rate_review_outlined,
          'Total Reports',
          '${controller.all.length * 208}',
          null,
          '',
          AppColors.accent,
        ),
        (
          Icons.pending_outlined,
          'Pending',
          '${controller.countStatus(ReportStatus.pending)}',
          null,
          '',
          AppColors.warning,
        ),
        (
          Icons.hourglass_top_outlined,
          'In Progress',
          '${controller.countStatus(ReportStatus.inProgress)}',
          null,
          '',
          AppColors.purple,
        ),
        (
          Icons.task_alt_outlined,
          'Resolved',
          '${controller.countStatus(ReportStatus.resolved)}',
          null,
          '',
          AppColors.success,
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
          mainAxisExtent: 96,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: stats.length,
        itemBuilder: (_, i) => StatCard(
          icon: stats[i].$1,
          label: stats[i].$2,
          value: stats[i].$3,
          iconColor: stats[i].$6,
        ),
      );
    });
  }

  Widget _typeTabs(BuildContext context) {
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            for (final t in ReportsController.typeTabs)
              InkWell(
                onTap: () => controller.typeTab.value = t,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: controller.typeTab.value == t
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    t,
                    style: TextStyle(
                      color: controller.typeTab.value == t
                          ? AppColors.primary
                          : context.palette.textSecondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _typeIcon(ReportType t) {
    final (icon, color) = switch (t) {
      ReportType.bug => (Icons.bug_report_outlined, AppColors.success),
      ReportType.prediction => (Icons.show_chart, AppColors.accent),
      ReportType.content => (Icons.description_outlined, AppColors.warning),
      ReportType.feature => (Icons.star_outline, AppColors.purple),
      ReportType.payment => (Icons.payment_outlined, AppColors.accent),
      ReportType.other => (Icons.chat_bubble_outline, AppColors.info),
    };
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  Widget _mobileCard(BuildContext context, Report r) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _typeIcon(r.type),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.subject,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.palette.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${r.userName} • ${formatDate(r.date)}',
                        style: TextStyle(
                          color: context.palette.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _openDetail(context, r.id),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                reportTypeBadge(r.type),
                reportStatusBadge(r.status),
                reportPriorityBadge(r.priority),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, String id) {
    showDetailPanel(
      context,
      title: 'Report Details',
      child: _ReportDetailBody(id: id),
      footer: _ReportDetailFooter(id: id),
    );
  }
}

class _ReportDetailBody extends GetView<ReportsController> {
  const _ReportDetailBody({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final r = controller.all.firstWhereOrNull((e) => e.id == id);
      if (r == null) return const SizedBox();
      final palette = context.palette;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.show_chart,
                    color: AppColors.accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.subject,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '#${r.id} • ${formatDateTime(r.date)}',
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                reportStatusBadge(r.status),
              ],
            ),
            const SizedBox(height: 18),
            _label(context, 'Reported by'),
            const SizedBox(height: 8),
            Row(
              children: [
                AvatarCircle(name: r.userName, size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.userName,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        r.userEmail,
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(context, 'Report Type'),
                      const SizedBox(height: 6),
                      reportTypeBadge(r.type),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(context, 'Priority'),
                      const SizedBox(height: 6),
                      reportPriorityBadge(r.priority),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _label(context, 'Description'),
            const SizedBox(height: 6),
            Text(
              r.description,
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 13,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 18),
            _label(context, 'Screenshots (2)'),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final c in [AppColors.accent, AppColors.primary])
                  Container(
                    width: 84,
                    height: 120,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: c.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: c.withValues(alpha: 0.3)),
                    ),
                    child: Icon(
                      Icons.phone_android,
                      color: c.withValues(alpha: 0.6),
                      size: 28,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            _label(context, 'Device Info'),
            const SizedBox(height: 6),
            Text(
              '${r.deviceModel ?? 'Unknown'} • ${r.os ?? '—'}',
              style: TextStyle(color: palette.textSecondary, fontSize: 12.5),
            ),
            const SizedBox(height: 18),
            _label(context, 'History'),
            const SizedBox(height: 8),
            _historyRow(
              context,
              formatDateTime(r.date),
              'Report submitted by user',
            ),
            if (r.status != ReportStatus.pending)
              _historyRow(
                context,
                formatDateTime(r.date.add(const Duration(hours: 5))),
                'Status changed to ${r.status.name}',
              ),
          ],
        ),
      );
    });
  }

  Widget _label(BuildContext context, String t) => Text(
    t,
    style: TextStyle(
      color: context.palette.textPrimary,
      fontSize: 12.5,
      fontWeight: FontWeight.w700,
    ),
  );

  Widget _historyRow(BuildContext context, String time, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 4),
          decoration: const BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: TextStyle(
                  color: context.palette.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                text,
                style: TextStyle(
                  color: context.palette.textSecondary,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ReportDetailFooter extends GetView<ReportsController> {
  const _ReportDetailFooter({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final r = controller.all.firstWhereOrNull((e) => e.id == id);
      if (r == null) return const SizedBox();
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Get.snackbar(
                'Assigned',
                'Report assigned to support team (mock).',
                snackPosition: SnackPosition.BOTTOM,
              ),
              icon: const Icon(Icons.person_add_alt_outlined, size: 16),
              label: const Text('Assign to Team'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: PopupMenuButton<ReportStatus>(
              onSelected: (s) {
                controller.updateStatus(id, s);
                Get.snackbar(
                  'Status updated',
                  'Report marked as ${s.name} (mock).',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Update Status',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
              itemBuilder: (_) => [
                for (final s in ReportStatus.values)
                  PopupMenuItem(
                    value: s,
                    child: Text(s.name, style: const TextStyle(fontSize: 13)),
                  ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
