import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/music_categories.dart';
import '../../l10n/l_text.dart';
import '../../l10n/strings.dart';
import '../../models/music.dart';
import '../../services/audio_download_service.dart' show AudioStatus;
import '../../services/date_utils.dart';
import '../../services/music_downloads.dart';
import '../../services/music_player.dart';
import '../../services/my_music_store.dart';
import '../../theme/app_colors.dart';
import '../glow.dart';
import 'cover_art.dart';

/// Opens the full-screen player. Set by the app shell to avoid import cycles.
void Function(BuildContext context)? openMusicPlayer;

/// Animated "now playing" bars.
class NowPlayingBars extends StatefulWidget {
  const NowPlayingBars({super.key, required this.playing, this.color, this.size = 16});

  final bool playing;
  final Color? color;
  final double size;

  @override
  State<NowPlayingBars> createState() => _NowPlayingBarsState();
}

class _NowPlayingBarsState extends State<NowPlayingBars> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant NowPlayingBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (widget.playing && !reduceMotion(context)) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? accentOf(context);
    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) => Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < 3; i++)
              Container(
                width: widget.size / 4.5,
                height:
                    widget.size *
                    (widget.playing ? 0.3 + 0.7 * (0.5 + 0.5 * math.sin((_c.value + i * 0.33) * 2 * math.pi)) : 0.35),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
              ),
          ],
        ),
      ),
    );
  }
}

/// A row for one track: cover, title, artist · duration, favorite and menu.
class TrackTile extends StatelessWidget {
  const TrackTile({super.key, required this.track, required this.queue, this.playlistId, this.trailing});

  final MusicTrack track;

  /// The list this tile belongs to; playback continues through it.
  final List<MusicTrack> queue;
  final String? playlistId;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = context.s;
    final player = context.watch<MusicPlayer>();
    final downloads = context.watch<MusicDownloads>();
    final mine = context.watch<MyMusicStore>();
    final isCurrent = player.isCurrent(track.id);
    final accent = accentOf(context);
    final dl = downloads.stateOf(track.id);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () async {
        await player.playTrack(track, context: queue);
        if (context.mounted) _reportError(context, player);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CoverArt.track(track, size: 54),
                if (isCurrent)
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: NowPlayingBars(playing: player.isPlaying, color: Colors.white, size: 18),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.titleFor(context.lang),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(color: isCurrent ? accent : null),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (dl.status == AudioStatus.downloaded) ...[
                        Icon(Icons.download_done_rounded, size: 14, color: accent),
                        const SizedBox(width: 4),
                      ] else if (dl.status == AudioStatus.downloading) ...[
                        SizedBox.square(
                          dimension: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: dl.progress == 0 ? null : dl.progress,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          [
                            if (track.artist.isNotEmpty) track.artist,
                            if (track.durationSeconds > 0) formatClock(track.durationSeconds),
                          ].join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(color: context.softText),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            trailing ??
                IconButton(
                  tooltip: mine.isFavorite(track.id) ? s.removeFavorite : s.addFavorite,
                  onPressed: () => mine.toggleFavorite(track.id),
                  icon: Icon(
                    mine.isFavorite(track.id) ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: mine.isFavorite(track.id) ? const Color(0xFFD9695F) : context.softText,
                  ),
                ),
            TrackMenuButton(track: track, playlistId: playlistId),
          ],
        ),
      ),
    );
  }
}

/// Shows a friendly message if playback couldn't start.
void _reportError(BuildContext context, MusicPlayer player) {
  final s = context.s;
  final msg = switch (player.error) {
    MusicError.offline => s.musicOffline,
    MusicError.notConfigured => s.musicNotAvailable,
    MusicError.playback => s.musicPlaybackError,
    null => player.skippedOffline > 0 ? s.musicSkipped(player.skippedOffline) : null,
  };
  if (msg != null) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}

void reportMusicError(BuildContext context) => _reportError(context, context.read<MusicPlayer>());

/// "⋮" menu: add to playlist, download / remove download, remove from playlist.
class TrackMenuButton extends StatelessWidget {
  const TrackMenuButton({super.key, required this.track, this.playlistId});

  final MusicTrack track;
  final String? playlistId;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final downloads = context.watch<MusicDownloads>();
    final st = downloads.stateOf(track.id).status;
    return PopupMenuButton<String>(
      tooltip: s.moreOptions,
      icon: Icon(Icons.more_vert_rounded, color: context.softText),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      onSelected: (v) async {
        switch (v) {
          case 'playlist':
            await showAddToPlaylist(context, track);
          case 'download':
            await downloads.download(track);
            if (context.mounted) _reportDownload(context, downloads, track);
          case 'cancel':
            await downloads.cancel(track.id);
          case 'delete':
            await downloads.delete(track.id);
          case 'remove':
            await context.read<MyMusicStore>().removeFromPlaylist(playlistId!, track.id);
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(value: 'playlist', child: _MenuRow(Icons.playlist_add_rounded, s.addToPlaylist)),
        if (st == AudioStatus.downloaded)
          PopupMenuItem(value: 'delete', child: _MenuRow(Icons.delete_outline_rounded, s.deleteDownload))
        else if (st == AudioStatus.downloading)
          PopupMenuItem(value: 'cancel', child: _MenuRow(Icons.close_rounded, s.cancel))
        else
          PopupMenuItem(value: 'download', child: _MenuRow(Icons.download_rounded, s.downloadForOffline)),
        if (playlistId != null)
          PopupMenuItem(value: 'remove', child: _MenuRow(Icons.playlist_remove_rounded, s.removeFromPlaylist)),
      ],
    );
  }
}

void _reportDownload(BuildContext context, MusicDownloads downloads, MusicTrack track) {
  final st = downloads.stateOf(track.id);
  final s = context.s;
  if (st.status == AudioStatus.failed) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.audioError(st.error)),
        action: SnackBarAction(label: s.retry, onPressed: () => downloads.download(track)),
      ),
    );
  } else if (st.status == AudioStatus.downloaded) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(s.downloadedForOffline)));
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(children: [Icon(icon, size: 20), const SizedBox(width: 12), Text(label)]);
}

/// Download control showing progress, done state, retry and delete.
class MusicDownloadButton extends StatelessWidget {
  const MusicDownloadButton({super.key, required this.track, this.color});

  final MusicTrack track;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final downloads = context.watch<MusicDownloads>();
    final st = downloads.stateOf(track.id);
    final c = color ?? Theme.of(context).colorScheme.onSurface;
    switch (st.status) {
      case AudioStatus.downloading:
        return IconButton(
          tooltip: s.cancel,
          onPressed: () => downloads.cancel(track.id),
          icon: SizedBox.square(
            dimension: 24,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 2.5,
                  value: st.progress == 0 ? null : st.progress,
                  color: c,
                  backgroundColor: c.withValues(alpha: 0.2),
                ),
                Icon(Icons.close_rounded, size: 12, color: c),
              ],
            ),
          ),
        );
      case AudioStatus.downloaded:
        return IconButton(
          tooltip: s.deleteDownload,
          onPressed: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (d) => AlertDialog(
                title: Text(s.deleteDownloadTitle),
                content: Text(s.deleteDownloadBody),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(d, false), child: Text(s.cancel)),
                  FilledButton(onPressed: () => Navigator.pop(d, true), child: Text(s.delete)),
                ],
              ),
            );
            if (ok == true) await downloads.delete(track.id);
          },
          icon: Icon(Icons.download_done_rounded, color: c),
        );
      case AudioStatus.failed:
        return IconButton(
          tooltip: s.retry,
          onPressed: () async {
            await downloads.download(track);
            if (context.mounted) _reportDownload(context, downloads, track);
          },
          icon: Icon(Icons.sync_problem_rounded, color: Theme.of(context).colorScheme.error),
        );
      case AudioStatus.notDownloaded:
        return IconButton(
          tooltip: s.downloadForOffline,
          onPressed: () async {
            await downloads.download(track);
            if (context.mounted) _reportDownload(context, downloads, track);
          },
          icon: Icon(Icons.download_rounded, color: c),
        );
    }
  }
}

/// Bottom sheet to add a track to an existing or new playlist.
Future<void> showAddToPlaylist(BuildContext context, MusicTrack track) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheet) {
      final s = sheet.s;
      return Consumer<MyMusicStore>(
        builder: (sheet, mine, _) {
          return SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(sheet).height * 0.7),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(s.addToPlaylist, style: Theme.of(sheet).textTheme.titleLarge),
                  ),
                  ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.add_rounded)),
                    title: Text(s.newPlaylist),
                    onTap: () async {
                      final name = await promptPlaylistName(sheet);
                      if (name == null) return;
                      await mine.createPlaylist(name, trackIds: [track.id]);
                      if (sheet.mounted) {
                        Navigator.pop(sheet);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.addedToPlaylist(name))));
                      }
                    },
                  ),
                  for (final p in mine.playlists)
                    ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.queue_music_rounded)),
                      title: Text(p.name),
                      subtitle: Text(s.tracksCount(p.trackIds.length)),
                      trailing: p.trackIds.contains(track.id)
                          ? Icon(Icons.check_circle_rounded, color: accentOf(sheet))
                          : null,
                      onTap: () async {
                        final added = await mine.addToPlaylist(p.id, track.id);
                        if (sheet.mounted) Navigator.pop(sheet);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(added ? s.addedToPlaylist(p.name) : s.alreadyInPlaylist)),
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<String?> promptPlaylistName(BuildContext context, {String initial = ''}) {
  final controller = TextEditingController(text: initial);
  final s = context.s;
  return showDialog<String>(
    context: context,
    builder: (d) => AlertDialog(
      title: Text(initial.isEmpty ? s.newPlaylist : s.renamePlaylist),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLength: 40,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(hintText: s.playlistNameHint),
        onSubmitted: (v) => Navigator.pop(d, v.trim().isEmpty ? null : v.trim()),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(d), child: Text(s.cancel)),
        FilledButton(
          onPressed: () => Navigator.pop(d, controller.text.trim().isEmpty ? null : controller.text.trim()),
          child: Text(s.save),
        ),
      ],
    ),
  );
}

/// Small persistent player shown above the bottom navigation.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<MusicPlayer>();
    final t = player.current;
    final s = context.s;
    final theme = Theme.of(context);
    final dark = context.isDark;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (c, a) => SizeTransition(
        sizeFactor: a,
        child: FadeTransition(opacity: a, child: c),
      ),
      child: t == null
          ? const SizedBox.shrink(key: ValueKey('none'))
          : Padding(
              key: const ValueKey('mini'),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Material(
                color: dark ? AppColors.nightCard : Colors.white,
                elevation: 0,
                borderRadius: BorderRadius.circular(22),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => openMusicPlayer?.call(context),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: dark ? AppColors.nightLine : AppColors.mint),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 4, 6),
                          child: Row(
                            children: [
                              Hero(tag: 'music-cover', child: CoverArt.track(t, size: 44, radius: 12)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.titleFor(context.lang),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleSmall,
                                    ),
                                    Text(
                                      t.artist.isEmpty
                                          ? (musicCategoryById(t.categoryId)?.name.get(context.lang) ?? '')
                                          : t.artist,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall?.copyWith(color: context.softText),
                                    ),
                                  ],
                                ),
                              ),
                              if (player.loading)
                                const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox.square(
                                    dimension: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2.5),
                                  ),
                                )
                              else
                                IconButton(
                                  tooltip: player.isPlaying ? s.pause : s.play,
                                  onPressed: () async {
                                    await player.togglePlay();
                                    if (context.mounted) reportMusicError(context);
                                  },
                                  icon: Icon(
                                    player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    size: 30,
                                  ),
                                ),
                              IconButton(
                                tooltip: s.close,
                                onPressed: player.close,
                                icon: Icon(Icons.close_rounded, color: context.softText),
                              ),
                            ],
                          ),
                        ),
                        if (player.isLoaded)
                          StreamBuilder<Duration>(
                            stream: player.player.positionStream,
                            builder: (context, snap) {
                              final total = player.player.duration?.inMilliseconds ?? 0;
                              final pos = snap.data?.inMilliseconds ?? 0;
                              return LinearProgressIndicator(
                                value: total == 0 ? 0 : (pos / total).clamp(0.0, 1.0),
                                minHeight: 2.5,
                                color: accentOf(context),
                                backgroundColor: Colors.transparent,
                              );
                            },
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
