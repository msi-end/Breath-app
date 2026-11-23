import 'package:flutter/material.dart';

import '../l10n/l_text.dart';
import 'breath_pattern.dart';

enum TechniqueTag { beginner, relax, focus, calm, balance }

class Technique {
  const Technique({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.purpose,
    required this.benefits,
    required this.steps,
    required this.pattern,
    required this.recommendedMinutes,
    required this.icon,
    required this.color,
    required this.tags,
    this.caution,
  });

  final String id;
  final LText name;
  final LText tagline;
  final LText description;
  final LText purpose;
  final List<LText> benefits;
  final List<LText> steps;
  final BreathPattern pattern;
  final int recommendedMinutes;
  final IconData icon;
  final Color color;
  final Set<TechniqueTag> tags;
  final LText? caution;

  /// Path of this technique's guidance MP3 in Firebase Storage.
  String get audioStoragePath => 'guidance/$id.mp3';
}
