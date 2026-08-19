import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/app_toast.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:just_audio/just_audio.dart';

class AudioPick {
  const AudioPick({
    required this.name,
    required this.size,
    this.bytes,
    this.path,
  });

  final String name;
  final int size;
  final List<int>? bytes;
  final String? path;
}

/// Audio upload row with inline preview playback.
/// Local playback works on desktop/mobile; on web the preview becomes
/// available after the real upload (Phase 3 Storage URL).
class AudioUploadField extends StatefulWidget {
  const AudioUploadField({
    super.key,
    required this.label,
    this.currentPath,
    this.currentLabel,
    required this.onChanged,
  });

  final String label; // e.g. 'Audio — বাংলা (BN)'
  final String? currentPath; // existing remote url (Phase 3)
  final String? currentLabel; // existing file name
  final ValueChanged<AudioPick?> onChanged;

  @override
  State<AudioUploadField> createState() => _AudioUploadFieldState();
}

class _AudioUploadFieldState extends State<AudioUploadField> {
  AudioPick? _picked;
  AudioPlayer? _player;
  bool _playing = false;

  bool get _hasAudio => _picked != null || widget.currentPath != null;

  bool get _canPlayLocally =>
      _picked?.path != null ||
      (widget.currentPath != null && widget.currentPath!.startsWith('http'));

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final f = result.files.first;
    setState(() {
      _picked = AudioPick(
        name: f.name,
        size: f.size,
        bytes: f.bytes,
        path: f.path,
      );
    });
    widget.onChanged(_picked);
  }

  void _remove() {
    _player?.stop();
    setState(() => _playing = false);
    _picked = null;
    widget.onChanged(null);
  }

  Future<void> _togglePlay() async {
    _player ??= AudioPlayer();
    final player = _player!;
    if (_playing) {
      await player.pause();
      setState(() => _playing = false);
      return;
    }
    try {
      if (player.audioSource == null) {
        if (_picked?.path != null) {
          await player.setFilePath(_picked!.path!);
        } else if (widget.currentPath != null) {
          await player.setUrl(widget.currentPath!);
        } else {
          AppToast.info(
            'Preview not available',
            'Web preview is available after upload (Phase 3 Storage).',
          );
          return;
        }
      }
      await player.play();
      setState(() => _playing = true);
      player.processingStateStream.listen((state) {
        if (state == ProcessingState.completed && mounted) {
          setState(() => _playing = false);
          player.seek(Duration.zero);
        }
      });
    } catch (_) {
      AppToast.error(
        'Audio Error',
        'Could not play this audio file.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final name = _picked?.name ?? widget.currentLabel ?? widget.currentPath;
    final sub = _picked != null
        ? '${_picked!.name} • ${fileSizeLabel(_picked!.size)} (new)'
        : name ?? 'No audio uploaded';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _hasAudio
              ? AppColors.primary.withValues(alpha: 0.4)
              : palette.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.audiotrack,
              color: AppColors.purple,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
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
                const SizedBox(height: 2),
                Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          if (_hasAudio && _canPlayLocally)
            IconButton(
              tooltip: _playing ? 'Pause' : 'Play preview',
              onPressed: _togglePlay,
              icon: Icon(
                _playing
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_outline,
                color: AppColors.primary,
              ),
            ),
          IconButton(
            tooltip: _picked == null ? 'Upload audio' : 'Replace audio',
            onPressed: _pick,
            icon: Icon(Icons.upload_file_outlined, color: palette.textPrimary),
          ),
          if (_hasAudio)
            IconButton(
              tooltip: 'Remove',
              onPressed: _remove,
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            ),
        ],
      ),
    );
  }
}
