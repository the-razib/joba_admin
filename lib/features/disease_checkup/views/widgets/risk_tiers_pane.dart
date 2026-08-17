import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/models/screener_admin_model.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/features/disease_checkup/controllers/admin_screener_controller.dart';
import 'package:joba_admin/features/disease_checkup/views/widgets/risk_tier_editor_dialog.dart';

class RiskTiersPane extends GetView<AdminScreenerController> {
  const RiskTiersPane({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final s = controller.selectedScreener;
      if (s == null) {
        return const Center(
          child: Text('Select a screener to configure risk tiers'),
        );
      }
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.speed_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${s.nameEn} Risk Gauge & Doctor Guidance',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Clinical scoring rules and doctor summary advice shown to users',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildGaugeBar(s.riskTiers),
                  const SizedBox(height: 20),
                  ...s.riskTiers.map(
                    (tier) => _RiskTierCard(tier: tier, screenerId: s.id),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildGaugeBar(List<RiskTierAdminConfig> tiers) {
    final ordered = [...tiers]
      ..sort((a, b) => a.minRatio.compareTo(b.minRatio));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Wrap(
            spacing: 12,
            runSpacing: 4,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                'Speedometer Risk Meter Layout',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              Text(
                '0% to 100% Score Ratio',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (ordered.isEmpty)
            const Text(
              'No risk tiers configured.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 24,
                child: Row(
                  children: [
                    for (var i = 0; i < ordered.length; i++) ...[
                      if (i > 0) const SizedBox(width: 2),
                      Expanded(
                        flex: _tierFlex(ordered[i]),
                        child: Container(
                          color: _parseColor(ordered[i].colorHex),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            '${ordered[i].labelEn.toUpperCase()} (${_percent(ordered[i].minRatio)}-${_percent(ordered[i].maxRatio)}%)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  static int _tierFlex(RiskTierAdminConfig tier) =>
      ((tier.maxRatio - tier.minRatio).abs() * 1000).round().clamp(1, 1000);
  static int _percent(double ratio) => (ratio * 100).round();
  static Color _parseColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('0xFF$clean'));
    } catch (_) {
      return AppColors.primary;
    }
  }
}

class _RiskTierCard extends GetView<AdminScreenerController> {
  final RiskTierAdminConfig tier;
  final String screenerId;
  const _RiskTierCard({required this.tier, required this.screenerId});

  @override
  Widget build(BuildContext context) {
    final color = RiskTiersPane._parseColor(tier.colorHex);
    final metadata = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${RiskTiersPane._percent(tier.minRatio)}% - ${RiskTiersPane._percent(tier.maxRatio)}% Score Ratio',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
    final edit = IconButton(
      icon: const Icon(Icons.edit_outlined, size: 18),
      tooltip: 'Edit Doctor Guidance',
      onPressed: () {
        RiskTierEditorDialog.show(
          context,
          tier: tier,
          onSave: (updated) => controller.updateRiskTier(screenerId, updated),
        );
      },
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final labels = Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          tier.labelEn,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '(${tier.labelBn})',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              if (constraints.maxWidth < 520) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    labels,
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(child: metadata),
                        edit,
                      ],
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: labels),
                  const SizedBox(width: 8),
                  metadata,
                  edit,
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          _guidance(
            'ডাক্তার পরামর্শ ও নির্দেশনা (Bengali):',
            tier.descriptionBn,
          ),
          const SizedBox(height: 8),
          _guidance(
            'Doctor Guidance & Clinical Advice (English):',
            tier.descriptionEn,
          ),
        ],
      ),
    );
  }

  Widget _guidance(String label, String value) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13, height: 1.4)),
      ],
    ),
  );
}
