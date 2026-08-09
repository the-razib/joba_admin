import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/theme/responsive.dart';

class FilterOption {
  const FilterOption({
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final String label; // e.g. 'All Status'
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;
}

/// Search + dropdown filters bar. Stacks vertically on mobile.
class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.searchController,
    this.searchHint = 'Search...',
    this.onSearchChanged,
    this.filters = const [],
    this.onClear,
  });

  final TextEditingController searchController;
  final String searchHint;
  final ValueChanged<String>? onSearchChanged;
  final List<FilterOption> filters;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final search = SizedBox(
      height: 44,
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: searchHint,
          isDense: true,
          prefixIcon: const Icon(Icons.search, size: 20),
        ),
      ),
    );

    final chips = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final f in filters) _FilterButton(filter: f),
        if (onClear != null)
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Clear'),
          ),
      ],
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Responsive.isMobile(context)
            ? Column(children: [search, const SizedBox(height: 10), chips])
            : Row(
                children: [
                  SizedBox(width: 300, child: search),
                  const SizedBox(width: 12),
                  Expanded(child: chips),
                ],
              ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.filter});

  final FilterOption filter;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDefault = filter.selected.isEmpty ||
        filter.selected == filter.options.first;
    return PopupMenuButton<String>(
      onSelected: filter.onChanged,
      offset: const Offset(0, 40),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: palette.inputFill,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              filter.selected,
              style: TextStyle(
                fontSize: 13,
                color: isDefault ? palette.textSecondary : palette.textPrimary,
                fontWeight: isDefault ? FontWeight.w400 : FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.keyboard_arrow_down, size: 18, color: palette.textSecondary),
          ],
        ),
      ),
      itemBuilder: (_) => [
        for (final o in filter.options)
          PopupMenuItem(
            value: o,
            child: Row(
              children: [
                Expanded(child: Text(o, style: const TextStyle(fontSize: 13))),
                if (o == filter.selected)
                  const Icon(Icons.check, size: 16),
              ],
            ),
          ),
      ],
    );
  }
}
