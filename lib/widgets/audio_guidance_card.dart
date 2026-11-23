import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../l10n/strings.dart';
import '../models/technique.dart';
import '../services/audio_download_service.dart';
import '../services/date_utils.dart';
import '../theme/app_colors.dart';
import 'common.dart';

/// Download-once audio guidance with an offline player.
class AudioGuidanceCard extends StatelessWidget {
  const AudioGuidanceCard({super.key, required this.technique});

  final Technique technique;

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioDownloadService>();
    final state = audio.stateOf(technique.id);
    final s = context.s;
    final theme = Theme.of(context);

    Widget body;
    switch (state.status) {
      case AudioStatus.downloaded:
        body = _LocalPlayer(path: audio.localPath(technique.id)!, onDelete: () => _confirmDelete(context, audio));
      case AudioStatus.downloading:
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(s.downloadingPercent((state.progress * 100).round()))),
                TextButton(onPressed: () => audio.cancel(technique.id), child: Text(s.cancel)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: state.progress == 0 ? null : state.progress, minHeight: 8),
            ),
          ],
        );
      case AudioStatus.failed:
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline_rounded, color: theme.colorScheme.error, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(s.audioError(state.error), style: theme.textTheme.bodySmall)),
              ],
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => audio.download(technique),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(s.retry),
            ),
          ],
        );
      case AudioStatus.notDownloaded:
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.audioDownloadHint, style: theme.textTheme.bodySmall?.copyWith(color: context.softText)),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => audio.download(technique),
              icon: const Icon(Icons.download_rounded),
              label: Text(s.downloadAudio),
            ),
          ],
        );
    }

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconBadge(Icons.headphones_rounded, color: AppColors.sky, size: 40),
              const SizedBox(width: 12),
              Expanded(child: Text(s.audioGuidance, style: theme.textTheme.titleMedium)),
              _StatusPill(status: state.status),
            ],
          ),
          const SizedBox(height: 14),
          body,
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, AudioDownloadService audio) async {
    final s = context.s;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(s.deleteDownloadTitle),
        content: Text(s.deleteDownloadBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(s.cancel)),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(s.delete)),
        ],
      ),
    );
    if (ok == true) await audio.delete(technique.id);
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final AudioStatus status;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final downloaded = status == AudioStatus.downloaded;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (downloaded ? AppColors.mintDeep : AppColors.creamDeep).withValues(alpha: context.isDark ? 0.25 : 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(downloaded ? Icons.offline_pin_rounded : Icons.cloud_outlined, size: 14),
          const SizedBox(width: 4),
          Text(downloaded ? s.downloaded : s.notDownloaded, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _LocalPlayer extends StatefulWidget {
  const _LocalPlayer({required this.path, required this.onDelete});

  final String path;
  final VoidCallback onDelete;

  @override
  State<_LocalPlayer> createState() => _LocalPlayerState();
}

class _LocalPlayerState extends State<_LocalPlayer> {
  final _player = AudioPlayer();
  bool _ready = false;
  bool _error = false;
  double? _dragValue;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await _player.setFilePath(widget.path);
      if (mounted) setState(() => _ready = true);
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    if (_error) {
      return Row(
        children: [
          Expanded(child: Text(s.audioCorrupt)),
          TextButton(onPressed: widget.onDelete, child: Text(s.delete)),
        ],
      );
    }
    return StreamBuilder<PlayerState>(
      stream: _player.playerStateStream,
      builder: (context, snap) {
        final playing = snap.data?.playing ?? false;
        final completed = snap.data?.processingState == ProcessingState.completed;
        return Column(
          children: [
            StreamBuilder<Duration>(
              stream: _player.positionStream,
              builder: (context, posSnap) {
                final total = _player.duration ?? Duration.zero;
                final pos = posSnap.data ?? Duration.zero;
                final max = total.inMilliseconds.toDouble();
                final value = (_dragValue ?? pos.inMilliseconds.toDouble()).clamp(0.0, max <= 0 ? 1.0 : max);
                return Column(
                  children: [
                    Slider(
                      value: value,
                      max: max <= 0 ? 1 : max,
                      onChanged: _ready ? (v) => setState(() => _dragValue = v) : null,
                      onChangeEnd: (v) async {
                        await _player.seek(Duration(milliseconds: v.round()));
                        if (mounted) setState(() => _dragValue = null);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(formatClock(value ~/ 1000), style: Theme.of(context).textTheme.labelSmall),
                          Text(formatClock(total.inSeconds), style: Theme.of(context).textTheme.labelSmall),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: s.replay,
                  onPressed: _ready
                      ? () async {
                          await _player.seek(Duration.zero);
                          unawaited(_player.play());
                        }
                      : null,
                  icon: const Icon(Icons.replay_rounded),
                ),
                const SizedBox(width: 12),
                IconButton.filled(
                  iconSize: 34,
                  tooltip: playing && !completed ? s.pause : s.play,
                  onPressed: !_ready
                      ? null
                      : () async {
                          if (completed) {
                            await _player.seek(Duration.zero);
                            unawaited(_player.play());
                          } else if (playing) {
                            await _player.pause();
                          } else {
                            unawaited(_player.play());
                          }
                        },
                  icon: Icon(playing && !completed ? Icons.pause_rounded : Icons.play_arrow_rounded),
                ),
                const SizedBox(width: 12),
                IconButton(
                  tooltip: s.deleteDownload,
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
