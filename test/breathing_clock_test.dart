import 'package:breathecare/data/techniques.dart';
import 'package:breathecare/models/breath_pattern.dart';
import 'package:breathecare/services/breathing_clock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final box = techniqueById('box')!.pattern;

  test('session length is rounded up to whole cycles', () {
    final clock = BreathingClock(box, targetSeconds: 60); // 16s cycle
    expect(clock.plannedSeconds, 64);
  });

  test('phases follow the pattern and the circle expands then contracts', () {
    final clock = BreathingClock(box, targetSeconds: 60);
    expect(clock.phase.type, PhaseType.inhale);
    expect(clock.expansion, closeTo(0, 0.01));
    for (var i = 0; i < 8; i++) {
      clock.advance(0.25); // 2s
    }
    expect(clock.phase.type, PhaseType.inhale);
    expect(clock.expansion, closeTo(0.5, 0.01));
    for (var i = 0; i < 12; i++) {
      clock.advance(0.25); // now at 5s
    }
    expect(clock.phase.type, PhaseType.holdIn);
    expect(clock.expansion, 1);
    for (var i = 0; i < 16; i++) {
      clock.advance(0.25); // 9s
    }
    expect(clock.phase.type, PhaseType.exhale);
    expect(clock.phaseSecondsLeft, 3);
  });

  test('large time jumps are clamped (e.g. app backgrounded)', () {
    final clock = BreathingClock(box, targetSeconds: 60);
    clock.advance(30);
    expect(clock.elapsed, 0.25);
  });

  test('finishes exactly at the planned end', () {
    final clock = BreathingClock(box, targetSeconds: 16);
    while (!clock.isFinished) {
      clock.advance(0.25);
    }
    expect(clock.elapsed, 16);
    expect(clock.remainingSeconds, 0);
  });

  test('gentle mode removes every hold', () {
    for (final t in allTechniques) {
      expect(t.pattern.withoutHolds().hasHolds, isFalse, reason: t.id);
      expect(t.pattern.withoutHolds().phases, isNotEmpty);
    }
  });

  test('calm mode never asks for a breath hold', () {
    expect(calmModeTechnique.pattern.hasHolds, isFalse);
  });
}
