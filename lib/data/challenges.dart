import 'package:flutter/material.dart';

import '../l10n/l_text.dart';

enum ChallengeKind { longSession, totalMinutes, newTechnique, relaxation, distinctDays, sessionCount, focus }

class ChallengeDef {
  const ChallengeDef({
    required this.id,
    required this.kind,
    required this.target,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String id;
  final ChallengeKind kind;

  /// Seconds for time-based kinds, a count for the others.
  final int target;
  final LText title;
  final LText description;
  final IconData icon;
}

/// The rotation of daily challenges. Every calendar day maps to one entry.
const List<ChallengeDef> dailyChallenges = [
  ChallengeDef(
    id: 'two_min',
    kind: ChallengeKind.longSession,
    target: 120,
    title: LText('Two calm minutes', 'दो शांत मिनट'),
    description: LText(
      'Complete one breathing session of at least 2 minutes.',
      'कम से कम 2 मिनट का एक श्वास सत्र पूरा करें।',
    ),
    icon: Icons.timer_outlined,
  ),
  ChallengeDef(
    id: 'five_min',
    kind: ChallengeKind.totalMinutes,
    target: 300,
    title: LText('Five mindful minutes', 'पाँच सजग मिनट'),
    description: LText('Practice breathing for a total of 5 minutes today.', 'आज कुल 5 मिनट श्वास अभ्यास करें।'),
    icon: Icons.hourglass_bottom_rounded,
  ),
  ChallengeDef(
    id: 'new_technique',
    kind: ChallengeKind.newTechnique,
    target: 1,
    title: LText('Explorer', 'खोजकर्ता'),
    description: LText(
      'Try a breathing technique you have not practiced before.',
      'कोई ऐसी श्वास तकनीक आज़माएँ जो आपने पहले नहीं की।',
    ),
    icon: Icons.explore_outlined,
  ),
  ChallengeDef(
    id: 'relaxation',
    kind: ChallengeKind.relaxation,
    target: 1,
    title: LText('Unwind time', 'आराम का समय'),
    description: LText(
      'Complete a relaxation session (Deep Belly, 4-7-8, Slow or Gentle Relaxation) of at least 1 minute.',
      'कम से कम 1 मिनट का एक विश्राम सत्र (गहरी पेट, 4-7-8, धीमी या कोमल विश्राम) पूरा करें।',
    ),
    icon: Icons.eco_outlined,
  ),
  ChallengeDef(
    id: 'three_days',
    kind: ChallengeKind.distinctDays,
    target: 3,
    title: LText('Steady habit', 'स्थिर आदत'),
    description: LText(
      'Practice breathing on three different days this week.',
      'इस सप्ताह तीन अलग-अलग दिन श्वास अभ्यास करें।',
    ),
    icon: Icons.calendar_month_outlined,
  ),
  ChallengeDef(
    id: 'two_sessions',
    kind: ChallengeKind.sessionCount,
    target: 2,
    title: LText('Morning & evening', 'सुबह और शाम'),
    description: LText('Complete two breathing sessions today.', 'आज दो श्वास सत्र पूरे करें।'),
    icon: Icons.wb_twilight_outlined,
  ),
  ChallengeDef(
    id: 'focus',
    kind: ChallengeKind.focus,
    target: 1,
    title: LText('Clear mind', 'साफ़ मन'),
    description: LText(
      'Complete a focus session (Focus, Box or Equal Breathing).',
      'एक एकाग्रता सत्र (एकाग्रता, बॉक्स या समान श्वास) पूरा करें।',
    ),
    icon: Icons.center_focus_strong_outlined,
  ),
];
