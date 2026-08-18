import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/widgets/bilingual_text_field.dart';
import 'package:joba_admin/core/widgets/rich_markdown_editor.dart';

/// Bilingual section of the Article Editor: Bengali & English title, subtitle, and rich markdown body inputs.
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
              'Bilingual Content & Rich Formatting',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Provide bilingual titles, summaries, and formatted Markdown content with live previews.',
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
            const SizedBox(height: 18),
            Text(
              'Article Body (Markdown Supported)',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // Bengali Body Markdown Editor
            RichMarkdownEditor(
              label: 'বাংলা বিস্তারিত নিবন্ধ',
              controller: contentBn,
              isBengali: true,
              hintText: 'বাংলায় বিস্তারিত নিবন্ধ লিখুন... (উপরের টুলবার দিয়ে বোল্ড, ইটালিক, পয়েন্ট, হেডিং যোগ করুন)',
              minLines: 8,
            ),
            const SizedBox(height: 14),

            // English Body Markdown Editor
            RichMarkdownEditor(
              label: 'English Full Article Body',
              controller: contentEn,
              isBengali: false,
              hintText: 'Full article text in English... (Use toolbar for bold, italic, bullets, headings, and quotes)',
              minLines: 8,
            ),
          ],
        ),
      ),
    );
  }
}
