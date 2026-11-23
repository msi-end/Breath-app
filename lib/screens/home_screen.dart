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
    final challenge = ChallengeService.todayProgress(store.sessions);
    final favCount = store.favorites.length;

    return NatureBackground(
      showHills: true,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            // Greeting
            Row(
              children: [
                const BreatheCareLogo(size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greeting, style: theme.textTheme.headlineSmall),
                      Text(s.welcomeSubtitle, style: theme.textTheme.bodyMedium?.copyWith(color: context.softText)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FadeSlideIn(child: _TodayCard(store: store)),
            const SizedBox(height: 12),
            const FadeSlideIn(delay: Duration(milliseconds: 80), child: _EmergencyButton()),
            const SizedBox(height: 28),
            RowGroup(
              children: [
                NavRow(
                  icon: Icons.mood_rounded,
                  iconColor: AppColors.sky,
                  title: s.moodBreathing,
                  subtitle: s.moodBreathingSub,
                  onTap: () => showMoodPicker(context),
                ),
                NavRow(
                  icon: Icons.spa_outlined,
                  title: s.exploreTechniques,
                  subtitle: s.exploreTechniquesSub,
                  onTap: () => openTechniques(context),
                ),
                NavRow(
                  icon: challenge.done ? Icons.check_rounded : challenge.def.icon,
                  iconColor: AppColors.sun,
                  title: s.dailyChallenge,
                  subtitle: context.l(challenge.def.title),
                  trailing: SizedBox.square(
                    dimension: 26,
                    child: CircularProgressIndicator(
                      value: challenge.fraction,
                      strokeWidth: 3,
                      strokeCap: StrokeCap.round,
                      backgroundColor: theme.colorScheme.outlineVariant,
                      color: accentOf(context),
                    ),
                  ),
                  onTap: () => openChallenges(context),
                ),
                NavRow(
                  icon: Icons.favorite_border_rounded,
                  iconColor: AppColors.blush,
                  title: s.favorites,
                  subtitle: favCount == 0 ? s.favoritesSub : s.savedCount(favCount),
                  onTap: () => openFavorites(context),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _Header(s.thisWeek, action: s.viewProgress, onAction: onOpenProgress),
            _WeekCard(store: store, onTap: onOpenProgress),
            if (store.recentTechniqueIds().isNotEmpty) ...[
              const SizedBox(height: 28),
              _Header(s.recentlyPracticed),
              _RecentChips(ids: store.recentTechniqueIds()),
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
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Row(
        children: [
          Expanded(
            child: Semantics(header: true, child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
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

/// Today's suggested practice — the one primary action on Home.
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
    final rhythm = t.pattern.phases.map((p) => '${s.phaseShort(p.type)} ${p.seconds}').join(' · ');
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      radius: 26,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2E5A3F), AppColors.forest],
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
                      s.todaysBreathing,
                      style: theme.textTheme.labelLarge?.copyWith(color: onCard.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 4),
                    Text(context.l(t.name), style: theme.textTheme.headlineSmall?.copyWith(color: onCard)),
                    const SizedBox(height: 4),
                    Text(
                      '${s.minutesCount(t.recommendedMinutes)} · $rhythm',
                      style: theme.textTheme.bodyMedium?.copyWith(color: onCard.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Semantics(
                label: s.practicedToday(s.durationText(todaySeconds)),
                child: SizedBox.square(
                  dimension: 64,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const GlowOrb(size: 64, color: AppColors.mintDeep, rings: false),
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: fraction,
                          strokeWidth: 3,
                          strokeCap: StrokeCap.round,
                          backgroundColor: onCard.withValues(alpha: 0.15),
                          color: AppColors.mint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: week[i] > 0 ? accent : Colors.transparent,
                        border: Border.all(
                          color: week[i] > 0 ? accent : theme.colorScheme.outlineVariant,
                          width: i == 6 ? 2 : 1.2,
                        ),
                      ),
                      child: week[i] > 0
                          ? Icon(Icons.check_rounded, size: 16, color: context.isDark ? AppColors.forest : Colors.white)
                          : null,
                    ),
                    const SizedBox(height: 6),
                    Text(labels[i], style: theme.textTheme.labelSmall?.copyWith(color: context.softText)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 14),
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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final id in ids.take(4))
          Builder(
            builder: (context) {
              final t = techniqueById(id)!;
              return ActionChip(
                avatar: Icon(t.icon, size: 18),
                label: Text(context.l(t.name)),
                onPressed: () => openTechnique(context, t),
              );
            },
          ),
      ],
    );
  }
}
