import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/strings.dart';
import '../../models/music.dart';
import '../../services/music_downloads.dart';
import '../../services/music_library.dart';
import '../../services/music_player.dart';
import '../../services/my_music_store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common.dart';
import '../../widgets/music/cover_art.dart';
import '../../widgets/music/music_widgets.dart';
import '../settings_screen.dart' show formatBytes;
import 'music_nav.dart';

/// My Music: Recently played, Favorites, Downloaded and Playlists.
class MyMusicScreen extends StatelessWidget {
  const MyMusicScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return DefaultTabController(
      length: 4,
      initialIndex: initialTab.clamp(0, 3),
      child: Scaffold(
        bottomNavigationBar: const SafeArea(child: MiniPlayer()),
        appBar: AppBar(
          title: Text(s.myMusic),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: s.recentlyPlayed),
              Tab(text: s.favorites),
              Tab(text: s.downloadedShort),
              Tab(text: s.playlists),
            ],
          ),
        ),
        body: const TabBarView(children: [_RecentTab(), _FavoritesTab(), _DownloadsTab(), _PlaylistsTab()]),
      ),
    );
  }
}

class _TrackList extends StatelessWidget {
  const _TrackList({required this.tracks, required this.empty, this.header});

  final List<MusicTrack> tracks;
  final _Empty empty;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) return empty;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        ?header,
        _PlayRow(tracks: tracks),
        const SizedBox(height: 8),
        for (final t in tracks) TrackTile(track: t, queue: tracks),
      ],
    );
  }
}

class _PlayRow extends StatelessWidget {
  const _PlayRow({required this.tracks});

  final List<MusicTrack> tracks;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final player = context.read<MusicPlayer>();
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () async {
              await player.playQueue(tracks);
              if (context.mounted) reportMusicError(context);
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(s.playAll),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              await player.shufflePlay(tracks);
              if (context.mounted) reportMusicError(context);
            },
            icon: const Icon(Icons.shuffle_rounded),
            label: Text(s.shuffle),
          ),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconBadge(icon, color: AppColors.mint, size: 72),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.softText),
            ),
            if (action != null) ...[const SizedBox(height: 18), action!],
          ],
        ),
      ),
    );
  }
}

class _RecentTab extends StatelessWidget {
  const _RecentTab();

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final mine = context.watch<MyMusicStore>();
    final tracks = context.watch<MusicLibrary>().byIds(mine.recentIds);
    return _TrackList(
      tracks: tracks,
      empty: _Empty(icon: Icons.history_rounded, text: s.noRecentMusic),
      header: Align(
        alignment: Alignment.centerRight,
        child: TextButton(onPressed: mine.clearRecent, child: Text(s.clearHistory)),
      ),
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab();

  @override
  Widget build(BuildContext context) {
    final mine = context.watch<MyMusicStore>();
    final tracks = context.watch<MusicLibrary>().byIds(mine.favoriteIds);
    return _TrackList(
      tracks: tracks,
      empty: _Empty(icon: Icons.favorite_border_rounded, text: context.s.noFavoriteMusic),
    );
  }
}

class _DownloadsTab extends StatelessWidget {
  const _DownloadsTab();

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final downloads = context.watch<MusicDownloads>();
    final tracks = context.watch<MusicLibrary>().byIds(downloads.downloadedIds);
    return _TrackList(
      tracks: tracks,
      empty: _Empty(icon: Icons.download_rounded, text: s.noDownloadedMusic),
      header: SoftCard(
        color: pastelOf(context, AppColors.mintDeep),
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        child: Row(
          children: [
            const Icon(Icons.offline_pin_rounded),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                s.offlineStorage(formatBytes(downloads.totalBytes)),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            TextButton(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (d) => AlertDialog(
                    title: Text(s.deleteAllDownloads),
                    content: Text(s.deleteAllMusicDownloadsBody),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(d, false), child: Text(s.cancel)),
                      FilledButton(onPressed: () => Navigator.pop(d, true), child: Text(s.delete)),
                    ],
                  ),
                );
                if (ok == true) await downloads.deleteAll();
              },
              child: Text(s.deleteAll),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistsTab extends StatelessWidget {
  const _PlaylistsTab();

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final mine = context.watch<MyMusicStore>();
    final library = context.watch<MusicLibrary>();
    Future<void> create() async {
      final name = await promptPlaylistName(context);
      if (name != null) await mine.createPlaylist(name);
    }

    if (mine.playlists.isEmpty) {
      return _Empty(
        icon: Icons.queue_music_rounded,
        text: s.noPlaylists,
        action: FilledButton.icon(onPressed: create, icon: const Icon(Icons.add_rounded), label: Text(s.newPlaylist)),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        OutlinedButton.icon(onPressed: create, icon: const Icon(Icons.add_rounded), label: Text(s.newPlaylist)),
        const SizedBox(height: 12),
        for (final p in mine.playlists)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SoftCard(
              padding: const EdgeInsets.all(10),
              onTap: () => openPlaylist(context, p),
              child: Row(
                children: [
                  PlaylistCover(tracks: library.byIds(p.trackIds), size: 60),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name, style: Theme.of(context).textTheme.titleSmall),
                        Text(
                          s.tracksCount(p.trackIds.length),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.softText),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: context.softText),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// 2×2 mosaic of a playlist's first covers.
class PlaylistCover extends StatelessWidget {
  const PlaylistCover({super.key, required this.tracks, required this.size});

  final List<MusicTrack> tracks;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: pastelOf(context, AppColors.lavender),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.queue_music_rounded, size: size * 0.4),
      );
    }
    if (tracks.length < 4) return CoverArt.track(tracks.first, size: size, radius: 16);
    final h = size / 2;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox.square(
        dimension: size,
        child: Wrap(children: [for (final t in tracks.take(4)) CoverArt.track(t, size: h, radius: 0)]),
      ),
    );
  }
}
