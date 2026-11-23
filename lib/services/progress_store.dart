import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/techniques.dart';
import '../models/session_record.dart';
import 'date_utils.dart';

/// Local, offline-first store for practice history and favorites.
class ProgressStore extends ChangeNotifier {
  ProgressStore(this._prefs) {
    _load();
  }

  static const _kSessions = 'progress.sessions.v1';
  static const _kFavorites = 'progress.favorites.v1';

  /// Sessions shorter than this are not recorded.
  static const minRecordedSeconds = 15;

  final SharedPreferences _prefs;
  final List<SessionRecord> _sessions = [];
  final Set<String> _favorites = {};

  List<SessionRecord> get sessions => List.unmodifiable(_sessions);
  Set<String> get favorites => Set.unmodifiable(_favorites);

  void _load() {
    _sessions.clear();
    _favorites.clear();
    final raw = _prefs.getString(_kSessions);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _sessions.addAll(list.map((e) => SessionRecord.fromJson(Map<String, dynamic>.from(e as Map))));
      } catch (e) {
        debugPrint('ProgressStore: could not read sessions: $e');
      }
    }
    _sessions.sort((a, b) => a.startedAt.compareTo(b.startedAt));
    _favorites.addAll(_prefs.getStringList(_kFavorites) ?? const []);
  }

  Future<void> _saveSessions() => _prefs.setString(_kSessions, jsonEncode(_sessions.map((s) => s.toJson()).toList()));

  Future<void> _saveFavorites() => _prefs.setStringList(_kFavorites, _favorites.toList());

  /// Records a session. Returns the record, or null when it was too short.
  Future<SessionRecord?> addSession({
    required String techniqueId,
    required DateTime startedAt,
    required int durationSeconds,
    required bool completed,
  }) async {
    if (durationSeconds < minRecordedSeconds) return null;
    final record = SessionRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      techniqueId: techniqueId,
      startedAt: startedAt,
      durationSeconds: durationSeconds,
      completed: completed,
    );
    _sessions.add(record);
    notifyListeners();
    await _saveSessions();
    return record;
  }

  bool isFavorite(String id) => _favorites.contains(id);

  Future<void> toggleFavorite(String id) async {
    if (!_favorites.remove(id)) _favorites.add(id);
    notifyListeners();
    await _saveFavorites();
  }

  // ---------- Statistics ----------

  int get totalSessions => _sessions.length;

  int get totalSeconds => _sessions.fold(0, (s, r) => s + r.durationSeconds);

  int get totalMinutes => (totalSeconds / 60).round();

  List<SessionRecord> sessionsOn(DateTime day) {
    final d = dayOf(day);
    return _sessions.where((s) => s.day == d).toList();
  }

  int secondsOn(DateTime day) => sessionsOn(day).fold(0, (s, r) => s + r.durationSeconds);

  /// Seconds practiced per day for the [n] days ending today (oldest first).
  List<int> secondsForLastDays(int n) {
    final t = today();
    final map = <DateTime, int>{};
    for (final s in _sessions) {
      map[s.day] = (map[s.day] ?? 0) + s.durationSeconds;
    }
    return [for (var i = n - 1; i >= 0; i--) map[addDays(t, -i)] ?? 0];
  }

  Set<DateTime> get practiceDays => _sessions.map((s) => s.day).toSet();

  int get currentStreak {
    final days = practiceDays;
    var cursor = today();
    if (!days.contains(cursor)) cursor = addDays(cursor, -1);
    var streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = addDays(cursor, -1);
    }
    return streak;
  }

  int get longestStreak {
    final days = practiceDays.toList()..sort();
    var best = 0, run = 0;
    DateTime? prev;
    for (final d in days) {
      run = (prev != null && daysBetween(prev, d) == 1) ? run + 1 : 1;
      if (run > best) best = run;
      prev = d;
    }
    return best;
  }

  /// Most recently practiced techniques, newest first, without duplicates.
  List<String> recentTechniqueIds({int limit = 6, bool includeCalmMode = false}) {
    final out = <String>[];
    for (final s in _sessions.reversed) {
      if (!includeCalmMode && s.techniqueId == calmModeTechnique.id) continue;
      if (techniqueById(s.techniqueId) == null) continue;
      if (!out.contains(s.techniqueId)) out.add(s.techniqueId);
      if (out.length >= limit) break;
    }
    return out;
  }

  /// Technique id -> session count, most practiced first.
  List<MapEntry<String, int>> techniqueCounts() {
    final map = <String, int>{};
    for (final s in _sessions) {
      if (techniqueById(s.techniqueId) == null) continue;
      map[s.techniqueId] = (map[s.techniqueId] ?? 0) + 1;
    }
    final entries = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  // ---------- Backup / reset ----------

  Map<String, dynamic> exportData() => {
    'sessions': _sessions.map((s) => s.toJson()).toList(),
    'favorites': _favorites.toList(),
  };

  /// Replaces local data with [data] from a backup, merging sessions by id.
  Future<void> importData(Map<String, dynamic> data) async {
    final incoming = (data['sessions'] as List<dynamic>? ?? const []).map(
      (e) => SessionRecord.fromJson(Map<String, dynamic>.from(e as Map)),
    );
    final byId = {for (final s in _sessions) s.id: s};
    for (final s in incoming) {
      byId[s.id] = s;
    }
    _sessions
      ..clear()
      ..addAll(byId.values)
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
    _favorites.addAll((data['favorites'] as List<dynamic>? ?? const []).cast<String>());
    notifyListeners();
    await _saveSessions();
    await _saveFavorites();
  }

  Future<void> clear() async {
    _sessions.clear();
    _favorites.clear();
    notifyListeners();
    await _prefs.remove(_kSessions);
    await _prefs.remove(_kFavorites);
  }
}
