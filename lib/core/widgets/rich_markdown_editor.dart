import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/widgets/markdown_content_view.dart';

/// Rich Markdown Editor widget with formatting toolbar (Bold, Italic, H1, H2, H3, Bullets, Numbers, Quotes, Links)
/// and a Live Preview mode.
class RichMarkdownEditor extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool isBengali;
  final String hintText;
  final int minLines;

  const RichMarkdownEditor({
    super.key,
    required this.label,
    required this.controller,
    this.isBengali = false,
    this.hintText = 'Write content in markdown...',
    this.minLines = 10,
  });

  @override
  State<RichMarkdownEditor> createState() => _RichMarkdownEditorState();
}

class _RichMarkdownEditorState extends State<RichMarkdownEditor> {
  bool _isPreviewMode = false;

  void _applyFormat({
    String prefix = '',
    String suffix = '',
    String defaultPlaceholder = '',
    bool isLinePrefix = false,
  }) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;

    if (!selection.isValid || selection.isCollapsed) {
      final insertPos = selection.isValid ? selection.baseOffset : text.length;
      final newText = text.replaceRange(
        insertPos,
        insertPos,
        '$prefix$defaultPlaceholder$suffix',
      );
      widget.controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection(
          baseOffset: insertPos + prefix.length,
          extentOffset: insertPos + prefix.length + defaultPlaceholder.length,
        ),
      );
      return;
    }

    final selectedText = text.substring(selection.start, selection.end);
    if (isLinePrefix) {
      final lines = selectedText.split('\n');
      final formattedLines = lines.map((l) => '$prefix$l$suffix').join('\n');
      final newText = text.replaceRange(selection.start, selection.end, formattedLines);
      widget.controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection(
          baseOffset: selection.start,
          extentOffset: selection.start + formattedLines.length,
        ),
      );
    } else {
      final formatted = '$prefix$selectedText$suffix';
      final newText = text.replaceRange(selection.start, selection.end, formatted);
      widget.controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection(
          baseOffset: selection.start,
          extentOffset: selection.start + formatted.length,
        ),
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final chipColor = widget.isBengali ? AppColors.accent : AppColors.info;
    final chipLabel = widget.isBengali ? 'BN' : 'EN';

    return Container(
      decoration: BoxDecoration(
        color: palette.inputFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toolbar Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
              border: Border(bottom: BorderSide(color: palette.border)),
            ),
            child: Row(
              children: [
                // Language Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: chipColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    chipLabel,
                    style: TextStyle(
                      color: chipColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: palette.textPrimary,
                  ),
                ),
                const Spacer(),

                // Mode Selector (Write vs Preview)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: palette.inputFill,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      _tabButton(
                        label: 'Edit',
                        icon: Icons.edit_note_rounded,
                        isSelected: !_isPreviewMode,
                        onTap: () => setState(() => _isPreviewMode = false),
                      ),
                      _tabButton(
                        label: 'Preview',
                        icon: Icons.visibility_outlined,
                        isSelected: _isPreviewMode,
                        onTap: () => setState(() => _isPreviewMode = true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Formatting Toolbar (Only in Edit mode)
          if (!_isPreviewMode)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: palette.card.withValues(alpha: 0.5),
                border: Border(bottom: BorderSide(color: palette.border.withValues(alpha: 0.5))),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _toolBtn(
                      icon: Icons.format_bold_rounded,
                      tooltip: 'Bold (**text**)',
                      onTap: () => _applyFormat(
                        prefix: '**',
                        suffix: '**',
                        defaultPlaceholder: widget.isBengali ? 'গুরুত্বপূর্ণ লেখা' : 'bold text',
                      ),
                    ),
                    _toolBtn(
                      icon: Icons.format_italic_rounded,
                      tooltip: 'Italic (*text*)',
                      onTap: () => _applyFormat(
                        prefix: '*',
                        suffix: '*',
                        defaultPlaceholder: widget.isBengali ? 'বাঁকা লেখা' : 'italic text',
                      ),
                    ),
                    const _ToolDivider(),
                    _toolTextBtn(
                      text: 'H1',
                      tooltip: 'Heading 1 (# Title)',
                      onTap: () => _applyFormat(
                        prefix: '\n# ',
                        suffix: '\n',
                        defaultPlaceholder: widget.isBengali ? 'প্রধান শিরোনাম' : 'Main Heading',
                      ),
                    ),
                    _toolTextBtn(
                      text: 'H2',
                      tooltip: 'Heading 2 (## Subheading)',
                      onTap: () => _applyFormat(
                        prefix: '\n## ',
                        suffix: '\n',
                        defaultPlaceholder: widget.isBengali ? 'উপশিরোনাম' : 'Section Heading',
                      ),
                    ),
                    _toolTextBtn(
                      text: 'H3',
                      tooltip: 'Heading 3 (### Subheading)',
                      onTap: () => _applyFormat(
                        prefix: '\n### ',
                        suffix: '\n',
                        defaultPlaceholder: widget.isBengali ? 'ছোট শিরোনাম' : 'Subheading',
                      ),
                    ),
                    const _ToolDivider(),
                    _toolBtn(
                      icon: Icons.format_list_bulleted_rounded,
                      tooltip: 'Bullet List (• item)',
                      onTap: () => _applyFormat(
                        prefix: '• ',
                        defaultPlaceholder: widget.isBengali ? 'পয়েন্ট বা তালিকা' : 'List item',
                        isLinePrefix: true,
                      ),
                    ),
                    _toolBtn(
                      icon: Icons.format_list_numbered_rounded,
                      tooltip: 'Numbered List (1. item)',
                      onTap: () => _applyFormat(
                        prefix: '1. ',
                        defaultPlaceholder: widget.isBengali ? 'ধাপ বা ক্রমিক' : 'Numbered step',
                        isLinePrefix: true,
                      ),
                    ),
                    _toolBtn(
                      icon: Icons.format_quote_rounded,
                      tooltip: 'Doctor Tip / Quote (> Tip)',
                      onTap: () => _applyFormat(
                        prefix: '\n> 💡 ',
                        suffix: '\n',
                        defaultPlaceholder: widget.isBengali
                            ? 'ডাক্তারের গুরুত্বপূর্ণ পরামর্শ...'
                            : 'Important doctor recommendation...',
                      ),
                    ),
                    const _ToolDivider(),
                    _toolBtn(
                      icon: Icons.link_rounded,
                      tooltip: 'Link ([text](url))',
                      onTap: () => _applyFormat(
                        prefix: '[',
                        suffix: '](https://...)',
                        defaultPlaceholder: widget.isBengali ? 'লিংকের নাম' : 'link title',
                      ),
                    ),
                    _toolBtn(
                      icon: Icons.horizontal_rule_rounded,
                      tooltip: 'Divider (---)',
                      onTap: () => _applyFormat(
                        prefix: '\n---\n',
                        defaultPlaceholder: '',
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Content Area (Editor or Live Markdown Preview)
          if (!_isPreviewMode)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: TextField(
                controller: widget.controller,
                minLines: widget.minLines,
                maxLines: null,
                style: widget.isBengali
                    ? AppTheme.bengali(context, fontSize: 14)
                    : TextStyle(color: palette.textPrimary, fontSize: 14, height: 1.6),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: (widget.isBengali
                          ? AppTheme.bengali(context, fontSize: 13.5)
                          : const TextStyle(fontSize: 13.5))
                      .copyWith(
                    color: palette.textSecondary.withValues(alpha: 0.45),
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            )
          else
            _buildMarkdownPreview(context),
        ],
      ),
    );
  }

  Widget _tabButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final palette = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? palette.card : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? AppColors.primary : palette.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : palette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return IconButton(
      icon: Icon(icon, size: 16),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onPressed: onTap,
    );
  }

  Widget _toolTextBtn({
    required String text,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    final palette = context.palette;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: palette.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarkdownPreview(BuildContext context) {
    final palette = context.palette;
    final rawText = widget.controller.text.trim();

    if (rawText.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: Text(
          'No content to preview.',
          style: TextStyle(color: palette.textSecondary, fontSize: 13),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(minHeight: 180),
      padding: const EdgeInsets.all(16),
      child: MarkdownContentView(
        data: rawText,
        isBengali: widget.isBengali,
      ),
    );
  }
}

class _ToolDivider extends StatelessWidget {
  const _ToolDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: context.palette.border,
    );
  }
}
