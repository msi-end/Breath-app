import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l_text.dart';
import '../../l10n/strings.dart';
import '../../models/music.dart';
import '../../services/music_library.dart';
import '../../services/music_player.dart';
import '../../theme/app_colors.dart';
import '../../widgets/music/cover_art.dart';
import '../../widgets/music/music_widgets.dart';
import 'music_nav.dart';

class MusicCategoryScreen extends StatefulWidget {
  const MusicCategoryScreen({super.key, required this.category});

  final MusicCategory category;

  @override
  State<MusicCategoryScreen> createState() => _MusicCategoryScreenState();
}

class _MusicCategoryScreenState extends State<MusicCategoryScreen> {
  MusicSort _sort = MusicSort.featured;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final c = widget.category;
    final theme = Theme.of(context);
    final library = context.watch<MusicLibrary>();
    final tracks = MusicLibrary.sorted(library.inCategory(c.id), _sort, lang: context.lang);
    final total = tracks.fold(0, (a, t) => a + t.durationSeconds);
    final player = context.read<MusicPlayer>();

    return Scaffold(
      bottomNavigationBar: const SafeArea(child: MiniPlayer()),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 250,
            foregroundColor: Colors.white,
            backgroundColor: Color.lerp(c.colors.last, AppColors.forest, 0.4),
            actions: [
              IconButton(
                tooltip: s.searchMusic,
                onPressed: () => openMusicSearch(context, categoryId: c.id),
                icon: const Icon(Icons.search_rounded),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(start: 56, bottom: 16, end: 56),
              title: Text(
                c.name.get(context.lang),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CoverArt.category(c, size: double.infinity, radius: 0),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withValues(alpha: 0.15), Colors.black.withValues(alpha: 0.55)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            sliver: SliverList.list(
              children: [
                Text(c.description.get(context.lang), style: theme.textTheme.bodyLarge),
                const SizedBox(height: 6),
                Text(
                  '${s.tracksCount(tracks.length)} · ${s.durationText(total)}',
                  style: theme.textTheme.labelLarge?.copyWith(color: context.softText),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: tracks.isEmpty
                            ? null
                            : () async {
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
                        onPressed: tracks.isEmpty
                            ? null
                            : () async {
                                await player.shufflePlay(tracks);
                                if (context.mounted) reportMusicError(context);
                              },
                        icon: const Icon(Icons.shuffle_rounded),
                        label: Text(s.shuffle),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: SortButton(value: _sort, onChanged: (v) => setState(() => _sort = v)),
                ),
                if (tracks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(s.emptyCategory, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                  )
                else
                  for (final t in tracks) TrackTile(track: t, queue: tracks),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SortButton extends StatelessWidget {
  const SortButton({super.key, required this.value, required this.onChanged});

  final MusicSort value;
  final ValueChanged<MusicSort> onChanged;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return PopupMenuButton<MusicSort>(
      tooltip: s.sortBy,
      initialValue: value,
      onSelected: onChanged,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      itemBuilder: (_) => [for (final o in MusicSort.values) PopupMenuItem(value: o, child: Text(s.sortLabel(o)))],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sort_rounded, size: 20),
            const SizedBox(width: 6),
            Text(s.sortLabel(value), style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}
