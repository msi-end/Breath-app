import 'package:flutter/material.dart';

import '../data/moods.dart';
import '../l10n/l_text.dart';
import '../l10n/strings.dart';
import '../screens/navigation.dart';
import '../theme/app_colors.dart';

/// "How are you feeling right now?" popup.
Future<void> showMoodPicker(BuildContext context) async {
  final mood = await pickMood(context);
  if (mood != null && context.mounted) openMoodResults(context, mood);
}

/// Shows the mood popup and returns the selection (null when dismissed).
Future<Mood?> pickMood(BuildContext context) =>
    showDialog<Mood>(context: context, builder: (context) => const _MoodDialog());

class _MoodDialog extends StatelessWidget {
  const _MoodDialog();

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.howAreYouFeeling, textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              s.moodPrivacyNote,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: context.softText),
            ),
            const SizedBox(height: 18),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.78,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final m in allMoods)
                  Material(
                    color: m.color.withValues(alpha: context.isDark ? 0.2 : 0.45),
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => Navigator.of(context).pop(m),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(m.emoji, style: const TextStyle(fontSize: 28)),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                context.l(m.label),
                                style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(s.close)),
          ],
        ),
      ),
    );
  }
}
