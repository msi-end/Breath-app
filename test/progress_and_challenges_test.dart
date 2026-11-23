import 'package:breathecare/data/challenges.dart';
import 'package:breathecare/data/moods.dart';
import 'package:breathecare/data/techniques.dart';
import 'package:breathecare/models/session_record.dart';
import 'package:breathecare/services/challenge_service.dart';
import 'package:breathecare/services/date_utils.dart';
import 'package:breathecare/services/progress_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

SessionRecord rec(String t, DateTime day, int secs, [int n = 0]) => SessionRecord(
  id: '${day.millisecondsSinceEpoch}-$t-$n',
  techniqueId: t,
  startedAt: day.add(const Duration(hours: 9)),
  durationSeconds: secs,
  completed: true,
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('every mood recommendation points at a real technique', () {
    expect(allMoods.length, 8);
    for (final m in allMoods) {
      expect(m.recommendations, isNotEmpty);
      for (final r in m.recommendations) {
        expect(techniqueById(r.techniqueId), isNotNull, reason: '${m.id} -> ${r.techniqueId}');
      }
    }
  });

  test('ten techniques with complete content', () {
    expect(allTechniques.length, 10);
    expect(allTechniques.map((t) => t.id).toSet().length, 10);
    for (final t in allTechniques) {
      expect(t.steps, isNotEmpty);
      expect(t.benefits, isNotEmpty);
      expect(t.name.hi, isNotEmpty);
    }
  });

  test('store records, persists, streaks and favorites', () async {
    final prefs = await SharedPreferences.getInstance();
    final store = ProgressStore(prefs);
    final now = DateTime.now();
    expect(
      await store.addSession(techniqueId: 'box', startedAt: now, durationSeconds: 5, completed: false),
      isNull,
      reason: 'too short',
    );
    await store.addSession(techniqueId: 'box', startedAt: now, durationSeconds: 120, completed: true);
    await store.addSession(
      techniqueId: 'slow',
      startedAt: now.subtract(const Duration(days: 1)),
      durationSeconds: 60,
      completed: true,
    );
    await store.toggleFavorite('box');

    final reloaded = ProgressStore(prefs);
    expect(reloaded.totalSessions, 2);
    expect(reloaded.totalSeconds, 180);
    expect(reloaded.currentStreak, 2);
    expect(reloaded.isFavorite('box'), isTrue);
    expect(reloaded.recentTechniqueIds().first, 'box');
    expect(reloaded.secondsForLastDays(7).last, 120);

    final backup = reloaded.exportData();
    await reloaded.clear();
    expect(reloaded.totalSessions, 0);
    await reloaded.importData(backup);
    expect(reloaded.totalSessions, 2);
    expect(reloaded.isFavorite('box'), isTrue);
  });

  test('challenge evaluation for each kind', () {
    final t = today();
    for (var offset = 0; offset < dailyChallenges.length; offset++) {
      final day = addDays(t, -offset);
      final def = ChallengeService.challengeFor(day);
      final empty = ChallengeService.evaluate(day, const []);
      expect(empty.done, isFalse, reason: def.id);

      final List<SessionRecord> sessions = switch (def.kind) {
        ChallengeKind.longSession => [rec('equal', day, 130)],
        ChallengeKind.totalMinutes => [rec('equal', day, 200), rec('slow', day, 120, 1)],
        ChallengeKind.newTechnique => [rec('box', addDays(day, -2), 60), rec('belly', day, 60)],
        ChallengeKind.relaxation => [rec('belly', day, 90)],
        ChallengeKind.distinctDays => [
          rec('box', day, 30),
          rec('box', addDays(day, -2), 30),
          rec('box', addDays(day, -5), 30),
        ],
        ChallengeKind.sessionCount => [rec('box', day, 30), rec('box', day, 30, 1)],
        ChallengeKind.focus => [rec('focus', day, 60)],
      };
      expect(ChallengeService.evaluate(day, sessions).done, isTrue, reason: def.id);
    }
  });

  test('trying the same technique again does not count as new', () {
    final t = today();
    // Find a day whose challenge is "new technique".
    var day = t;
    while (ChallengeService.challengeFor(day).kind != ChallengeKind.newTechnique) {
      day = addDays(day, -1);
    }
    final sessions = [rec('box', addDays(day, -1), 60), rec('box', day, 60)];
    expect(ChallengeService.evaluate(day, sessions).done, isFalse);
  });
}
