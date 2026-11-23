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

    return NatureBackground(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greeting, style: theme.textTheme.titleMedium?.copyWith(color: context.softText)),
                      const SizedBox(height: 2),
                      Text(s.welcomeTitle, style: theme.textTheme.headlineMedium),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: s.favorites,
                  onPressed: () => openFavorites(context),
                  icon: const Icon(Icons.favorite_border_rounded),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(s.welcomeSubtitle, style: theme.textTheme.bodyMedium?.copyWith(color: context.softText)),
            const SizedBox(height: 20),
            _TodayCard(store: store),
            const SizedBox(height: 14),
            const _EmergencyCalmButton(),
            SectionHeader(s.explore),
            const _QuickActions(),
            SectionHeader(s.dailyChallenge, action: s.viewAll, onAction: () => openChallenges(context)),
            _ChallengePreview(store: store),
            SectionHeader(s.recentlyPracticed),
            _RecentList(store: store),
            SectionHeader(s.thisWeek, action: s.viewProgress, onAction: onOpenProgress),
            _WeeklySummary(store: store, onTap: onOpenProgress),
            const BannerAdSlot(padding: EdgeInsets.only(top: 20)),
          ],
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.store});

  final ProgressStore store;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final t = todaysTechnique();
    final todaySeconds = store.secondsOn(today());
    final fraction = (todaySeconds / dailyGoalSeconds).clamp(0.0, 1.0);
    final theme = Theme.of(context);
    const onCard = AppColors.cream;
    return SoftCard(
      padding: const EdgeInsets.all(20),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.forest, AppColors.forestSoft, AppColors.sageDark],
      ),
      onTap: () => openTechnique(context, t),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.todaysBreathing.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: onCard.withValues(alpha: 0.75),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(context.l(t.name), style: theme.textTheme.headlineSmall?.copyWith(color: onCard)),
                    const SizedBox(height: 4),
                    Text(
                      context.l(t.tagline),
                      style: theme.textTheme.bodyMedium?.copyWith(color: onCard.withValues(alpha: 0.85)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: fraction,
                        strokeWidth: 6,
                        strokeCap: StrokeCap.round,
                        backgroundColor: onCard.withValues(alpha: 0.18),
                        color: AppColors.mint,
                      ),
                    ),
                    Text(
                      '${(todaySeconds / 60).floor()}/${dailyGoalSeconds ~/ 60}',
                      style: theme.textTheme.labelLarge?.copyWith(color: onCard, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            todaySeconds == 0 ? s.noPracticeToday : s.practicedToday(s.durationText(todaySeconds)),
            style: theme.textTheme.bodySmall?.copyWith(color: onCard.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: AppColors.cream, foregroundColor: AppColors.forest),
              onPressed: () => startSession(context, t),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(s.startBreathing),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyCalmButton extends StatelessWidget {
  const _EmergencyCalmButton();

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final dark = context.isDark;
    return Semantics(
      button: true,
      label: s.emergencyCalm,
      child: SoftCard(
        color: dark ? const Color(0xFF2B2A33) : const Color(0xFFFCE9E1),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        onTap: () => openEmergencyCalm(context),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: dark ? AppColors.blush.withValues(alpha: 0.25) : AppColors.blush,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.favorite_rounded, color: dark ? AppColors.blush : const Color(0xFF9C4A3C)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.emergencyCalm, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(s.emergencyCalmSubtitle, style: theme.textTheme.bodySmall?.copyWith(color: context.softText)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final items = [
      (Icons.spa_outlined, s.exploreTechniques, s.exploreTechniquesSub, AppColors.mint, () => openTechniques(context)),
      (Icons.mood_rounded, s.moodBreathing, s.moodBreathingSub, AppColors.sky, () => showMoodPicker(context)),
      (
        Icons.emoji_events_outlined,
        s.dailyChallenge,
        s.dailyChallengeSub,
        AppColors.sun,
        () => openChallenges(context),
      ),
      (Icons.favorite_border_rounded, s.favorites, s.favoritesSub, AppColors.blush, () => openFavorites(context)),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        final w = (c.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final (icon, title, sub, color, onTap) in items)
              SizedBox(
                width: w,
                child: SoftCard(
                  onTap: onTap,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconBadge(icon, color: color, size: 42),
                      const SizedBox(height: 12),
                      Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.softText),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ChallengePreview extends StatelessWidget {
  const _ChallengePreview({required this.store});

  final ProgressStore store;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final p = ChallengeService.todayProgress(store.sessions);
    final streak = ChallengeService.streak(store.sessions);
    final theme = Theme.of(context);
    return SoftCard(
      onTap: () => openChallenges(context),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: p.fraction,
                    strokeWidth: 5,
                    strokeCap: StrokeCap.round,
                    backgroundColor: AppColors.sun.withValues(alpha: 0.3),
                    color: p.done ? AppColors.sageDark : const Color(0xFFE0A84F),
                  ),
                ),
                Icon(p.done ? Icons.check_rounded : p.def.icon, size: 24),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l(p.def.title), style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(context.l(p.def.description), style: theme.textTheme.bodySmall?.copyWith(color: context.softText)),
                const SizedBox(height: 6),
                Text(
                  p.done ? s.challengeCompleted : s.challengeStreak(streak),
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentList extends StatelessWidget {
  const _RecentList({required this.store});

  final ProgressStore store;

  @override
  Widget build(BuildContext context) {
    final ids = store.recentTechniqueIds();
    final theme = Theme.of(context);
    if (ids.isEmpty) {
      return SoftCard(
        child: Row(
          children: [
            const IconBadge(Icons.history_rounded, color: AppColors.mint, size: 42),
            const SizedBox(width: 14),
            Expanded(
              child: Text(context.s.noRecent, style: theme.textTheme.bodyMedium?.copyWith(color: context.softText)),
            ),
          ],
        ),
      );
    }
    return SizedBox(
      height: 138,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: ids.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final t = techniqueById(ids[i])!;
          return SizedBox(
            width: 150,
            child: SoftCard(
              padding: const EdgeInsets.all(14),
              onTap: () => openTechnique(context, t),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconBadge(t.icon, color: t.color, size: 40),
                  const Spacer(),
                  Text(
                    context.l(t.name),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.s.minutesCount(t.recommendedMinutes),
                    style: theme.textTheme.labelSmall?.copyWith(color: context.softText),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WeeklySummary extends StatelessWidget {
  const _WeeklySummary({required this.store, required this.onTap});

  final ProgressStore store;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final week = store.secondsForLastDays(7);
    final total = week.fold(0, (a, b) => a + b);
    final activeDays = week.where((v) => v > 0).length;
    final theme = Theme.of(context);
    return SoftCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _MiniStat(value: s.durationText(total), label: s.minutesThisWeek),
              ),
              Expanded(
                child: _MiniStat(value: '$activeDays/7', label: s.activeDays),
              ),
              Expanded(
                child: _MiniStat(value: '${store.currentStreak}', label: s.dayStreak),
              ),
            ],
          ),
          const SizedBox(height: 16),
          MiniBarChart(values: week, labels: lastDayLabels(context, 7), height: 70),
          if (total == 0) ...[
            const SizedBox(height: 8),
            Text(s.weekEmpty, style: theme.textTheme.bodySmall?.copyWith(color: context.softText)),
          ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: theme.textTheme.titleLarge),
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: context.softText)),
      ],
    );
  }
}
