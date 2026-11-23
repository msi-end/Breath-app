import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/techniques.dart';
import '../l10n/l_text.dart';
import '../l10n/strings.dart';
import '../models/technique.dart';
import '../services/challenge_service.dart';
import '../services/date_utils.dart';
import '../services/progress_store.dart';
import '../theme/app_colors.dart';
import '../widgets/banner_ad_slot.dart';
import '../widgets/common.dart';
import '../widgets/glow.dart';
import '../widgets/logo.dart';
import '../widgets/mood_picker_sheet.dart';
import '../widgets/nature_background.dart';
import 'navigation.dart';

/// The technique suggested for today. Rotates daily through the collection.
Technique todaysTechnique() {
  final day = today();
  final index = DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
  return allTechniques[(index * 3) % allTechniques.length];
}

const dailyGoalSeconds = 5 * 60;

/// Techniques featured on Home.
const featuredTechniqueIds = ['box', '478', 'belly', 'focus'];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenProgress});

  final VoidCallback onOpenProgress;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final store = context.watch<ProgressStore>();
    final theme = Theme.of(context);
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? s.goodMorning : (hour < 17 ? s.goodAfternoon : s.goodEvening);
    final recent = store.recentTechniqueIds();

    return NatureBackground(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greeting, style: theme.textTheme.titleSmall?.copyWith(color: context.softText)),
                      const SizedBox(height: 2),
                      Text(s.readyToBreathe, style: theme.textTheme.headlineMedium),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: context.cardColor, shape: BoxShape.circle),
                  child: const BreatheCareLogo(size: 32),
                ),
              ],
            ),
            const SizedBox(height: 22),
            FadeSlideIn(child: _TodayCard(store: store)),
            const SizedBox(height: 12),
            const FadeSlideIn(delay: Duration(milliseconds: 60), child: _EmergencyButton()),
            const SizedBox(height: 30),
            _Header(s.breathingTechniques, action: s.seeAll, onAction: () => openTechniques(context)),
            const FadeSlideIn(delay: Duration(milliseconds: 120), child: _TechniqueCarousel()),
            const SizedBox(height: 26),
            FadeSlideIn(
              delay: const Duration(milliseconds: 180),
              child: _QuickGrid(store: store),
            ),
            const SizedBox(height: 30),
            _Header(s.thisWeek, action: s.viewProgress, onAction: onOpenProgress),
            _WeekCard(store: store, onTap: onOpenProgress),
            if (recent.isNotEmpty) ...[
              const SizedBox(height: 30),
              _Header(s.recentlyPracticed),
              _RecentChips(ids: recent),
            ],
            const BannerAdSlot(padding: EdgeInsets.only(top: 24)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.title, {this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Semantics(header: true, child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
          ),
          if (action != null)
            TextButton(
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              onPressed: onAction,
              child: Text(action!),
            ),
        ],
      ),
    );
  }
}

/// Today's suggested practice — the primary action on Home.
class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.store});

  final ProgressStore store;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final t = todaysTechnique();
    final theme = Theme.of(context);
    final todaySeconds = store.secondsOn(today());
    final fraction = (todaySeconds / dailyGoalSeconds).clamp(0.0, 1.0);
    const onCard = AppColors.cream;
    return SoftCard(
      padding: EdgeInsets.zero,
      radius: 30,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3A6B4B), AppColors.forest, Color(0xFF1B3324)],
      ),
      onTap: () => openTechnique(context, t),
      child: Stack(
        children: [
          // Decorative breathing orb, partly off the card edge.
          const Positioned(right: -36, top: -36, child: GlowOrb(size: 170, color: AppColors.mintDeep, rings: true)),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Pill(text: s.todaysBreathing, dark: true),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.only(right: 90),
                  child: Text(
                    context.l(t.name),
                    style: theme.textTheme.headlineSmall?.copyWith(color: onCard, height: 1.15),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.l(t.tagline),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(color: onCard.withValues(alpha: 0.78)),
                ),
                const SizedBox(height: 14),
                Semantics(
                  label: s.practicedToday(s.durationText(todaySeconds)),
                  excludeSemantics: true,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 72,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: fraction,
                            minHeight: 5,
                            color: AppColors.mint,
                            backgroundColor: onCard.withValues(alpha: 0.18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          s.goalToday((todaySeconds / 60).floor(), dailyGoalSeconds ~/ 60),
                          style: theme.textTheme.labelMedium?.copyWith(color: onCard.withValues(alpha: 0.8)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.mint, foregroundColor: AppColors.forest),
                    onPressed: () => startSession(context, t),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(s.startBreathing),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, this.dark = false});

  final String text;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withValues(alpha: 0.12) : AppColors.forest.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: dark ? AppColors.mint : AppColors.forest, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _EmergencyButton extends StatelessWidget {
  const _EmergencyButton();

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final dark = context.isDark;
    return Semantics(
      button: true,
      hint: s.emergencyCalmSubtitle,
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.tonalIcon(
          style: FilledButton.styleFrom(
            backgroundColor: dark ? const Color(0xFF3A2A27) : const Color(0xFFFBE3DA),
            foregroundColor: dark ? AppColors.blush : const Color(0xFF8E3F32),
          ),
          onPressed: () => openEmergencyCalm(context),
          icon: const Icon(Icons.favorite_rounded),
          label: Text(s.emergencyCalm),
        ),
      ),
    );
  }
}

/// Swipeable row of featured techniques.
class _TechniqueCarousel extends StatelessWidget {
  const _TechniqueCarousel();

  @override
  Widget build(BuildContext context) {
    final techniques = featuredTechniqueIds.map((id) => techniqueById(id)!).toList();
    return SizedBox(
      height: 206,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: techniques.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) => TechniqueTile(
          technique: techniques[i],
          width: 160,
          onTap: () => openTechnique(context, techniques[i]),
          onPlay: () => startSession(context, techniques[i]),
        ),
      ),
    );
  }
}

/// 2 × 2 grid: Mood, Explore, Daily Challenge, Favorites.
class _QuickGrid extends StatelessWidget {
  const _QuickGrid({required this.store});

  final ProgressStore store;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final challenge = ChallengeService.todayProgress(store.sessions);
    final favCount = store.favorites.length;
    return StatGrid(
      children: [
        _QuickCard(
          icon: Icons.mood_rounded,
          pastel: AppColors.sky,
          title: s.moodBreathing,
          subtitle: s.moodBreathingSub,
          onTap: () => showMoodPicker(context),
        ),
        _QuickCard(
          icon: Icons.spa_outlined,
          pastel: AppColors.mintDeep,
          title: s.exploreTechniques,
          subtitle: s.exploreTechniquesSub,
          onTap: () => openTechniques(context),
        ),
        _QuickCard(
          icon: challenge.done ? Icons.emoji_events_rounded : challenge.def.icon,
          pastel: AppColors.sun,
          title: s.dailyChallenge,
          subtitle: context.l(challenge.def.title),
          progress: challenge.fraction,
          onTap: () => openChallenges(context),
        ),
        _QuickCard(
          icon: Icons.favorite_border_rounded,
          pastel: AppColors.blush,
          title: s.favorites,
          subtitle: favCount == 0 ? s.favoritesSub : s.savedCount(favCount),
          onTap: () => openFavorites(context),
        ),
      ],
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.pastel,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.progress,
  });

  final IconData icon;
  final Color pastel;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = context.isDark;
    final bg = dark
        ? Color.alphaBlend(pastel.withValues(alpha: 0.14), AppColors.nightCard)
        : Color.alphaBlend(pastel.withValues(alpha: 0.38), Colors.white);
    return SoftCard(
      color: bg,
      radius: 26,
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: dark ? pastel.withValues(alpha: 0.22) : Colors.white.withValues(alpha: 0.75),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 22),
              ),
              const Spacer(),
              if (progress != null)
                SizedBox.square(
                  dimension: 30,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 3.5,
                    strokeCap: StrokeCap.round,
                    backgroundColor: (dark ? Colors.white : AppColors.forest).withValues(alpha: 0.12),
                    color: accentOf(context),
                  ),
                )
              else
                Icon(Icons.arrow_outward_rounded, size: 20, color: context.softText),
            ],
          ),
          const SizedBox(height: 18),
          Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: context.softText, height: 1.3),
          ),
        ],
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.store, required this.onTap});

  final ProgressStore store;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final week = store.secondsForLastDays(7);
    final total = week.fold(0, (a, b) => a + b);
    final active = week.where((v) => v > 0).length;
    final labels = lastDayLabels(context, 7);
    final accent = accentOf(context);
    return SoftCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 7; i++)
                Column(
                  children: [
                    Text(labels[i], style: theme.textTheme.labelSmall?.copyWith(color: context.softText)),
                    const SizedBox(height: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: week[i] > 0
                            ? accent
                            : (context.isDark ? Colors.white : AppColors.forest).withValues(alpha: 0.05),
                        border: i == 6 ? Border.all(color: accent, width: 2) : null,
                      ),
                      child: week[i] > 0
                          ? Icon(Icons.check_rounded, size: 17, color: context.isDark ? AppColors.forest : Colors.white)
                          : null,
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            total == 0 ? s.weekEmpty : s.weekSummary(s.durationText(total), active, store.currentStreak),
            style: theme.textTheme.bodyMedium?.copyWith(color: context.softText),
          ),
        ],
      ),
    );
  }
}

class _RecentChips extends StatelessWidget {
  const _RecentChips({required this.ids});

  final List<String> ids;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final id in ids.take(6))
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Builder(
                builder: (context) {
                  final t = techniqueById(id)!;
                  return ActionChip(
                    avatar: Icon(t.icon, size: 18),
                    label: Text(context.l(t.name)),
                    onPressed: () => openTechnique(context, t),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
