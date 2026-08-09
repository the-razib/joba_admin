import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_theme.dart';

/// Titled card with an optional trailing action ("View All" etc.).
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: context.palette.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (action != null)
                  TextButton(
                    onPressed: onAction,
                    child: Text(action!),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
