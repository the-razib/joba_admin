import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
import 'package:joba_admin/core/widgets/section_card.dart';
import 'package:joba_admin/features/cycle_data/controllers/cycle_data_controller.dart';
import 'package:joba_admin/features/users/views/user_detail_panel.dart';

/// Card providing real-time search and lookup of individual user cycle details (Super Admin access).
class CycleUserLookupCard extends GetView<CycleDataController> {
  const CycleUserLookupCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Per-User Lookup (Super Admin)',
      child: Column(
        children: [
          TextField(
            controller: controller.searchController,
            onChanged: (_) => controller.searchTick.value++,
            decoration: const InputDecoration(
              hintText: 'Search user by name, email or UID...',
              isDense: true,
              prefixIcon: Icon(Icons.search, size: 18),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            controller.searchTick.value;
            final list = controller.lookup;

            if (list.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No users found matching search query.',
                    style: TextStyle(
                      color: context.palette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: [
                for (final u in list)
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => openUserDetail(context, u.uid),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          AvatarCircle(
                            name: u.name,
                            url: u.photoUrl,
                            size: 38,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  u.name,
                                  style: TextStyle(
                                    color: context.palette.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${u.averageCycleLength}d cycle • ${u.averagePeriodDuration}d period • ${u.cycleGoal}',
                                  style: TextStyle(
                                    color: context.palette.textSecondary,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 18),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
