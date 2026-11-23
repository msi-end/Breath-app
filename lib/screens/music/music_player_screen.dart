import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart' show ProcessingState;
import 'package:provider/provider.dart';

import '../../data/music_categories.dart';
import '../../l10n/l_text.dart';
import '../../l10n/strings.dart';
import '../../services/date_utils.dart';
import '../../services/music_player.dart';
import '../../services/my_music_store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glow.dart';
import '../../widgets/music/cover_art.dart';
import '../../widgets/music/music_widgets.dart';

/// Full-screen player.
class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  double? _drag;
  bool _showAbout = false;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final player = context.watch<MusicPlayer>();
    final mine = context.watch<MyMusicStore>();
    final t = player.current;
    final theme = Theme.of(context);
    if (t == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).maybePop();
      });
      return const Scaffold();
    }
    final cat = musicCategoryById(t.categoryId) ?? musicCategories.first;
    final fav = mine.isFavorite(t.id);
    const fg = AppColors.cream;
    final accent = AppColors.mint;
    final bgTop = Color.lerp(cat.colors.last, AppColors.forest, 0.55)!;

    return Scaffold(
      backgroundColor: AppColors.night,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred artwork backdrop
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [bgTop, AppColors.night],
              ),
            ),
          ),
          Opacity(
            opacity: 0.35,
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: CoverArt.track(t, size: double.infinity, radius: 0),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppColors.night.withValues(alpha: 0.85)],
                stops: const [0.3, 1],
              ),
            ),
          ),
          SafeArea(
            child: DefaultTextStyle.merge(
              style: const TextStyle(color: fg),
              child: IconTheme.merge(
                data: const IconThemeData(color: fg),
                child: LayoutBuilder(
                  builder: (context, box) {
                    final coverSize = (box.maxWidth - 64).clamp(160.0, box.maxHeight * 0.42);
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      children: [
                        Row(
                          children: [
                            IconButton(
                              tooltip: s.close,
                              onPressed: () => Navigator.of(context).maybePop(),
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    s.nowPlaying.toUpperCase(),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: fg.withValues(alpha: 0.7),
                                      letterSpacing: 1.4,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    cat.name.get(context.lang),
                                    style: theme.textTheme.titleSmall?.copyWith(color: fg),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: s.addToPlaylist,
                              onPressed: t.isLocalOnly ? null : () => showAddToPlaylist(context, t),
                              icon: const Icon(Icons.playlist_add_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // Cover: gently "breathes" while playing.
                        Center(
                          child: AnimatedScale(
                            scale: player.isPlaying ? 1 : 0.9,
                            duration: const Duration(milliseconds: 450),
                            curve: Curves.easeOutBack,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              child: Container(
                                key: ValueKey(t.id),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.35),
                                      blurRadius: 40,
                                      offset: const Offset(0, 18),
                                    ),
                                  ],
                                ),
                                child: Hero(
                                  tag: 'music-cover',
                                  child: CoverArt.track(t, size: coverSize, radius: 30),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Text(
                                      t.titleFor(context.lang),
                                      key: ValueKey(t.id),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.headlineSmall?.copyWith(color: fg),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    t.artist,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyLarge?.copyWith(color: fg.withValues(alpha: 0.7)),
                                  ),
                                ],
                              ),
                            ),
                            if (!t.isLocalOnly) ...[
                              IconButton(
                                tooltip: fav ? s.removeFavorite : s.addFavorite,
                                onPressed: () => mine.toggleFavorite(t.id),
                                icon: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                                  child: Icon(
                                    fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    key: ValueKey(fav),
                                    color: fav ? const Color(0xFFF08A7E) : fg,
                                    size: 28,
                                  ),
                                ),
                              ),
                              MusicDownloadButton(track: t, color: fg),
                            ],
                          ],
                        ),
                        const SizedBox(height: 14),
                        _SeekBar(
                          player: player,
                          drag: _drag,
                          onDrag: (v) => setState(() => _drag = v),
                          onDragEnd: (v) async {
                            await player.seek(Duration(milliseconds: v.round()));
                            if (mounted) setState(() => _drag = null);
                          },
                          fallbackSeconds: t.durationSeconds,
                        ),
                        const SizedBox(height: 6),
                        // Transport controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              tooltip: player.shuffle ? s.shuffleOff : s.shuffleOn,
                              isSelected: player.shuffle,
                              onPressed: player.toggleShuffle,
                              icon: Icon(
                                Icons.shuffle_rounded,
                                color: player.shuffle ? accent : fg.withValues(alpha: 0.6),
                              ),
                            ),
                            IconButton(
                              tooltip: s.previous,
                              iconSize: 38,
                              onPressed: player.previous,
                              icon: const Icon(Icons.skip_previous_rounded),
                            ),
                            _PlayButton(player: player),
                            IconButton(
                              tooltip: s.next,
                              iconSize: 38,
                              onPressed: player.hasNext ? player.next : null,
                              icon: Icon(
                                Icons.skip_next_rounded,
                                color: player.hasNext ? fg : fg.withValues(alpha: 0.3),
                              ),
                            ),
                            IconButton(
                              tooltip: s.repeatLabel(player.repeat),
                              isSelected: player.repeat != MusicRepeat.off,
                              onPressed: player.cycleRepeat,
                              icon: Icon(
                                player.repeat == MusicRepeat.one ? Icons.repeat_one_rounded : Icons.repeat_rounded,
                                color: player.repeat == MusicRepeat.off ? fg.withValues(alpha: 0.6) : accent,
                              ),
                            ),
                          ],
                        ),
                        if (player.error != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            switch (player.error!) {
                              MusicError.offline => s.musicOffline,
                              MusicError.notConfigured => s.musicNotAvailable,
                              MusicError.playback => s.musicPlaybackError,
                            },
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.blush),
                          ),
                        ],
                        if (t.descriptionFor(context.lang).isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Theme(
                              data: theme.copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                initiallyExpanded: _showAbout,
                                onExpansionChanged: (v) => _showAbout = v,
                                iconColor: fg,
                                collapsedIconColor: fg,
                                shape: const RoundedRectangleBorder(),
                                title: Text(s.aboutTrack, style: theme.textTheme.titleSmall?.copyWith(color: fg)),
                                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.descriptionFor(context.lang),
                                    style: theme.textTheme.bodyMedium?.copyWith(color: fg.withValues(alpha: 0.85)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.player});

  final MusicPlayer player;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final buffering =
        player.loading ||
        (player.isLoaded &&
            (player.player.processingState == ProcessingState.loading ||
                player.player.processingState == ProcessingState.buffering));
    return SizedBox.square(
      dimension: 78,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (player.isPlaying) const GlowOrb(size: 78, color: AppColors.mintDeep, rings: false),
          Material(
            color: AppColors.mint,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () async {
                await player.togglePlay();
                if (context.mounted) reportMusicError(context);
              },
              child: Tooltip(
                message: player.isPlaying ? s.pause : s.play,
                child: SizedBox.square(
                  dimension: 70,
                  child: buffering
                      ? const Padding(
                          padding: EdgeInsets.all(22),
                          child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.forest),
                        )
                      : AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                          child: Icon(
                            player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            key: ValueKey(player.isPlaying),
                            size: 40,
                            color: AppColors.forest,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeekBar extends StatelessWidget {
  const _SeekBar({
    required this.player,
    required this.drag,
    required this.onDrag,
    required this.onDragEnd,
    required this.fallbackSeconds,
  });

  final MusicPlayer player;
  final double? drag;
  final ValueChanged<double> onDrag;
  final ValueChanged<double> onDragEnd;
  final int fallbackSeconds;

  @override
  Widget build(BuildContext context) {
    const fg = AppColors.cream;
    final theme = Theme.of(context);
    if (!player.isLoaded) {
      final pos = player.resumePosition;
      return _bar(context, pos.inMilliseconds.toDouble(), fallbackSeconds * 1000.0, enabled: false);
    }
    return StreamBuilder<Duration?>(
      stream: player.player.durationStream,
      builder: (context, durSnap) {
        final total = (durSnap.data ?? Duration(seconds: fallbackSeconds)).inMilliseconds.toDouble();
        return StreamBuilder<Duration>(
          stream: player.player.positionStream,
          builder: (context, posSnap) {
            final pos = drag ?? (posSnap.data?.inMilliseconds.toDouble() ?? 0);
            return _bar(context, pos, total, enabled: true, theme: theme, fg: fg);
          },
        );
      },
    );
  }

  Widget _bar(
    BuildContext context,
    double pos,
    double total, {
    required bool enabled,
    ThemeData? theme,
    Color fg = AppColors.cream,
  }) {
    final t = theme ?? Theme.of(context);
    final max = total <= 0 ? 1.0 : total;
    final value = pos.clamp(0.0, max);
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: AppColors.mint,
            inactiveTrackColor: fg.withValues(alpha: 0.2),
            thumbColor: Colors.white,
            overlayColor: AppColors.mint.withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(
            value: value,
            max: max,
            onChanged: enabled ? onDrag : null,
            onChangeEnd: enabled ? onDragEnd : null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatClock(value ~/ 1000),
                style: t.textTheme.labelMedium?.copyWith(color: fg.withValues(alpha: 0.75)),
              ),
              Text(
                formatClock(max ~/ 1000),
                style: t.textTheme.labelMedium?.copyWith(color: fg.withValues(alpha: 0.75)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
