import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/widgets/page_header.dart';
import 'package:joba_admin/core/widgets/stat_card.dart';
import 'package:joba_admin/features/disease_checkup/controllers/admin_screener_controller.dart';
import 'package:joba_admin/features/disease_checkup/views/widgets/questions_pane.dart';
import 'package:joba_admin/features/disease_checkup/views/widgets/risk_tiers_pane.dart';
import 'package:joba_admin/features/disease_checkup/views/widgets/screener_editor_dialog.dart';
import 'package:joba_admin/features/disease_checkup/views/widgets/screener_list_pane.dart';

class AdminScreenerScreen extends GetView<AdminScreenerController> {
  const AdminScreenerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final isMobile = Responsive.isMobile(context);

      return SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 14 : 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Responsive.contentMax),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'Disease Checkup & Screeners',
                  subtitle:
                      'Manage clinical self-assessment questionnaires, risk tiers, and doctor advice.',
                  actions: isMobile
                      ? const []
                      : [
                          ElevatedButton.icon(
                            onPressed: () {
                              ScreenerEditorDialog.show(
                                context,
                                onSave: (screener, isNew) => controller
                                    .saveScreener(screener, isNew: isNew),
                              );
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Screener'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                ),
                const SizedBox(height: 16),

                // Standard Responsive KPI Stats Grid
                _buildStatsGrid(context),
                const SizedBox(height: 16),

                // Main Workspace Layout
                if (isMobile)
                  _buildMobileWorkspace(context)
                else
                  _buildDesktopTabletWorkspace(context),
              ],
            ),
          ),
        ),
      );
    });
  }

  /// 4-card responsive KPI grid matching Users & Reminders screens
  Widget _buildStatsGrid(BuildContext context) {
    return Obx(() {
      final activeScreeners = controller.activeScreenersCount;
      final totalScreeners = controller.totalScreenersCount;
      final totalQuestions = controller.totalQuestionsCount;
      final totalCompletions = controller.totalCompletionsCount;
      final popular = controller.mostPopularScreener;

      final stats = [
        (
          Icons.health_and_safety_outlined,
          'Active Tests',
          '$activeScreeners / $totalScreeners',
          AppColors.primary,
        ),
        (
          Icons.quiz_outlined,
          'Clinical Questions',
          '$totalQuestions',
          AppColors.info,
        ),
        (
          Icons.insights_outlined,
          'Total Screenings',
          '$totalCompletions',
          AppColors.success,
        ),
        (
          Icons.star_outline_rounded,
          'Top Screener',
          popular,
          AppColors.warning,
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
          iconColor: stats[i].$4,
        ),
      );
    });
  }

  /// Desktop (>= 1100px) & Tablet (700-1100px) multi-pane workspace
  Widget _buildDesktopTabletWorkspace(BuildContext context) {
    final isTablet = Responsive.isTablet(context);

    return SizedBox(
      height: 680,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Pane: Screener List
          SizedBox(
            width: isTablet ? 300 : 360,
            child: const ScreenerListPane(),
          ),
          SizedBox(width: isTablet ? 12 : 16),

          // Right Workspace Pane (Questions or Risk Guidance)
          Expanded(
            child: Column(
              children: [
                // Tab Switcher
                Obx(
                  () => Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: context.palette.inputFill,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: context.palette.border),
                    ),
                    child: Row(
                      children: [
                        _buildTabButton(context, '1. Symptom Questionnaire', 0),
                        _buildTabButton(
                          context,
                          '2. Risk Gauge & Doctor Advice',
                          1,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Selected Tab Content
                Expanded(
                  child: Obx(
                    () => controller.activeTab.value == 0
                        ? const QuestionsPane()
                        : const RiskTiersPane(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Mobile (< 700px) drill-down & tabbed navigation workspace
  Widget _buildMobileWorkspace(BuildContext context) {
    return Obx(() {
      final tab = controller.mobileTab.value;
      final selected = controller.selectedScreener.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mobile Segmented Switcher
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: context.palette.inputFill,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.palette.border),
            ),
            child: Row(
              children: [
                _buildMobileTabButton(
                  context,
                  'Tests (${controller.screeners.length})',
                  0,
                ),
                _buildMobileTabButton(
                  context,
                  'Questions (${selected?.questions.length ?? 0})',
                  1,
                ),
                _buildMobileTabButton(context, 'Guidance', 2),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Selected Screener Indicator Banner on Mobile
          if (tab != 0 && selected != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.health_and_safety_outlined,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Editing: ${selected.nameEn} (${selected.nameBn})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: () => controller.mobileTab.value = 0,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        'Change',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Active Mobile View Container
          SizedBox(
            height: (MediaQuery.sizeOf(context).height * 0.68).clamp(
              520.0,
              760.0,
            ),
            child: _buildMobileTabContent(tab),
          ),
        ],
      );
    });
  }

  Widget _buildMobileTabContent(int tab) {
    switch (tab) {
      case 0:
        return const ScreenerListPane(isMobileDrillDown: true);
      case 1:
        return const QuestionsPane();
      case 2:
        return const RiskTiersPane();
      default:
        return const ScreenerListPane(isMobileDrillDown: true);
    }
  }

  Widget _buildTabButton(BuildContext context, String label, int index) {
    final isSelected = controller.activeTab.value == index;
    return Expanded(
      child: InkWell(
        onTap: () => controller.activeTab.value = index,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? context.palette.card : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : context.palette.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileTabButton(BuildContext context, String label, int index) {
    final isSelected = controller.mobileTab.value == index;
    return Expanded(
      child: InkWell(
        onTap: () => controller.mobileTab.value = index,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? context.palette.card : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : context.palette.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
