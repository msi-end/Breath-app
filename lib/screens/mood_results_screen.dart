import 'package:flutter/material.dart';

import '../data/moods.dart';
import '../data/techniques.dart';
import '../l10n/l_text.dart';
import '../l10n/strings.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/mood_picker_sheet.dart';
import '../widgets/nature_background.dart';
import 'navigation.dart';

class MoodResultsScreen extends StatelessWidget {
  const MoodResultsScreen({super.key, required this.mood});

  final Mood mood;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(s.moodBreathing)),
      body: NatureBackground(
        tint: Color.lerp(mood.color, context.isDark ? AppColors.night : AppColors.cream, context.isDark ? 0.8 : 0.45),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Row(
                children: [
                  Text(mood.emoji, style: const TextStyle(fontSize: 44)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.youAreFeeling, style: theme.textTheme.bodyMedium?.copyWith(color: context.softText)),
                        Text(context.l(mood.label), style: theme.textTheme.headlineMedium),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(context.l(mood.message), style: theme.textTheme.bodyLarge),
              SectionHeader(s.suggestedForYou),
              for (final rec in mood.recommendations) ...[_RecommendationCard(rec: rec), const SizedBox(height: 14)],
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    final m = await pickMood(context);
                    if (m != null && context.mounted) {
                      Navigator.of(context)
                          .pushReplacement(MaterialPageRoute(builder: (_) => MoodResultsScreen(mood: m)));
                    }
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(s.chooseAnotherMood),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                s.notMedicalAdvice,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: context.softText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.rec});

  final MoodRecommendation rec;

  @override
  Widget build(BuildContext context) {
    final t = techniqueById(rec.techniqueId)!;
    final s = context.s;
    final theme = Theme.of(context);
    return SoftCard(
      onTap: () => openTechnique(context, t),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(t.icon, color: t.color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l(t.name), style: theme.textTheme.titleMedium),
                    Text(
                      s.minutesCount(t.recommendedMinutes),
                      style: theme.textTheme.labelSmall?.copyWith(color: context.softText),
                    ),
                  ],
                ),
              ),
              FavoriteButton(techniqueId: t.id),
            ],
          ),
          const SizedBox(height: 12),
          Text(context.l(rec.why), style: theme.textTheme.bodyMedium),
          const SizedBox(height: 10),
          PatternChips(t.pattern, dense: true),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => startSession(context, t),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(s.startBreathing),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(onPressed: () => openTechnique(context, t), child: Text(s.details)),
            ],
          ),
        ],
      ),
    );
  }
}
