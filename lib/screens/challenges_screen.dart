import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/challenges.dart';
import '../data/techniques.dart';
import '../l10n/l_text.dart';
import '../l10n/strings.dart';
import '../models/technique.dart';
import '../services/challenge_service.dart';
import '../services/progress_store.dart';
import '../services/usage_tracker.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/nature_background.dart';
import 'home_screen.dart';
import 'navigation.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  /// A technique that will make progress on [def].
  static Technique suggestionFor(ChallengeDef def, ProgressStore store) {
    switch (def.kind) {
      case ChallengeKind.relaxation:
        return techniqueById('relax')!;
      case ChallengeKind.focus:
        return techniqueById('focus')!;
      case ChallengeKind.newTechnique:
        final tried = store.sessions.map((s) => s.techniqueId).toSet();
        return allTechniques.firstWhere((t) => !tried.contains(t.id), orElse: todaysTechnique);
      case ChallengeKind.totalMinutes:
        final t = todaysTechnique();
        return t;
      default:
        return todaysTechnique();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final store = context.watch<ProgressStore>();
    final since = context.read<UsageTracker>().firstOpen;
    final p = ChallengeService.todayProgress(store.sessions);
    final streak = ChallengeService.streak(store.sessions);
    final history = ChallengeService.history(store.sessions, since);
    final (done30, total30) = ChallengeService.completionRate(store.sessions, since);
    final theme = Theme.of(context);
    final suggestion = suggestionFor(p.def, store);

    return Scaffold(
      appBar: AppBar(title: Text(s.dailyChallenges)),
      body: NatureBackground(
        showHills: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            SoftCard(
              padding: const EdgeInsets.all(22),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: context.isDark
                    ? [const Color(0xFF3A3424), AppColors.nightCard]
                    : [const Color(0xFFFFF1D6), const Color(0xFFFDF8EE)],
              ),
              child: Column(
                children: [
                  Text(
                    s.todaysChallenge.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.2, color: context.softText),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: 132,
                    height: 132,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.expand(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: p.fraction),
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.easeOutCubic,
                            builder: (_, v, _) => CircularProgressIndicator(
                              value: v,
                              strokeWidth: 10,
                              strokeCap: StrokeCap.round,
                              backgroundColor: AppColors.sun.withValues(alpha: 0.35),
                              color: p.done ? AppColors.sageDark : const Color(0xFFE0A84F),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(p.done ? Icons.emoji_events_rounded : p.def.icon, size: 34),
                            const SizedBox(height: 4),
                            Text(s.challengeProgressText(p), style: theme.textTheme.labelLarge),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(context.l(p.def.title), style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
                  const SizedBox(height: 6),
                  Text(
                    context.l(p.def.description),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(color: context.softText),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: (p.done ? AppColors.mintDeep : AppColors.sun).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      p.done ? s.challengeCompleted : s.challengeInProgress,
                      style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (!p.done) ...[
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => startSession(
                          context,
                          suggestion,
                          minutes: p.def.kind == ChallengeKind.totalMinutes ? 5 : null,
                        ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(s.startWith(context.l(suggestion.name))),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    icon: Icons.local_fire_department_outlined,
                    value: '$streak',
                    label: s.challengeStreakLabel,
                    color: AppColors.sun,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    icon: Icons.task_alt_rounded,
                    value: '$done30/$total30',
                    label: s.completedLast30,
                    color: AppColors.mint,
                  ),
                ),
              ],
            ),
            SectionHeader(s.previousChallenges),
            if (history.isEmpty)
              SoftCard(
                child: Text(s.noChallengeHistory, style: theme.textTheme.bodyMedium?.copyWith(color: context.softText)),
              )
            else
              SoftCard(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    for (final h in history)
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: (h.done ? AppColors.mintDeep : AppColors.creamDeep).withValues(
                            alpha: context.isDark ? 0.3 : 1,
                          ),
                          child: Icon(h.done ? Icons.check_rounded : h.def.icon, size: 20),
                        ),
                        title: Text(context.l(h.def.title)),
                        subtitle: Text(MaterialLocalizations.of(context).formatMediumDate(h.day)),
                        trailing: Text(
                          h.done ? s.done : s.missed,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: h.done
                                ? (context.isDark ? AppColors.mintDeep : AppColors.sageDark)
                                : context.softText,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
