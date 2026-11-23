import 'dart:math' as math;

import '../models/breath_pattern.dart';

/// Pure timing logic for a guided breathing session.
///
/// Elapsed time is advanced explicitly (from a Ticker), which keeps the
/// session exact across pauses and makes the logic easy to test.
class BreathingClock {
  BreathingClock(this.pattern, {int? targetSeconds})
    : assert(pattern.phases.isNotEmpty),
      plannedSeconds = targetSeconds == null
          ? null
          // Always end on a full breath cycle.
          : (targetSeconds / pattern.cycleSeconds).ceil() * pattern.cycleSeconds;

  BreathPattern pattern;

  /// Total planned length, or null for an open-ended session.
  final int? plannedSeconds;

  double elapsed = 0;

  int get cycleSeconds => pattern.cycleSeconds;

  bool get isFinished => plannedSeconds != null && elapsed >= plannedSeconds!;

  /// Advances time. Large jumps (e.g. after the app was backgrounded) are
  /// clamped so the animation never skips ahead unexpectedly.
  void advance(double dtSeconds) {
    final dt = dtSeconds.clamp(0.0, 0.25);
    elapsed += dt;
    if (plannedSeconds != null && elapsed > plannedSeconds!) elapsed = plannedSeconds!.toDouble();
  }

  /// Swap rhythm while keeping total elapsed time (used by the pace toggle).
  void changePattern(BreathPattern next) {
    pattern = next;
    elapsed = 0;
  }

  ({int index, BreathPhase phase, double local}) _locate() {
    final t = elapsed % cycleSeconds;
    var start = 0.0;
    for (var i = 0; i < pattern.phases.length; i++) {
      final p = pattern.phases[i];
      if (t < start + p.seconds || i == pattern.phases.length - 1) {
        return (index: i, phase: p, local: (t - start).clamp(0.0, p.seconds.toDouble()));
      }
      start += p.seconds;
    }
    throw StateError('unreachable');
  }

  BreathPhase get phase => _locate().phase;

  /// A counter that changes every time a new phase begins.
  int get phaseSerial => (elapsed ~/ cycleSeconds) * pattern.phases.length + _locate().index;

  /// Whole seconds left in the current phase (for the countdown).
  int get phaseSecondsLeft {
    final l = _locate();
    return math.max(1, (l.phase.seconds - l.local).ceil());
  }

  /// Fraction through the current phase.
  double get phaseProgress {
    final l = _locate();
    return l.phase.seconds == 0 ? 1 : l.local / l.phase.seconds;
  }

  /// 0 = fully exhaled, 1 = fully inhaled, eased for a natural feel.
  double get expansion {
    final l = _locate();
    final f = l.phase.seconds == 0 ? 1.0 : l.local / l.phase.seconds;
    final eased = 0.5 - 0.5 * math.cos(math.pi * f);
    switch (l.phase.type) {
      case PhaseType.inhale:
        return eased;
      case PhaseType.holdIn:
        return 1;
      case PhaseType.exhale:
        return 1 - eased;
      case PhaseType.holdOut:
        return 0;
    }
  }

  int get remainingSeconds => plannedSeconds == null ? 0 : math.max(0, (plannedSeconds! - elapsed).ceil());

  double get sessionProgress =>
      plannedSeconds == null || plannedSeconds == 0 ? 0 : (elapsed / plannedSeconds!).clamp(0.0, 1.0);
}
