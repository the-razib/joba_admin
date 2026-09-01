import 'dart:async';

import 'package:flutter/material.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:just_audio/just_audio.dart';

/// Inline audio player card for remote narration audio.
///
/// Used in the article details "SEO & Media" tab and the reader preview
/// dialog. Loads the URL eagerly so the total duration is known up-front,
/// and supports play/pause, seeking and retry after a load failure.
class AudioPlayerCard extends StatefulWidget {
  const AudioPlayerCard({super.key, required this.label, required this.url});

  final String label;
  final String url;

  @override
  State<AudioPlayerCard> createState() => _AudioPlayerCardState();
}

class _AudioPlayerCardState extends State<AudioPlayerCard> {
  AudioPlayer? _player;
  StreamSubscription<ProcessingState>? _completedSub;
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;

  bool _loading = false;
  bool _failed = false;
  bool _playing = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  @override
  void didUpdateWidget(covariant AudioPlayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _position = Duration.zero;
      _duration = Duration.zero;
      _prepare();
    }
  }

  @override
  void dispose() {
    _completedSub?.cancel();
    _stateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _player?.dispose();
    super.dispose();
  }

  Future<void> _prepare() async {
    // Recreate the player so a URL change can never race an in-flight load.
    await _teardownPlayer();
    if (!mounted) return;
    setState(() {
      _loading = true;
      _failed = false;
      _playing = false;
    });
    try {
      final player = _player = AudioPlayer();
      _completedSub = player.processingStateStream.listen((state) {
        if (state == ProcessingState.completed) {
          player.seek(Duration.zero);
        }
      });
      _stateSub = player.playerStateStream.listen((state) {
        if (mounted) setState(() => _playing = state.playing);
      });
      _positionSub = player.positionStream.listen((pos) {
        if (mounted) setState(() => _position = pos);
      });
      _durationSub = player.durationStream.listen((dur) {
        if (mounted && dur != null) setState(() => _duration = dur);
      });

      await player.setUrl(widget.url);
      if (mounted) setState(() => _loading = false);
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
          _playing = false;
        });
      }
    }
  }

  Future<void> _teardownPlayer() async {
    await _completedSub?.cancel();
    _completedSub = null;
    await _stateSub?.cancel();
    _stateSub = null;
    await _positionSub?.cancel();
    _positionSub = null;
    await _durationSub?.cancel();
    _durationSub = null;
    await _player?.dispose();
    _player = null;
  }

  Future<void> _toggle() async {
    if (_failed) {
      await _prepare();
      if (_failed) return;
    }
    final player = _player;
    if (player == null) return;
    try {
      if (player.playing) {
        await player.pause();
      } else {
        if (player.audioSource == null) await player.setUrl(widget.url);
        unawaited(player.play());
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final totalMs = _duration.inMilliseconds;
    final posMs = totalMs > 0 ? _position.inMilliseconds.clamp(0, totalMs) : 0;
    final durationLabel = totalMs > 0 ? _fmt(_duration) : '--:--';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: palette.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          _playButton(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _failed ? Icons.error_outline : Icons.audiotrack,
                      size: 14,
                      color: _failed ? AppColors.danger : AppColors.purple,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _failed
                            ? '${widget.label} — could not load audio'
                            : widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: palette.border,
                          thumbColor: AppColors.primary,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 7,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 12,
                          ),
                        ),
                        child: Slider(
                          value: posMs.toDouble(),
                          max: (totalMs > 0 ? totalMs : 1).toDouble(),
                          onChanged:
                              (totalMs > 0 && !_failed && !_loading)
                              ? (v) {
                                  final d = Duration(milliseconds: v.toInt());
                                  _player?.seek(d);
                                  setState(() => _position = d);
                                }
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_fmt(_position)} / $durationLabel',
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 11,
                        fontFeatures: const [FontFeature.tabularFigures()],
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

  Widget _playButton() {
    if (_loading) {
      return const SizedBox(
        width: 38,
        height: 38,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    return IconButton(
      onPressed: _toggle,
      iconSize: 34,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
      tooltip: _failed ? 'Retry' : _playing ? 'Pause' : 'Play',
      icon: Icon(
        _failed
            ? Icons.refresh
            : _playing
            ? Icons.pause_circle_filled
            : Icons.play_circle_filled,
        color: _failed ? AppColors.danger : AppColors.primary,
      ),
    );
  }
}
