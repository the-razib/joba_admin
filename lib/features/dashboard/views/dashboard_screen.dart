import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/article_thumb.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/core/widgets/charts.dart';
import 'package:joba_admin/core/widgets/section_card.dart';
import 'package:joba_admin/core/widgets/stat_card.dart';
import 'package:joba_admin/features/dashboard/controllers/dashboard_controller.dart';
import 'package:joba_admin/features/shell/nav_items.dart';
import 'package:joba_admin/features/shell/shell_controller.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

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
              children: [
                _statsGrid(context),
                const SizedBox(height: 16),
                _chartsRow(context),
                const SizedBox(height: 16),
                _cardsRow(context),
                const SizedBox(height: 16),
                _pushBanner(context),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _statsGrid(BuildContext context) {
    const stats = [
      (Icons.group_outlined, 'Total Users', '24,789', 12.5, 'vs last 7 days', AppColors.primary),
      (Icons.monitor_heart_outlined, 'Active Today', '4,278', 8.3, 'vs yesterday', AppColors.purple),
      (Icons.person_add_alt_outlined, 'New Users', '689', 15.2, 'vs yesterday', AppColors.accent),
      (Icons.workspace_premium_outlined, 'Premium Users', '2,356', 10.1, 'vs last 7 days', AppColors.warning),
      (Icons.calendar_month_outlined, 'Avg. Cycle Length', '28.7', -1.3, 'vs last 30 days', AppColors.info),
    ];
    final count = Responsive.pick(context, mobile: 2, tablet: 3, desktop: 5);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count,
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

  Widget _chartsRow(BuildContext context) {
    final line = Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'User Activity Overview',
                    style: TextStyle(
                      color: context.palette.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Obx(
                  () => PopupMenuButton<String>(
                    onSelected: controller.setRange,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: context.palette.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(controller.range.value,
                              style: TextStyle(
                                  fontSize: 12.5,
                                  color: context.palette.textPrimary)),
                          const Icon(Icons.keyboard_arrow_down, size: 16),
                        ],
                      ),
                    ),
                    itemBuilder: (_) => [
                      for (final r in [
                        'Last 7 Days',
                        'Last 30 Days',
                        'Last 90 Days',
                      ])
                        PopupMenuItem(value: r, child: Text(r)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(
              () => ActivityLineChart(
                values: controller.activityValues,
                labels: controller.activityLabels,
              ),
            ),
          ],
        ),
      ),
    );

    final donut = SectionCard(
      title: 'Users by Country',
      child: DonutChart(
        centerValue: '24,789',
        slices: const [
          DonutSlice('Bangladesh', 78.4, AppColors.primary),
          DonutSlice('India', 10.7, AppColors.accent),
          DonutSlice('Pakistan', 4.3, AppColors.warning),
          DonutSlice('Indonesia', 2.8, AppColors.purple),
          DonutSlice('Others', 3.8, Color(0xFF9AA5A1)),
        ],
      ),
    );

    return Responsive.isDesktop(context)
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: line),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: donut),
            ],
          )
        : Column(children: [line, const SizedBox(height: 16), donut]);
  }

  Widget _cardsRow(BuildContext context) {
    final shell = Get.find<ShellController>();
    final recentUsers = SectionCard(
      title: 'Recent Users',
      action: 'View All',
      onAction: () => shell.select(NavId.users),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          for (final u in controller.recentUsers)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  AvatarCircle(name: u.name, size: 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          u.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.palette.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          u.email,
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
                  Text(
                    timeAgo(u.lastActive),
                    style: TextStyle(
                      color: context.palette.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 8),
                  userPlanBadge(u.plan),
                ],
              ),
            ),
        ],
      ),
    );

    final popular = SectionCard(
      title: 'Popular Articles',
      action: 'View All',
      onAction: () => shell.select(NavId.articles),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          for (final a in controller.popularArticles)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  ArticleThumb(imagePath: a.imagePath, width: 56, height: 46),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.titleBn,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.bengali(
                            context,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          a.titleEn,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.palette.textSecondary,
                            fontSize: 11.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.visibility_outlined,
                                size: 13,
                                color: context.palette.textSecondary),
                            const SizedBox(width: 3),
                            Text(compactNumber(a.views),
                                style: TextStyle(
                                    fontSize: 11,
                                    color: context.palette.textSecondary)),
                            const SizedBox(width: 10),
                            Icon(Icons.favorite_outline,
                                size: 13,
                                color: context.palette.textSecondary),
                            const SizedBox(width: 3),
                            Text(compactNumber(a.likes),
                                style: TextStyle(
                                    fontSize: 11,
                                    color: context.palette.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );

    final reports = SectionCard(
      title: 'Recent Reports',
      action: 'View All',
      onAction: () => shell.select(NavId.reports),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          for (final r in controller.recentReports)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.rate_review_outlined,
                        size: 18, color: AppColors.accent),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      r.subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.palette.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  reportStatusBadge(r.status),
                ],
              ),
            ),
        ],
      ),
    );

    return Responsive.isDesktop(context)
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: recentUsers),
              const SizedBox(width: 16),
              Expanded(child: popular),
              const SizedBox(width: 16),
              Expanded(child: reports),
            ],
          )
        : Column(children: [
            recentUsers,
            const SizedBox(height: 16),
            popular,
            const SizedBox(height: 16),
            reports,
          ]);
  }

  Widget _pushBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.mark_chat_unread_outlined,
                color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Send a Push Notification',
                  style: TextStyle(
                    color: context.palette.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Reach your users instantly with updates and important notifications.',
                  style: TextStyle(
                    color: context.palette.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => Get.snackbar(
              'Push Notifications',
              'The BN/EN composer ships in Phase 2.',
              snackPosition: SnackPosition.BOTTOM,
            ),
            icon: const Icon(Icons.send, size: 16),
            label: Responsive.isMobile(context)
                ? const SizedBox()
                : const Text('Send Notification'),
          ),
        ],
      ),
    );
  }
}
