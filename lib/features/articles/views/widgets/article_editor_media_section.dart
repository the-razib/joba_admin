import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/widgets/audio_upload_field.dart';
import 'package:joba_admin/core/widgets/image_upload_field.dart';

/// Media uploads section of the Article Editor: Cover image and BN/EN audio narrations.
class ArticleEditorMediaSection extends StatelessWidget {
  const ArticleEditorMediaSection({
    super.key,
    required this.imagePath,
    required this.audioBn,
    required this.audioEn,
    required this.onImageChanged,
    required this.onAudioBnChanged,
    required this.onAudioEnChanged,
  });

  final String? imagePath;
  final String? audioBn;
  final String? audioEn;
  final ValueChanged<String?> onImageChanged;
  final ValueChanged<String?> onAudioBnChanged;
  final ValueChanged<String?> onAudioEnChanged;

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
              'Media',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            ImageUploadField(
              label: 'Cover Image (16:9 recommended)',
              currentPath: imagePath,
              onChanged: (ImagePick? pick) => onImageChanged(pick?.path),
            ),
            const SizedBox(height: 14),
            AudioUploadField(
              label: 'Audio Narration — বাংলা',
              currentPath: audioBn,
              currentLabel: audioBn != null ? 'Audio file' : null,
              onChanged: (AudioPick? pick) => onAudioBnChanged(pick?.path),
            ),
            const SizedBox(height: 14),
            AudioUploadField(
              label: 'Audio Narration — English',
              currentPath: audioEn,
              currentLabel: audioEn != null ? 'Audio file' : null,
              onChanged: (AudioPick? pick) => onAudioEnChanged(pick?.path),
            ),
          ],
        ),
      ),
    );
  }
}
