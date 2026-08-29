import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_colors.dart';

/// Circular avatar with graceful multi-tier fallbacks:
/// picked bytes → remote network URL → local bundled asset → colored initials.
class AvatarCircle extends StatelessWidget {
  const AvatarCircle({
    super.key,
    this.bytes,
    this.assetPath,
    this.fallbackAssetPath,
    this.url,
    required this.name,
    this.size = 40,
  });

  final List<int>? bytes;
  final String? assetPath;
  final String? fallbackAssetPath;
  final String? url;
  final String name;
  final double size;

  static const _fallbackColors = [
    AppColors.primary,
    AppColors.accent,
    AppColors.info,
    AppColors.purple,
    AppColors.warning,
  ];

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    final first = parts.isNotEmpty ? parts.first : '';
    final second = parts.length > 1 ? parts[1] : '';
    final s =
        (first.isNotEmpty ? first[0] : '?') +
        (second.isNotEmpty ? second[0] : '');
    return s.toUpperCase();
  }

  Color get _fallbackColor =>
      _fallbackColors[name.hashCode.abs() % _fallbackColors.length];

  @override
  Widget build(BuildContext context) {
    final Widget fallback = Container(
      decoration: BoxDecoration(
        color: _fallbackColor.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          color: _fallbackColor,
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    Widget buildAssetFallback() {
      if (fallbackAssetPath != null && fallbackAssetPath!.isNotEmpty) {
        return Image.asset(
          fallbackAssetPath!,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => fallback,
        );
      }
      return fallback;
    }

    Widget? image;
    if (bytes != null) {
      image = Image.memory(
        Uint8List.fromList(bytes!),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => buildAssetFallback(),
      );
    } else if (assetPath != null && assetPath!.isNotEmpty) {
      if (assetPath!.startsWith('http://') ||
          assetPath!.startsWith('https://')) {
        image = Image.network(
          assetPath!,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => buildAssetFallback(),
        );
      } else {
        image = Image.asset(
          assetPath!,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => buildAssetFallback(),
        );
      }
    } else if (url != null && url!.isNotEmpty) {
      image = Image.network(
        url!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => buildAssetFallback(),
      );
    } else if (fallbackAssetPath != null && fallbackAssetPath!.isNotEmpty) {
      image = Image.asset(
        fallbackAssetPath!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    }

    return ClipOval(
      child: SizedBox(width: size, height: size, child: image ?? buildAssetFallback()),
    );
  }
}
