import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l_text.dart';
import '../l10n/strings.dart';
import '../models/technique.dart';
import '../services/audio_download_service.dart';
import '../services/date_utils.dart';
import '../services/music_player.dart';
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
        body = _LocalPlayer(
          technique: technique,
          path: audio.localPath(technique.id)!,
          onDelete: () => _confirmDelete(context, audio),
        );
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

/// Plays downloaded guidance through the app's shared player, so it gets the
/// same background playback and lock-screen controls as music.
class _LocalPlayer extends StatelessWidget {
  const _LocalPlayer({required this.technique, required this.path, required this.onDelete});

  final Technique technique;
  final String path;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final music = context.watch<MusicPlayer>();
    final id = '${MusicPlayer.guidancePrefix}${technique.id}';
    final active = music.isLoaded && music.isCurrent(id);
    final playing = active && music.isPlaying;
    Future<void> start() => music.playGuidance(techniqueId: technique.id, title: context.l(technique.name), path: path);

    return Column(
      children: [
        if (active)
          StreamBuilder<Duration?>(
            stream: music.player.durationStream,
            builder: (context, d) => StreamBuilder<Duration>(
              stream: music.player.positionStream,
              builder: (context, p) {
                final total = (d.data ?? Duration.zero).inMilliseconds.toDouble();
                final pos = (p.data ?? Duration.zero).inMilliseconds.toDouble().clamp(0.0, total <= 0 ? 1.0 : total);
                return Column(
                  children: [
                    Slider(
                      value: pos,
                      max: total <= 0 ? 1 : total,
                      onChanged: (v) => music.seek(Duration(milliseconds: v.round())),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(formatClock(pos ~/ 1000), style: Theme.of(context).textTheme.labelSmall),
                          Text(formatClock(total ~/ 1000), style: Theme.of(context).textTheme.labelSmall),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: s.replay,
              onPressed: () async {
                if (active) {
                  await music.seek(Duration.zero);
                  if (!music.isPlaying) await music.togglePlay();
                } else {
                  await start();
                }
              },
              icon: const Icon(Icons.replay_rounded),
            ),
            const SizedBox(width: 12),
            IconButton.filled(
              iconSize: 34,
              tooltip: playing ? s.pause : s.play,
              onPressed: () => active ? music.togglePlay() : start(),
              icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
            ),
            const SizedBox(width: 12),
            IconButton(
              tooltip: s.deleteDownload,
              onPressed: () async {
                if (active) await music.close();
                onDelete();
              },
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
      ],
    );
  }
}
