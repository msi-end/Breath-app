import '../data/challenges.dart';
import '../data/techniques.dart';
import '../models/session_record.dart';
import '../models/technique.dart';
import 'date_utils.dart';

class ChallengeProgress {
  const ChallengeProgress(this.def, this.day, this.current, this.target);

  final ChallengeDef def;
  final DateTime day;
  final int current;
  final int target;

  bool get done => current >= target;
  double get fraction => target == 0 ? 1 : (current / target).clamp(0, 1).toDouble();
}

/// Daily challenges are derived entirely from the local session history,
/// so they work offline and need no extra storage.
class ChallengeService {
  ChallengeService._();

  static ChallengeDef challengeFor(DateTime day) {
    final index = DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
    return dailyChallenges[index % dailyChallenges.length];
  }

  static bool _hasTag(SessionRecord s, TechniqueTag tag) => techniqueById(s.techniqueId)?.tags.contains(tag) ?? false;

  static ChallengeProgress evaluate(DateTime day, List<SessionRecord> all) {
    final d = dayOf(day);
    final def = challengeFor(d);
    final onDay = all.where((s) => s.day == d).toList();
    int current;
    switch (def.kind) {
      case ChallengeKind.longSession:
        current = onDay.fold(0, (m, s) => s.durationSeconds > m ? s.durationSeconds : m);
      case ChallengeKind.totalMinutes:
        current = onDay.fold(0, (sum, s) => sum + s.durationSeconds);
      case ChallengeKind.sessionCount:
        current = onDay.length;
      case ChallengeKind.relaxation:
        current =
            onDay.any(
              (s) => s.techniqueId != calmModeTechnique.id && _hasTag(s, TechniqueTag.relax) && s.durationSeconds >= 60,
            )
            ? 1
            : 0;
      case ChallengeKind.focus:
        current = onDay.any((s) => _hasTag(s, TechniqueTag.focus)) ? 1 : 0;
      case ChallengeKind.distinctDays:
        final start = addDays(d, -6);
        current = all.where((s) => !s.day.isBefore(start) && !s.day.isAfter(d)).map((s) => s.day).toSet().length;
      case ChallengeKind.newTechnique:
        final before = all.where((s) => s.day.isBefore(d)).map((s) => s.techniqueId).toSet();
        final triedAll = allTechniques.every((t) => before.contains(t.id));
        Set<String> seen = before;
        if (triedAll) {
          // Everything has been tried: count anything not practiced in the last week.
          final weekStart = addDays(d, -7);
          seen = all.where((s) => s.day.isBefore(d) && !s.day.isBefore(weekStart)).map((s) => s.techniqueId).toSet();
        }
        current =
            onDay.any(
              (s) =>
                  techniqueById(s.techniqueId) != null &&
                  s.techniqueId != calmModeTechnique.id &&
                  !seen.contains(s.techniqueId),
            )
            ? 1
            : 0;
    }
    return ChallengeProgress(def, d, current > def.target ? def.target : current, def.target);
  }

  static ChallengeProgress todayProgress(List<SessionRecord> all) => evaluate(today(), all);

  /// Consecutive completed challenge days, ending today (or yesterday if
  /// today's challenge is still open).
  static int streak(List<SessionRecord> all) {
    var cursor = today();
    if (!evaluate(cursor, all).done) cursor = addDays(cursor, -1);
    var count = 0;
    while (count < 3650 && evaluate(cursor, all).done) {
      count++;
      cursor = addDays(cursor, -1);
    }
    return count;
  }

  /// Previous days' challenges (newest first), starting from [since].
  static List<ChallengeProgress> history(List<SessionRecord> all, DateTime since, {int days = 14}) {
    final out = <ChallengeProgress>[];
    final start = dayOf(since);
    for (var i = 1; i <= days; i++) {
      final d = addDays(today(), -i);
      if (d.isBefore(start)) break;
      out.add(evaluate(d, all));
    }
    return out;
  }

  /// (completed, total) over the last [days] days the user has had the app.
  static (int, int) completionRate(List<SessionRecord> all, DateTime since, {int days = 30}) {
    var done = 0, total = 0;
    final start = dayOf(since);
    for (var i = 0; i < days; i++) {
      final d = addDays(today(), -i);
      if (d.isBefore(start)) break;
      total++;
      if (evaluate(d, all).done) done++;
    }
    return (done, total);
  }
}
