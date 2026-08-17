import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:joba_admin/features/reminders/models/reminder_template.dart';

/// Reusable icon widget rendering SVG or PNG assets for [ReminderKind].
class ReminderIconWidget extends StatelessWidget {
  final ReminderKind kind;
  final double size;

  const ReminderIconWidget({
    super.key,
    required this.kind,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (kind.isSvg) {
      return SvgPicture.asset(
        kind.assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => Icon(
          Icons.notifications_none,
          size: size,
          color: kind.themeColor,
        ),
      );
    }
    return Image.asset(
      kind.assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.notifications_none,
        size: size,
        color: kind.themeColor,
      ),
    );
  }
}
