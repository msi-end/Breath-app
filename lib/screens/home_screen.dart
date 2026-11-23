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

/// Techniques featured in the "Explore practices" grid, each with its tint.
const _featured = [
  ('box', AppColors.sky),
  ('relax', AppColors.lavender),
  ('equal', AppColors.blush),
  ('focus', AppColors.mintDeep),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenProgress});

  final VoidCallback onOpenProgress;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final store = context.watch<ProgressStore>();
    final theme = Theme.of(context);
    var i = 0;
    Widget enter(Widget child) => FadeSlideIn(
      delay: Duration(milliseconds: 70 * i++),
      child: child,
    );

    return NatureBackground(
      ripples: true,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            // Top bar
            Row(
              children: [
                CircleIconButton(
                  icon: Icons.favorite_border_rounded,
                  tooltip: s.favorites,
                  onPressed: () => openFavorites(context),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const BreatheCareLogo(size: 26),
                      const SizedBox(width: 8),
                      Text('BreatheCare', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                CircleIconButton(icon: Icons.insights_rounded, tooltip: s.progressTooltip, onPressed: onOpenProgress),
              ],
            ),
            const SizedBox(height: 20),
            enter(_HeroCard(store: store)),
            const SizedBox(height: 14),
            enter(const _EmergencyCalmCard()),
            const SizedBox(height: 26),
            enter(
              _SectionTitle(overline: s.findYourRhythm, title: s.explorePractices, subtitle: s.explorePracticesSub),
            ),
            const SizedBox(height: 14),
            enter(const _PracticeGrid()),
            const SizedBox(height: 12),
            enter(
              TintCard(
                tint: AppColors.sage,
                onTap: () => openTechniques(context),
                padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Overline(s.allTechniquesOverline),
                          const SizedBox(height: 4),
                          Text(s.breathingLibrary, style: theme.textTheme.titleLarge),
                        ],
                      ),
                    ),
                    const _ArrowBubble(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 26),
            enter(Overline(s.checkIn)),
            const SizedBox(height: 10),
            enter(const _MoodStrip()),
            const SizedBox(height: 26),
            _SectionTitle(
              overline: s.dailyChallengeSub,
              title: s.dailyChallenge,
              action: s.viewAll,
              onAction: () => openChallenges(context),
            ),
            const SizedBox(height: 14),
            _ChallengePreview(store: store),
            const SizedBox(height: 26),
            _SectionTitle(overline: s.jumpBackIn, title: s.recentlyPracticed),
            const SizedBox(height: 14),
            _RecentList(store: store),
            const SizedBox(height: 26),
            _SectionTitle(overline: s.tabProgress, title: s.thisWeek, action: s.viewProgress, onAction: onOpenProgress),
            const SizedBox(height: 14),
            _WeeklySummary(store: store, onTap: onOpenProgress),
            const BannerAdSlot(padding: EdgeInsets.only(top: 20)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.overline, required this.title, this.subtitle, this.action, this.onAction});

  final String overline;
  final String title;
  final String? subtitle;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Overline(overline),
              const SizedBox(height: 4),
              Semantics(header: true, child: Text(title, style: theme.textTheme.titleLarge)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: theme.textTheme.bodyMedium?.copyWith(color: context.softText)),
              ],
            ],
          ),
        ),
        if (action != null) TextButton(onPressed: onAction, child: Text(action!)),
      ],
    );
  }
}

class _ArrowBubble extends StatelessWidget {
  const _ArrowBubble();

  @override
  Widget build(BuildContext context) {
    final accent = accentOf(context);
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(color: accent.withValues(alpha: 0.18), shape: BoxShape.circle),
      child: Icon(Icons.arrow_forward_rounded, size: 20, color: accent),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.store});

  final ProgressStore store;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final t = todaysTechnique();
    final todaySeconds = store.secondsOn(today());
    final fraction = (todaySeconds / dailyGoalSeconds).clamp(0.0, 1.0);
    final theme = Theme.of(context);
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? s.goodMorning : (hour < 17 ? s.goodAfternoon : s.goodEvening);
    const onCard = AppColors.cream;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2B5A3E), AppColors.forest, Color(0xFF17301F)],
        ),
        border: Border.all(color: AppColors.mintDeep.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(color: AppColors.forest.withValues(alpha: 0.25), blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () => openTechnique(context, t),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Overline(greeting, color: AppColors.mintDeep),
                          const SizedBox(height: 10),
                          Text(
                            s.heroHeadline,
                            style: theme.textTheme.headlineSmall?.copyWith(color: onCard, height: 1.2),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            s.todayPractice(context.l(t.name), t.recommendedMinutes),
                            style: theme.textTheme.bodyMedium?.copyWith(color: onCard.withValues(alpha: 0.85)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Pulsing orb inside today's goal ring
                    SizedBox(
                      width: 96,
                      height: 96,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const GlowOrb(size: 96, color: AppColors.mintDeep, rings: false),
                          SizedBox.square(
                            dimension: 86,
                            child: CircularProgressIndicator(
                              value: fraction,
                              strokeWidth: 3,
                              strokeCap: StrokeCap.round,
                              backgroundColor: onCard.withValues(alpha: 0.15),
                              color: AppColors.mint,
                            ),
                          ),
                          Semantics(
                            label: s.practicedToday(s.durationText(todaySeconds)),
                            child: Text(
                              '${(todaySeconds / 60).floor()}/${dailyGoalSeconds ~/ 60}',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: AppColors.forest,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.mintDeep,
                    foregroundColor: AppColors.forest,
                    minimumSize: const Size(0, 46),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => startSession(context, t),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(s.startBreathing),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmergencyCalmCard extends StatelessWidget {
  const _EmergencyCalmCard();

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final dark = context.isDark;
    return Semantics(
      button: true,
      label: s.emergencyCalm,
      child: TintCard(
        tint: AppColors.blush,
        strength: dark ? 1.2 : 1.1,
        onTap: () => openEmergencyCalm(context),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          children: [
            const GlowOrb(
              size: 54,
              color: AppColors.blush,
              rings: false,
              child: Icon(Icons.favorite_rounded, size: 20, color: Color(0xFF8E3F32)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Overline(s.needCalmNow, color: dark ? AppColors.blush : const Color(0xFF9C4A3C)),
                  const SizedBox(height: 2),
                  Text(s.emergencyCalm, style: theme.textTheme.titleMedium),
                  Text(s.emergencyCalmSubtitle, style: theme.textTheme.bodySmall?.copyWith(color: context.softText)),
                ],
              ),
            ),
            const _ArrowBubble(),
          ],
        ),
      ),
    );
  }
}

class _PracticeGrid extends StatelessWidget {
  const _PracticeGrid();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = context.s;
    final dark = context.isDark;
    final cards = [
      for (final (id, tint) in _featured)
        Builder(
          builder: (context) {
            final t = techniqueById(id)!;
            final tagline = t.tags.take(2).map(s.tagLabel).join(' & ');
            return TintCard(
              tint: tint,
              onTap: () => openTechnique(context, t),
              padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: tint.withValues(alpha: dark ? 0.25 : 0.55),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(t.icon, size: 22),
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_forward_rounded, size: 18, color: context.softText),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    context.l(t.name),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tagline,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: dark ? Color.lerp(tint, Colors.white, 0.2) : Color.lerp(tint, AppColors.forest, 0.6),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
    ];
    return StatGrid(children: cards);
  }
}

class _MoodStrip extends StatelessWidget {
  const _MoodStrip();

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    return TintCard(
      tint: AppColors.sky,
      onTap: () => showMoodPicker(context),
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.sky.withValues(alpha: context.isDark ? 0.25 : 0.6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.mood_rounded),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.moodBreathing, style: theme.textTheme.titleMedium),
                Text(s.moodBreathingSub, style: theme.textTheme.bodySmall?.copyWith(color: context.softText)),
              ],
            ),
          ),
          const _ArrowBubble(),
        ],
      ),
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
    return TintCard(
      tint: AppColors.sun,
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
            child: TintCard(
              tint: t.color,
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
