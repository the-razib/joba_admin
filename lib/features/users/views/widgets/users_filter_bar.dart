import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/widgets/filter_bar.dart';
import 'package:joba_admin/features/users/controllers/users_controller.dart';

/// Top search and multi-facet filtering controls for the users list.
class UsersFilterBar extends GetView<UsersController> {
  const UsersFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => FilterBar(
        searchController: controller.searchController,
        searchHint: 'Search by name, email or user ID...',
        onSearchChanged: (_) => controller.page.value = 1,
        onClear: controller.clearFilters,
        filters: [
          FilterOption(
            label: 'All Status',
            options: const [
              'All Status',
              'Active',
              'Inactive',
              'Blocked',
            ],
            selected: controller.statusFilter.value,
            onChanged: (v) => controller.statusFilter.value = v,
          ),
          FilterOption(
            label: 'All Plans',
            options: const ['All Plans', 'Free', 'Premium'],
            selected: controller.planFilter.value,
            onChanged: (v) => controller.planFilter.value = v,
          ),
          FilterOption(
            label: 'All Countries',
            options: ['All Countries', ...controller.countries],
            selected: controller.countryFilter.value,
            onChanged: (v) => controller.countryFilter.value = v,
          ),
        ],
      ),
    );
  }
}
