import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/music_categories.dart';
import '../../l10n/l_text.dart';
import '../../l10n/strings.dart';
import '../../models/music.dart';
import '../../services/music_downloads.dart';
import '../../services/music_library.dart';
import '../../services/music_player.dart';
import '../../services/my_music_store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/banner_ad_slot.dart';
import '../../widgets/common.dart';
import '../../widgets/glow.dart';
import '../../widgets/music/cover_art.dart';
import '../../widgets/music/music_widgets.dart';
import '../../widgets/nature_background.dart';
import 'music_nav.dart';

/// The Music tab.
class MusicScreen extends StatelessWidget {
  const MusicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final library = context.watch<MusicLibrary>();
    final mine = context.watch<MyMusicStore>();
    final downloads = context.watch<MusicDownloads>();
    final recent = library.byIds(mine.recentIds);
    final favorites = library.byIds(mine.favoriteIds);
    final downloaded = library.byIds(downloads.downloadedIds);
    final categories = library.hasTracks ? library.activeCategories : <MusicCategory>[];

    return NatureBackground(
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: library.refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.musicTab, style: theme.textTheme.headlineMedium),
                        const SizedBox(height: 2),
                        Text(s.musicSubtitle, style: theme.textTheme.bodyMedium?.copyWith(color: context.softText)),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: s.myMusic,
                    onPressed: () => openMyMusic(context),
                    icon: const Icon(Icons.library_music_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SearchPill(onTap: () => openMusicSearch(context)),
              const SizedBox(height: 22),
              if (library.status == LibraryStatus.loading && !library.hasTracks)
                const _LoadingPlaceholder()
              else if (!library.hasTracks)
                _EmptyLibrary(status: library.status, onRetry: library.refresh)
              else ...[
                if (library.status == LibraryStatus.offline) ...[_OfflineNote(), const SizedBox(height: 16)],
                _Section(title: s.featuredMusic, tracks: library.featured, large: true),
                _MyMusicShortcuts(
                  favorites: favorites.length,
                  downloads: downloaded.length,
                  playlists: mine.playlists.length,
                ),
                const SizedBox(height: 28),
                _Header(s.musicCategories),
                _CategoryGrid(categories: categories),
                if (recent.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  _Section(
                    title: s.recentlyPlayed,
                    tracks: recent.take(10).toList(),
                    onSeeAll: () => openMyMusic(context, tab: 0),
                  ),
                ],
                if (favorites.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _Section(
                    title: s.favorites,
                    tracks: favorites.take(10).toList(),
                    onSeeAll: () => openMyMusic(context, tab: 1),
                  ),
                ],
                if (downloaded.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _Section(
                    title: s.downloadedMusic,
                    tracks: downloaded.take(10).toList(),
                    onSeeAll: () => openMyMusic(context, tab: 2),
                  ),
                ],
                const BannerAdSlot(padding: EdgeInsets.only(top: 16)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.title, {this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Semantics(header: true, child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
          ),
          if (onSeeAll != null)
            TextButton(
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              onPressed: onSeeAll,
              child: Text(context.s.seeAll),
            ),
        ],
      ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  const _SearchPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.s.searchMusic,
      child: Material(
        color: context.cardColor,
        shape: StadiumBorder(side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: context.softText),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.s.searchMusic,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.softText),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontal row of track cards.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.tracks, this.large = false, this.onSeeAll});

  final String title;
  final List<MusicTrack> tracks;
  final bool large;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) return const SizedBox.shrink();
    final w = large ? 168.0 : 136.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(title, onSeeAll: onSeeAll),
        SizedBox(
          height: w + 58,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: tracks.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, i) => _TrackCard(track: tracks[i], queue: tracks, size: w),
          ),
        ),
        const SizedBox(height: 22),
      ],
    );
  }
}

class _TrackCard extends StatelessWidget {
  const _TrackCard({required this.track, required this.queue, required this.size});

  final MusicTrack track;
  final List<MusicTrack> queue;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final player = context.watch<MusicPlayer>();
    final isCurrent = player.isCurrent(track.id);
    return SizedBox(
      width: size,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () async {
          await player.playTrack(track, context: queue);
          if (context.mounted) reportMusicError(context);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CoverArt.track(track, size: size, radius: 22),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 10)],
                    ),
                    child: Center(
                      child: isCurrent && player.isPlaying
                          ? const NowPlayingBars(playing: true, color: AppColors.forest, size: 16)
                          : const Icon(Icons.play_arrow_rounded, color: AppColors.forest),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              track.titleFor(context.lang),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(color: isCurrent ? accentOf(context) : null),
            ),
            Text(
              track.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: context.softText),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyMusicShortcuts extends StatelessWidget {
  const _MyMusicShortcuts({required this.favorites, required this.downloads, required this.playlists});

  final int favorites;
  final int downloads;
  final int playlists;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    Widget chip(IconData icon, String label, int count, Color color, int tab) => Expanded(
      child: SoftCard(
        color: pastelOf(context, color),
        radius: 20,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        onTap: () => openMyMusic(context, tab: tab),
        child: Column(
          children: [
            Icon(icon, size: 22),
            const SizedBox(height: 6),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelLarge),
            Text('$count', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.softText)),
          ],
        ),
      ),
    );
    return Row(
      children: [
        chip(Icons.favorite_rounded, s.favorites, favorites, AppColors.blush, 1),
        const SizedBox(width: 10),
        chip(Icons.download_done_rounded, s.downloadedShort, downloads, AppColors.mintDeep, 2),
        const SizedBox(width: 10),
        chip(Icons.queue_music_rounded, s.playlists, playlists, AppColors.lavender, 3),
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.categories});

  final List<MusicCategory> categories;

  @override
  Widget build(BuildContext context) {
    final library = context.read<MusicLibrary>();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisExtent: 128,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, i) {
        final c = categories[i];
        final count = library.inCategory(c.id).length;
        return CategoryCard(category: c, count: count, onTap: () => openMusicCategory(context, c));
      },
    );
  }
}

class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.category, required this.count, required this.onTap});

  final MusicCategory category;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: category.name.get(context.lang),
      child: Material(
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CoverArt.category(category, size: double.infinity, radius: 0),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.45)],
                    stops: const [0.35, 1],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      category.name.get(context.lang),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      context.s.tracksCount(count),
                      style: theme.textTheme.labelSmall?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfflineNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: pastelOf(context, AppColors.sky),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded),
          const SizedBox(width: 12),
          Expanded(child: Text(context.s.musicOfflineBanner, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.status, required this.onRetry});

  final LibraryStatus status;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final offline = status == LibraryStatus.offline;
    return Column(
      children: [
        const SizedBox(height: 20),
        GlowOrb(
          size: 150,
          color: AppColors.mintDeep,
          child: Icon(offline ? Icons.cloud_off_rounded : Icons.music_note_rounded, size: 40, color: AppColors.forest),
        ),
        const SizedBox(height: 18),
        Text(
          offline ? s.musicOfflineTitle : s.musicEmptyTitle,
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          offline ? s.musicOfflineBanner : s.musicEmptyBody,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: context.softText),
        ),
        if (offline) ...[
          const SizedBox(height: 18),
          OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: Text(s.retry)),
        ],
        const SizedBox(height: 26),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [for (final c in musicCategories) _CategoryPreviewChip(category: c)],
        ),
      ],
    );
  }
}

class _CategoryPreviewChip extends StatelessWidget {
  const _CategoryPreviewChip({required this.category});

  final MusicCategory category;

  @override
  Widget build(BuildContext context) =>
      Chip(avatar: Icon(category.icon, size: 16), label: Text(category.name.get(context.lang)));
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.6);
    Widget box(double w, double h) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(20)),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        box(160, 22),
        const SizedBox(height: 14),
        Row(children: [box(160, 160), const SizedBox(width: 14), box(160, 160)]),
        const SizedBox(height: 24),
        box(140, 22),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: box(0, 120)),
            const SizedBox(width: 12),
            Expanded(child: box(0, 120)),
          ],
        ),
        const SizedBox(height: 22),
        const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
