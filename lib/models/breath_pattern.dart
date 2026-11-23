enum PhaseType { inhale, holdIn, exhale, holdOut }

class BreathPhase {
  const BreathPhase(this.type, this.seconds);

  final PhaseType type;
  final int seconds;

  bool get isHold => type == PhaseType.holdIn || type == PhaseType.holdOut;
}

class BreathPattern {
  const BreathPattern(this.phases);

  final List<BreathPhase> phases;

  bool get hasHolds => phases.any((p) => p.isHold);

  int get cycleSeconds => phases.fold(0, (sum, p) => sum + p.seconds);

  /// The same rhythm with every breath-hold removed, so nobody is ever
  /// required to hold their breath.
  BreathPattern withoutHolds() => BreathPattern(phases.where((p) => !p.isHold).toList());

  /// Breaths per minute for display.
  double get breathsPerMinute => 60 / cycleSeconds;
}
