import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/services/auth_service.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/article_thumb.dart';
import 'package:joba_admin/core/widgets/audio_player_card.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/core/widgets/confirm_dialog.dart';
import 'package:joba_admin/core/widgets/markdown_content_view.dart';
import 'package:joba_admin/features/articles/controllers/articles_controller.dart';
import 'package:joba_admin/features/articles/models/article.dart';

/// Body content of article detail panel and mobile slide-over.
class ArticleDetailsBody extends StatefulWidget {
  const ArticleDetailsBody({super.key, required this.article});

  final Article article;

  @override
  State<ArticleDetailsBody> createState() => _ArticleDetailsBodyState();
}

class _ArticleDetailsBodyState extends State<ArticleDetailsBody> {
  int _tab = 0;
  bool _bnReader = true;

  Article get a => widget.article;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final controller = Get.find<ArticlesController>();
    final bool canManage = Get.isRegistered<AuthService>()
        ? Get.find<AuthService>().canManageContent
        : true;
    final bool isSuper = Get.isRegistered<AuthService>()
        ? Get.find<AuthService>().canManageAdmins
        : true;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ArticleThumb(
                      imagePath: a.imagePath,
                      width: 108,
                      height: 84,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.titleBn,
                            style: AppTheme.bengali(
                              context,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            a.titleEn,
                            style: TextStyle(
                              color: palette.textSecondary,
                              fontSize: 12.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              articleStatusBadge(a.status),
                              if (a.featured)
                                const PillBadge(
                                  label: 'Featured',
                                  color: AppColors.warning,
                                  icon: Icons.star,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (a.isMedicallyReviewed) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1EAE8D).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF1EAE8D).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF1EAE8D,
                            ).withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF1EAE8D),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${a.medicalReviewerBn} (মেডিকেল রিভিউ)',
                                style: AppTheme.bengali(context).copyWith(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: palette.textPrimary,
                                ),
                              ),
                              Text(
                                '⏱️ ${a.readingTimeMin} মিনিট পড়া • Verified Medical Content',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: palette.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                _metaRow(context, 'Slug', a.slug, copyable: true),
                _metaRow(
                  context,
                  'Category',
                  controller.categories
                          .firstWhereOrNull((c) => c.id == a.categoryId)
                          ?.nameEn ??
                      a.categoryId,
                ),
                _metaRow(context, 'Tags', a.tags.join(', ')),
                _metaRow(context, 'Updated', formatDateTime(a.updatedAt)),
                const SizedBox(height: 14),
                _tabRow(context),
                const SizedBox(height: 16),
                if (_tab == 0) _contentTab(context),
                if (_tab == 1) _seoMediaTab(context),
                if (_tab == 2) _statsTab(context),
                if (_tab == 3) _historyTab(context),
                if (isSuper)
                  Container(
                    margin: const EdgeInsets.only(top: 18),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.danger.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.danger,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Danger Zone',
                                style: TextStyle(
                                  color: AppColors.danger,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Delete this article permanently. This action cannot be undone.',
                                style: TextStyle(
                                  color: palette.textSecondary,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            side: const BorderSide(color: AppColors.danger),
                          ),
                          onPressed: () async {
                            final ok = await showConfirmDialog(
                              context,
                              title: 'Delete article?',
                              message:
                                  '"${a.titleEn}" and all associated files (cover image, audio narrations) will be permanently deleted.',
                              confirmLabel: 'Delete',
                              danger: true,
                            );
                            if (ok) await controller.deleteArticle(a.id);
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: palette.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showReader(context),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('Preview'),
                ),
              ),
              if (canManage) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => controller.startEdit(a),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit Article'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _metaRow(
    BuildContext context,
    String label,
    String value, {
    bool copyable = false,
  }) {
    if (value.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                color: context.palette.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: context.palette.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (copyable)
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Copy slug',
              icon: const Icon(Icons.copy_outlined, size: 15),
              onPressed: () => Clipboard.setData(ClipboardData(text: value)),
            ),
        ],
      ),
    );
  }

  Widget _tabRow(BuildContext context) {
    const tabs = ['Content', 'SEO & Media', 'Stats', 'History'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            InkWell(
              onTap: () => setState(() => _tab = i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _tab == i ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tabs[i],
                  style: TextStyle(
                    color: _tab == i
                        ? AppColors.primary
                        : context.palette.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ],
      ),
    );
  }

  Widget _contentTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Short Description',
          style: TextStyle(
            color: context.palette.textPrimary,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          a.subtitleBn,
          style: AppTheme.bengali(
            context,
            fontSize: 13,
            color: context.palette.textSecondary,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Content',
          style: TextStyle(
            color: context.palette.textPrimary,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        MarkdownContentView(
          data: a.contentBn,
          isBengali: true,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => _showReader(context),
          child: const Text('View Full Content'),
        ),
      ],
    );
  }

  Widget _seoMediaTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _metaRow(context, 'SEO title', a.seoTitle),
        _metaRow(context, 'SEO desc', a.seoDescription),
        const SizedBox(height: 8),
        Text(
          'Media',
          style: TextStyle(
            color: context.palette.textPrimary,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        _audioRow(context, 'Audio — বাংলা', a.audioBnPath),
        const SizedBox(height: 8),
        _audioRow(context, 'Audio — English', a.audioEnPath),
      ],
    );
  }

  Widget _audioRow(BuildContext context, String label, String? path) {
    final has = path != null && path.isNotEmpty;
    if (has) {
      return AudioPlayerCard(label: label, url: path);
    }
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.palette.inputFill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.audiotrack,
            size: 17,
            color: context.palette.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label — not uploaded',
              style: TextStyle(
                color: context.palette.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsTab(BuildContext context) {
    final tiles = [
      (Icons.visibility_outlined, 'Total Views', a.views, AppColors.primary),
      (
        Icons.bookmark_outline_rounded,
        'Bookmarks',
        a.bookmarks,
        AppColors.accent,
      ),
      (
        Icons.chat_bubble_outline,
        'Comments',
        a.commentsCount,
        AppColors.warning,
      ),
      (Icons.share_outlined, 'Shares', a.shares, AppColors.info),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 92,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: tiles.length,
      itemBuilder: (_, i) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: tiles[i].$4.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(tiles[i].$1, color: tiles[i].$4, size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  compactNumber(tiles[i].$3),
                  style: TextStyle(
                    color: context.palette.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  tiles[i].$2,
                  style: TextStyle(
                    color: context.palette.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyTab(BuildContext context) {
    return Column(
      children: [
        for (var v = a.version; v >= 1; v--)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        v == a.version
                            ? 'Current version (v$v)'
                            : 'Version v$v',
                        style: TextStyle(
                          color: context.palette.textPrimary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${formatDateTime(a.updatedAt.subtract(Duration(days: (a.version - v) * 9)))} • by ${a.createdBy}',
                        style: TextStyle(
                          color: context.palette.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showReader(BuildContext context) {
    setState(() => _bnReader = true);
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _bnReader ? a.titleBn : a.titleEn,
                          style: _bnReader
                              ? AppTheme.bengali(
                                  context,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                )
                              : TextStyle(
                                  color: context.palette.textPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      for (final bn in [true, false])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            selected: _bnReader == bn,
                            label: Text(
                              bn ? 'বাংলা' : 'English',
                              style: const TextStyle(fontSize: 12),
                            ),
                            onSelected: (_) => setState(() => _bnReader = bn),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Builder(
                    builder: (_) {
                      final url = _bnReader ? a.audioBnPath : a.audioEnPath;
                      if (url == null || url.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: AudioPlayerCard(
                          label: _bnReader
                              ? 'অডিও ন্যারেশন — বাংলা'
                              : 'Audio Narration — English',
                          url: url,
                        ),
                      );
                    },
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: MarkdownContentView(
                        data: _bnReader ? a.contentBn : a.contentEn,
                        isBengali: _bnReader,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
