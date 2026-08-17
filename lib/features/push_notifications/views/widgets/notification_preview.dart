import 'package:flutter/material.dart';
import 'package:joba_admin/features/push_notifications/models/push_notification.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';

/// Remote image with a visible fallback.
///
/// Never let a bad URL throw: an admin pasting a broken link should see a
/// placeholder telling them it failed, not a red error box over the preview.
class PreviewImage extends StatelessWidget {
  const PreviewImage({
    super.key,
    required this.url,
    required this.height,
    this.width = double.infinity,
    this.radius = 10,
  });

  final String url;
  final double height;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url,
        height: height,
        width: width,
        fit: BoxFit.cover,
        errorBuilder: (context, _, _) => Container(
          height: height,
          width: width,
          color: Colors.white.withValues(alpha: 0.08),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image_outlined,
                size: height < 70 ? 18 : 24,
                color: Colors.white.withValues(alpha: 0.55),
              ),
              if (height >= 70) ...[
                const SizedBox(height: 4),
                Text(
                  'Image not reachable',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// OS notification tray rendering, matching how FCM lays out an image push:
/// collapsed shows a thumbnail, expanded shows the full 2:1 image below.
class PushPreview extends StatelessWidget {
  const PushPreview({
    super.key,
    required this.title,
    required this.body,
    required this.bengali,
    this.imageUrl,
    this.expanded = true,
  });

  final String title;
  final String body;
  final bool bengali;
  final String? imageUrl;
  final bool expanded;

  bool get _hasImage => (imageUrl ?? '').trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111417),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_florist,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Joba',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'now',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title.isEmpty ? 'Notification title' : title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: bengali
                          ? AppTheme.bengali(
                              context,
                              fontSize: 13.5,
                              color: Colors.white,
                            )
                          : const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      body.isEmpty ? 'Notification body…' : body,
                      maxLines: expanded ? 4 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: bengali
                          ? AppTheme.bengali(
                              context,
                              fontSize: 12,
                              color: Colors.white70,
                            )
                          : const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                    ),
                  ],
                ),
              ),
              // Collapsed trays show the image as a small square thumbnail.
              if (_hasImage && !expanded) ...[
                const SizedBox(width: 10),
                PreviewImage(url: imageUrl!, height: 42, width: 42, radius: 8),
              ],
            ],
          ),
          if (_hasImage && expanded) ...[
            const SizedBox(height: 10),
            PreviewImage(url: imageUrl!, height: 132),
          ],
        ],
      ),
    );
  }
}

/// In-app dialog rendering. Layout mirrors what the client builds from the
/// campaign document.
class InAppPreview extends StatelessWidget {
  const InAppPreview({
    super.key,
    required this.title,
    required this.body,
    required this.bengali,
    required this.layout,
    this.imageUrl,
    this.actionLabel,
  });

  final String title;
  final String body;
  final bool bengali;
  final InAppLayout layout;
  final String? imageUrl;
  final String? actionLabel;

  bool get _hasImage => (imageUrl ?? '').trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Scrim, so the dialog reads as an overlay rather than a page.
        color: const Color(0xFF1B1F24).withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: switch (layout) {
        InAppLayout.banner => _banner(context),
        InAppLayout.imageOnly => _imageOnly(context),
        InAppLayout.modal => _sheet(context, compact: false),
        InAppLayout.card => _sheet(context, compact: true),
      },
    );
  }

  TextStyle _titleStyle(BuildContext context) => bengali
      ? AppTheme.bengali(
          context,
          fontSize: 15,
          color: const Color(0xFF16181C),
        ).copyWith(fontWeight: FontWeight.w700)
      : const TextStyle(
          color: Color(0xFF16181C),
          fontSize: 15,
          fontWeight: FontWeight.w700,
        );

  TextStyle _bodyStyle(BuildContext context) => bengali
      ? AppTheme.bengali(
          context,
          fontSize: 12.5,
          color: const Color(0xFF5A6169),
        )
      : const TextStyle(color: Color(0xFF5A6169), fontSize: 12.5, height: 1.45);

  Widget _shell({required Widget child, EdgeInsets? padding}) => Container(
    width: double.infinity,
    padding: padding ?? const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: child,
  );

  Widget _sheet(BuildContext context, {required bool compact}) {
    return _shell(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_hasImage)
            PreviewImage(url: imageUrl!, height: compact ? 96 : 128, radius: 0),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? 'Dialog title' : title,
                  style: _titleStyle(context),
                ),
                const SizedBox(height: 6),
                Text(
                  body.isEmpty ? 'Dialog message…' : body,
                  style: _bodyStyle(context),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Dismiss',
                      style: TextStyle(
                        color: const Color(0xFF5A6169).withValues(alpha: 0.9),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    if ((actionLabel ?? '').trim().isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          actionLabel!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _banner(BuildContext context) {
    return _shell(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          if (_hasImage)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: PreviewImage(
                url: imageUrl!,
                height: 38,
                width: 38,
                radius: 8,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? 'Banner title' : title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _titleStyle(context).copyWith(fontSize: 13),
                ),
                Text(
                  body.isEmpty ? 'Banner message…' : body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _bodyStyle(context).copyWith(fontSize: 11.5),
                ),
              ],
            ),
          ),
          const Icon(Icons.close, size: 16, color: Color(0xFF5A6169)),
        ],
      ),
    );
  }

  Widget _imageOnly(BuildContext context) {
    if (!_hasImage) {
      return _shell(
        child: Row(
          children: [
            const Icon(
              Icons.image_outlined,
              size: 18,
              color: Color(0xFF5A6169),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Image-only dialogs need an image.',
                style: _bodyStyle(context),
              ),
            ),
          ],
        ),
      );
    }
    return Stack(
      alignment: Alignment.topRight,
      children: [
        PreviewImage(url: imageUrl!, height: 190, radius: 16),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, size: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
