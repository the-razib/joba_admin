// ignore_for_file: experimental_member_use
import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
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

/// In-memory audio source so freshly picked files can be previewed before
/// upload — on web (bytes only) and desktop (bytes or file path).
class _BytesAudioSource extends StreamAudioSource {
  _BytesAudioSource(this.bytes, this.mime);

  final Uint8List bytes;
  final String mime;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final from = start ?? 0;
    final to = end ?? bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: to - from,
      offset: from,
      stream: Stream.value(bytes.sublist(from, to)),
      contentType: mime,
    );
  }
}

/// Audio upload row with inline preview playback.
///
/// Preview priority: freshly picked bytes → picked file path → existing
/// remote Storage URL. The player is fully reset whenever the selection
/// changes, so playback always matches what is on screen.
class AudioUploadField extends StatefulWidget {
  const AudioUploadField({
    super.key,
    required this.label,
    this.currentPath,
    this.currentLabel,
    required this.onChanged,
  });

  final String label; // e.g. 'Audio — বাংলা (BN)'
  final String? currentPath; // existing remote Storage URL
  final String? currentLabel; // existing file name override
  final ValueChanged<AudioPick?> onChanged;

  @override
  State<AudioUploadField> createState() => _AudioUploadFieldState();

  /// Extracts a readable file name from a Storage download URL, e.g.
  /// `.../articles%2Fid%2F2026-09%2Fab12cd_audio_bn.mp3?alt=media…`
  /// → `ab12cd_audio_bn.mp3`.
  static String? fileNameFromUrl(String? url) {
    if (url == null || !url.startsWith('http')) return null;
    try {
      final path = Uri.parse(url).path;
      final parts = path.split(RegExp(r'%2F|/')).where((s) => s.isNotEmpty);
      if (parts.isEmpty) return null;
      final name = Uri.decodeComponent(parts.last);
      return name.isEmpty ? null : name;
    } catch (_) {
      return null;
    }
  }
}

class _AudioUploadFieldState extends State<AudioUploadField> {
  AudioPick? _picked;
  AudioPlayer? _player;
  StreamSubscription<ProcessingState>? _stateSub;
  bool _playing = false;

  bool get _hasAudio =>
      _picked != null ||
      (widget.currentPath != null && widget.currentPath!.isNotEmpty);

  bool get _canPlay =>
      (_picked?.bytes?.isNotEmpty ?? false) ||
      (_picked?.path != null) ||
      (widget.currentPath != null && widget.currentPath!.startsWith('http'));

  @override
  void dispose() {
    _stateSub?.cancel();
    _player?.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['mp3', 'm4a', 'wav', 'aac', 'ogg', 'flac'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final f = result.files.first;
    await _resetPlayer();
    setState(() {
      _picked = AudioPick(
        name: f.name,
        size: f.size,
        bytes: f.bytes,
        path: kIsWeb ? null : f.path,
      );
    });
    widget.onChanged(_picked);
  }

  Future<void> _remove() async {
    await _resetPlayer();
    setState(() => _picked = null);
    widget.onChanged(null);
  }

  /// Stops and releases the current source so the next play uses fresh data.
  Future<void> _resetPlayer() async {
    await _stateSub?.cancel();
    _stateSub = null;
    await _player?.dispose();
    _player = null;
    if (mounted) setState(() => _playing = false);
  }

  Future<void> _togglePlay() async {
    if (_playing) {
      await _player?.pause();
      if (mounted) setState(() => _playing = false);
      return;
    }

    _player ??= AudioPlayer();
    final player = _player!;
    try {
      if (player.audioSource == null) {
        final bytes = _picked?.bytes;
        if (bytes != null && bytes.isNotEmpty) {
          await player.setAudioSource(
            _BytesAudioSource(
              Uint8List.fromList(bytes),
              _mimeFor(_picked!.name),
            ),
          );
        } else if (_picked?.path != null) {
          await player.setFilePath(_picked!.path!);
        } else if (widget.currentPath != null &&
            widget.currentPath!.startsWith('http')) {
          await player.setUrl(widget.currentPath!);
        } else {
          AppToast.info(
            'Preview not available',
            'Upload an audio file to preview it.',
          );
          return;
        }
        _stateSub ??= player.processingStateStream.listen((state) {
          if (state == ProcessingState.completed && mounted) {
            setState(() => _playing = false);
            player.seek(Duration.zero);
          }
        });
      }
      unawaited(player.play());
      if (mounted) setState(() => _playing = true);
    } catch (_) {
      await _resetPlayer();
      AppToast.error('Audio Error', 'Could not play this audio file.');
    }
  }

  String _mimeFor(String name) {
    final ext = name.split('.').last.toLowerCase();
    return switch (ext) {
      'wav' => 'audio/wav',
      'm4a' || 'mp4' || 'aac' => 'audio/mp4',
      'ogg' => 'audio/ogg',
      'flac' => 'audio/flac',
      _ => 'audio/mpeg',
    };
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final name =
        _picked?.name ??
        widget.currentLabel ??
        AudioUploadField.fileNameFromUrl(widget.currentPath);
    final sub = _picked != null
        ? '${_picked!.name} • ${fileSizeLabel(_picked!.size)} (new — uploads on save)'
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
          if (_hasAudio && _canPlay)
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
