import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/techniques.dart';
import '../l10n/l_text.dart';
import '../l10n/strings.dart';
import '../services/challenge_service.dart';
import '../services/date_utils.dart';
import '../services/progress_store.dart';
import '../services/usage_tracker.dart';
import '../theme/app_colors.dart';
import '../widgets/banner_ad_slot.dart';
import '../widgets/common.dart';
import '../widgets/nature_background.dart';
import 'navigation.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _showAllHistory = false;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final store = context.watch<ProgressStore>();
    final since = context.read<UsageTracker>().firstOpen;
    final theme = Theme.of(context);
    final week = store.secondsForLastDays(7);
    final month = store.secondsForLastDays(28);
    final weekTotal = week.fold(0, (a, b) => a + b);
    final monthTotal = month.fold(0, (a, b) => a + b);
    final todaySessions = store.sessionsOn(today());
    final (chDone, chTotal) = ChallengeService.completionRate(store.sessions, since);
    final counts = store.techniqueCounts();
    final history = store.sessions.reversed.toList();
    final shownHistory = _showAllHistory ? history : history.take(8).toList();

    return NatureBackground(
      showHills: false,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text(s.yourProgress, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(s.progressSubtitle, style: theme.textTheme.bodyMedium?.copyWith(color: context.softText)),
            const SizedBox(height: 20),
            StatGrid(
              children: [
                StatTile(
                  icon: Icons.self_improvement,
                  value: '${store.totalSessions}',
                  label: s.totalSessions,
                  color: AppColors.mint,
                ),
                StatTile(
                  icon: Icons.timer_outlined,
                  value: '${store.totalMinutes}',
                  label: s.totalMinutes,
                  color: AppColors.sky,
                ),
                StatTile(
                  icon: Icons.local_fire_department_outlined,
                  value: '${store.currentStreak}',
                  label: s.currentStreak,
                  color: AppColors.sun,
                ),
                StatTile(
                  icon: Icons.workspace_premium_outlined,
                  value: '${store.longestStreak}',
                  label: s.longestStreak,
                  color: AppColors.lavender,
                ),
              ],
            ),
            SectionHeader(s.todaysActivity),
            SoftCard(
              child: Row(
                children: [
                  const IconBadge(Icons.wb_sunny_outlined, color: AppColors.sun),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.durationText(store.secondsOn(today())), style: theme.textTheme.titleLarge),
                        Text(
                          s.sessionsCount(todaySessions.length),
                          style: theme.textTheme.bodySmall?.copyWith(color: context.softText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SectionHeader(s.weeklyActivity),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.minutesThisWeekValue(s.durationText(weekTotal)), style: theme.textTheme.titleMedium),
                  const SizedBox(height: 16),
                  MiniBarChart(values: week, labels: lastDayLabels(context, 7), height: 110),
                ],
              ),
            ),
            SectionHeader(s.monthlyActivity),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.last28Days(s.durationText(monthTotal), month.where((v) => v > 0).length),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 14),
                  _MonthGrid(values: month),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(s.less, style: theme.textTheme.labelSmall),
                      const SizedBox(width: 6),
                      for (final lvl in [0, 1, 2, 3])
                        Container(
                          width: 14,
                          height: 14,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: _MonthGrid.colorFor(context, lvl),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      const SizedBox(width: 2),
                      Text(s.more, style: theme.textTheme.labelSmall),
                    ],
                  ),
                ],
              ),
            ),
            SectionHeader(s.dailyChallenge, action: s.viewAll, onAction: () => openChallenges(context)),
            SoftCard(
              onTap: () => openChallenges(context),
              child: Row(
                children: [
                  SizedBox(
                    width: 58,
                    height: 58,
                    child: CircularProgressIndicator(
                      value: chTotal == 0 ? 0 : chDone / chTotal,
                      strokeWidth: 6,
                      strokeCap: StrokeCap.round,
                      backgroundColor: AppColors.sun.withValues(alpha: 0.3),
                      color: const Color(0xFFE0A84F),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.challengesCompleted(chDone, chTotal), style: theme.textTheme.titleMedium),
                        Text(
                          s.challengeStreak(ChallengeService.streak(store.sessions)),
                          style: theme.textTheme.bodySmall?.copyWith(color: context.softText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SectionHeader(s.mostPracticed),
            SoftCard(
              child: counts.isEmpty
                  ? Text(s.noSessionsYet, style: theme.textTheme.bodyMedium?.copyWith(color: context.softText))
                  : Column(
                      children: [
                        for (final e in counts.take(5))
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: _CountBar(techniqueId: e.key, count: e.value, max: counts.first.value),
                          ),
                      ],
                    ),
            ),
            SectionHeader(s.sessionHistory),
            SoftCard(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: history.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        s.noSessionsYet,
                        style: theme.textTheme.bodyMedium?.copyWith(color: context.softText),
                      ),
                    )
                  : Column(
                      children: [
                        for (final r in shownHistory)
                          Builder(
                            builder: (context) {
                              final t = techniqueById(r.techniqueId);
                              final loc = MaterialLocalizations.of(context);
                              return ListTile(
                                leading: IconBadge(
                                  t?.icon ?? Icons.spa_outlined,
                                  color: t?.color ?? AppColors.mint,
                                  size: 40,
                                ),
                                title: Text(t == null ? r.techniqueId : context.l(t.name)),
                                subtitle: Text(
                                  '${loc.formatMediumDate(r.startedAt)} · ${loc.formatTimeOfDay(TimeOfDay.fromDateTime(r.startedAt))}',
                                ),
                                trailing: Text(s.durationText(r.durationSeconds), style: theme.textTheme.labelLarge),
                              );
                            },
                          ),
                        if (history.length > 8)
                          TextButton(
                            onPressed: () => setState(() => _showAllHistory = !_showAllHistory),
                            child: Text(_showAllHistory ? s.showLess : s.showAll(history.length)),
                          ),
                      ],
                    ),
            ),
            const BannerAdSlot(padding: EdgeInsets.only(top: 20)),
          ],
        ),
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.values});

  final List<int> values;

  static Color colorFor(BuildContext context, int level) {
    final dark = context.isDark;
    final base = dark ? AppColors.mintDeep : AppColors.sageDark;
    switch (level) {
      case 0:
        return base.withValues(alpha: 0.12);
      case 1:
        return base.withValues(alpha: 0.35);
      case 2:
        return base.withValues(alpha: 0.65);
      default:
        return base;
    }
  }

  static int levelFor(int seconds) {
    if (seconds <= 0) return 0;
    if (seconds < 180) return 1;
    if (seconds < 600) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    final labels = lastDayLabels(context, 7);
    return Column(
      children: [
        Row(
          children: [
            for (final l in labels)
              Expanded(
                child: Center(child: Text(l, style: Theme.of(context).textTheme.labelSmall)),
              ),
          ],
        ),
        const SizedBox(height: 6),
        for (var row = 0; row < values.length ~/ 7; row++)
          Row(
            children: [
              for (var col = 0; col < 7; col++)
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Tooltip(
                      message: context.s.durationText(values[row * 7 + col]),
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: colorFor(context, levelFor(values[row * 7 + col])),
                          borderRadius: BorderRadius.circular(8),
                          border: row * 7 + col == values.length - 1
                              ? Border.all(color: Theme.of(context).colorScheme.primary, width: 1.5)
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _CountBar extends StatelessWidget {
  const _CountBar({required this.techniqueId, required this.count, required this.max});

  final String techniqueId;
  final int count;
  final int max;

  @override
  Widget build(BuildContext context) {
    final t = techniqueById(techniqueId)!;
    final theme = Theme.of(context);
    return Row(
      children: [
        IconBadge(t.icon, color: t.color, size: 36),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(context.l(t.name), style: theme.textTheme.titleSmall)),
                  Text(context.s.sessionsCount(count), style: theme.textTheme.labelMedium),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: max == 0 ? 0 : count / max,
                  minHeight: 8,
                  backgroundColor: t.color.withValues(alpha: 0.2),
                  color: t.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
