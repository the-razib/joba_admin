import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/widgets/bilingual_text_field.dart';

/// Bilingual section of the Article Editor: Bengali & English title, subtitle, and markdown body inputs.
class ArticleEditorBilingualSection extends StatelessWidget {
  const ArticleEditorBilingualSection({
    super.key,
    required this.titleBn,
    required this.titleEn,
    required this.subBn,
    required this.subEn,
    required this.contentBn,
    required this.contentEn,
  });

  final TextEditingController titleBn;
  final TextEditingController titleEn;
  final TextEditingController subBn;
  final TextEditingController subEn;
  final TextEditingController contentBn;
  final TextEditingController contentEn;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bilingual Content',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Articles must be provided in both বাংলা and English.',
              style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
            ),
            const SizedBox(height: 16),
            BilingualField(
              label: 'Title',
              bnController: titleBn,
              enController: titleEn,
              hintBn: 'নিবন্ধের শিরোনাম...',
              hintEn: 'Article title...',
            ),
            const SizedBox(height: 14),
            BilingualField(
              label: 'Short Description',
              bnController: subBn,
              enController: subEn,
              hintBn: 'সংক্ষিপ্ত বর্ণনা (তালিকায় দেখানোর জন্য)...',
              hintEn: 'Short summary for list views...',
              maxLines: 2,
            ),
            const SizedBox(height: 14),
            BilingualField(
              label: 'Article Body (Markdown supported)',
              bnController: contentBn,
              enController: contentEn,
              hintBn: 'বাংলায় বিস্তারিত নিবন্ধ লিখুন...',
              hintEn: 'Full article text in English...',
              maxLines: 12,
            ),
          ],
        ),
      ),
    );
  }
}
