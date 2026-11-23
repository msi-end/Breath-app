import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/strings.dart';
import '../../services/music_library.dart';
import '../../services/music_player.dart';
import '../../services/my_music_store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/music/music_widgets.dart';
import 'my_music_screen.dart' show PlaylistCover;

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key, required this.playlistId});

  final String playlistId;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final mine = context.watch<MyMusicStore>();
    final p = mine.playlist(playlistId);
    if (p == null) return Scaffold(appBar: AppBar());
    final tracks = context.watch<MusicLibrary>().byIds(p.trackIds);
    final player = context.read<MusicPlayer>();

    return Scaffold(
      bottomNavigationBar: const SafeArea(child: MiniPlayer()),
      appBar: AppBar(
        actions: [
          PopupMenuButton<String>(
            tooltip: s.moreOptions,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            onSelected: (v) async {
              if (v == 'rename') {
                final name = await promptPlaylistName(context, initial: p.name);
                if (name != null) await mine.renamePlaylist(p.id, name);
              } else if (v == 'delete') {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (d) => AlertDialog(
                    title: Text(s.deletePlaylist),
                    content: Text(s.deletePlaylistBody(p.name)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(d, false), child: Text(s.cancel)),
                      FilledButton(onPressed: () => Navigator.pop(d, true), child: Text(s.delete)),
                    ],
                  ),
                );
                if (ok == true && context.mounted) {
                  Navigator.pop(context);
                  await mine.deletePlaylist(p.id);
                }
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'rename', child: Text(s.renamePlaylist)),
              PopupMenuItem(value: 'delete', child: Text(s.deletePlaylist)),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Center(child: PlaylistCover(tracks: tracks, size: 170)),
          const SizedBox(height: 16),
          Text(p.name, textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
          Text(
            s.tracksCount(tracks.length),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: context.softText),
          ),
          const SizedBox(height: 16),
          if (tracks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Text(s.emptyPlaylist, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
            )
          else ...[
            Row(
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
            ),
            const SizedBox(height: 8),
            Text(s.dragToReorder, style: theme.textTheme.labelSmall?.copyWith(color: context.softText)),
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              onReorder: (a, b) => mine.reorderPlaylist(
                p.id,
                p.trackIds.indexOf(tracks[a].id),
                b >= tracks.length ? p.trackIds.length : p.trackIds.indexOf(tracks[b].id),
              ),
              children: [
                for (var i = 0; i < tracks.length; i++)
                  Row(
                    key: ValueKey(tracks[i].id),
                    children: [
                      ReorderableDragStartListener(
                        index: i,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(Icons.drag_indicator_rounded, color: context.softText),
                        ),
                      ),
                      Expanded(
                        child: TrackTile(track: tracks[i], queue: tracks, playlistId: p.id),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
