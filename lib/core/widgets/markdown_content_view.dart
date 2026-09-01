import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';

/// Reusable Markdown Content Viewer for Joba Admin
/// Renders structured Markdown with Bengali/English typography, headings, lists, quotes, and inline bold/italic/links.
class MarkdownContentView extends StatelessWidget {
  final String data;
  final bool isBengali;
  final TextStyle? baseStyle;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool selectable;

  const MarkdownContentView({
    super.key,
    required this.data,
    this.isBengali = true,
    this.baseStyle,
    this.maxLines,
    this.overflow,
    this.selectable = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final rawText = data.trim();

    if (rawText.isEmpty) {
      return Text(
        'No content available',
        style: TextStyle(
          color: palette.textSecondary,
          fontSize: 13,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    // If maxLines is set (e.g. preview snippet), render truncated rich inline text
    if (maxLines != null) {
      return _buildTruncatedPreview(context, rawText, palette);
    }

    final lines = rawText.split('\n');
    final children = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        children.add(const SizedBox(height: 8));
        continue;
      }

      if (trimmed.startsWith('# ')) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(
              trimmed.substring(2),
              style: (isBengali ? AppTheme.bengali(context) : const TextStyle())
                  .copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: palette.textPrimary,
              ),
            ),
          ),
        );
      } else if (trimmed.startsWith('## ')) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Text(
              trimmed.substring(3),
              style: (isBengali ? AppTheme.bengali(context) : const TextStyle())
                  .copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
              ),
            ),
          ),
        );
      } else if (trimmed.startsWith('### ')) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 2),
            child: Text(
              trimmed.substring(4),
              style: (isBengali ? AppTheme.bengali(context) : const TextStyle())
                  .copyWith(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
              ),
            ),
          ),
        );
      } else if (trimmed.startsWith('> ')) {
        children.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: const Border(
                left: BorderSide(color: AppColors.primary, width: 3.5),
              ),
            ),
            child: Text(
              trimmed.substring(2),
              style: (isBengali ? AppTheme.bengali(context) : const TextStyle())
                  .copyWith(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: palette.textPrimary,
              ),
            ),
          ),
        );
      } else if (trimmed == '---' || trimmed == '***') {
        children.add(
          Divider(color: palette.border, height: 20),
        );
      } else if (trimmed.startsWith('• ') ||
          trimmed.startsWith('- ') ||
          trimmed.startsWith('* ')) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 7, right: 8),
                  child: CircleAvatar(
                    radius: 3,
                    backgroundColor: AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _buildRichInlineText(
                    context,
                    trimmed.substring(2),
                    isBengali,
                    palette,
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (RegExp(r'^\d+\.\s').hasMatch(trimmed)) {
        final match = RegExp(r'^(\d+\.)\s*(.*)').firstMatch(trimmed);
        final num = match?.group(1) ?? '•';
        final text = match?.group(2) ?? '';
        children.add(
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$num ',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontSize: 13.5,
                  ),
                ),
                Expanded(
                  child: _buildRichInlineText(
                    context,
                    text,
                    isBengali,
                    palette,
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _buildRichInlineText(
              context,
              trimmed,
              isBengali,
              palette,
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Widget _buildTruncatedPreview(
    BuildContext context,
    String raw,
    AppPalette palette,
  ) {
    // Strip markdown tags for clean compact preview
    final cleaned = raw
        .replaceAll(RegExp(r'#+\s*'), '')
        .replaceAll(RegExp(r'[\*\_\~]'), '')
        .replaceAll(RegExp(r'>\s*'), '');

    return Text(
      cleaned,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.ellipsis,
      style: (isBengali ? AppTheme.bengali(context) : const TextStyle())
          .copyWith(
        fontSize: 13,
        height: 1.5,
        color: palette.textSecondary,
      ),
    );
  }

  Widget _buildRichInlineText(
    BuildContext context,
    String text,
    bool isBengali,
    AppPalette palette,
  ) {
    final spans = <TextSpan>[];
    final regex = RegExp(
        r'(\*\*(.*?)\*\*|__(.*?)__|~~(.*?)~~|\*(.*?)\*|_(.*?)_|\[(.*?)\]\((.*?)\))');
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }

      if (match.group(2) != null || match.group(3) != null) {
        // Bold: **text** or __text__
        final boldContent = match.group(2) ?? match.group(3);
        spans.add(TextSpan(
          text: boldContent,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ));
      } else if (match.group(4) != null) {
        // Strike: ~~text~~
        spans.add(TextSpan(
          text: match.group(4),
          style: const TextStyle(decoration: TextDecoration.lineThrough),
        ));
      } else if (match.group(5) != null || match.group(6) != null) {
        // Italic: *text* or _text_
        final italicContent = match.group(5) ?? match.group(6);
        spans.add(TextSpan(
          text: italicContent,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ));
      } else if (match.group(7) != null && match.group(8) != null) {
        // Link: [text](url)
        spans.add(TextSpan(
          text: match.group(7),
          style: const TextStyle(
            color: AppColors.primary,
            decoration: TextDecoration.underline,
          ),
        ));
      }
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    final textStyle = baseStyle ??
        (isBengali ? AppTheme.bengali(context) : const TextStyle()).copyWith(
          fontSize: 13.5,
          height: 1.65,
          color: palette.textPrimary,
        );

    return Text.rich(
      TextSpan(children: spans),
      style: textStyle,
    );
  }
}
