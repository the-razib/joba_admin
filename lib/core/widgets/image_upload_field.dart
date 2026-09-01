import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';

class ImagePick {
  const ImagePick({this.name, this.path, this.bytes});
  final String? name;
  final String? path;
  final List<int>? bytes;
}

/// Image picker with live preview (asset / url / freshly picked bytes).
class ImageUploadField extends StatefulWidget {
  const ImageUploadField({
    super.key,
    required this.label,
    this.currentPath,
    this.height = 150,
    required this.onChanged,
  });

  final String label;
  final String? currentPath;
  final double height;
  final ValueChanged<ImagePick?> onChanged;

  @override
  State<ImageUploadField> createState() => _ImageUploadFieldState();
}

class _ImageUploadFieldState extends State<ImageUploadField> {
  ImagePick? _picked;

  Future<void> _pick() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final f = result.files.first;
    setState(() => _picked = ImagePick(
          name: f.name,
          path: kIsWeb ? null : f.path,
          bytes: f.bytes,
        ));
    widget.onChanged(_picked);
  }

  void _remove() {
    setState(() => _picked = null);
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    Widget preview;
    if (_picked?.bytes != null) {
      preview = Image.memory(
        Uint8List.fromList(_picked!.bytes!),
        fit: BoxFit.cover,
      );
    } else if (_picked?.path != null) {
      preview = Image.asset(_picked!.path!, fit: BoxFit.cover);
    } else if (widget.currentPath != null &&
        widget.currentPath!.startsWith('http')) {
      preview = Image.network(widget.currentPath!, fit: BoxFit.cover);
    } else if (widget.currentPath != null && widget.currentPath!.isNotEmpty) {
      preview = Image.asset(widget.currentPath!, fit: BoxFit.cover);
    } else {
      preview = Container(
        color: palette.inputFill,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.image_outlined,
                size: 30,
                color: palette.textSecondary,
              ),
              const SizedBox(height: 6),
              Text(
                'No image',
                style: TextStyle(color: palette.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: widget.height,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                preview,
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Row(
                    children: [
                      _btn(Icons.upload_file_outlined, 'Upload', _pick),
                      if (_picked != null || widget.currentPath != null)
                        const SizedBox(width: 6),
                      if (_picked != null || widget.currentPath != null)
                        _btn(
                          Icons.delete_outline,
                          'Remove',
                          _remove,
                          danger: true,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _btn(
    IconData icon,
    String tooltip,
    VoidCallback onTap, {
    bool danger = false,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Icon(
            icon,
            size: 17,
            color: danger ? AppColors.danger : AppColors.textPrimaryLight,
          ),
        ),
      ),
    );
  }
}
