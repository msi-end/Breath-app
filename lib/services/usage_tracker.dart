import 'package:shared_preferences/shared_preferences.dart';

import 'date_utils.dart';

/// Tracks app-usage days, used for the optional account invitation.
class UsageTracker {
  UsageTracker(this._prefs);

  static const _kFirstOpen = 'usage.firstOpen';
  static const _kDays = 'usage.activeDays';
  static const _kPromptCount = 'usage.accountPromptCount';
  static const _kLastPrompt = 'usage.accountPromptLast';

  /// Days of usage before inviting the user to create an account.
  static const promptAfterDays = 10;
  static const maxPrompts = 2;

  final SharedPreferences _prefs;

  DateTime get firstOpen {
    final ms = _prefs.getInt(_kFirstOpen);
    return ms == null ? today() : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  int get activeDayCount => (_prefs.getStringList(_kDays) ?? const []).length;

  Future<void> recordOpen() async {
    if (_prefs.getInt(_kFirstOpen) == null) {
      await _prefs.setInt(_kFirstOpen, today().millisecondsSinceEpoch);
    }
    final days = (_prefs.getStringList(_kDays) ?? <String>[]).toSet();
    if (days.add(dayKey(today()))) {
      final list = days.toList()..sort();
      // Keep the list small; only the count matters.
      await _prefs.setStringList(_kDays, list.length > 60 ? list.sublist(list.length - 60) : list);
    }
  }

  /// True after roughly 10 days of use, at most twice, 10 days apart.
  bool shouldInviteToAccount({required bool signedIn}) {
    if (signedIn) return false;
    final count = _prefs.getInt(_kPromptCount) ?? 0;
    if (count >= maxPrompts) return false;
    final usedDays = daysBetween(firstOpen, today()) + 1;
    if (usedDays < promptAfterDays && activeDayCount < promptAfterDays) return false;
    final last = _prefs.getInt(_kLastPrompt);
    if (last != null && daysBetween(DateTime.fromMillisecondsSinceEpoch(last), today()) < promptAfterDays) {
      return false;
    }
    return true;
  }

  Future<void> markInvited() async {
    await _prefs.setInt(_kPromptCount, (_prefs.getInt(_kPromptCount) ?? 0) + 1);
    await _prefs.setInt(_kLastPrompt, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> clear() async {
    for (final k in [_kFirstOpen, _kDays, _kPromptCount, _kLastPrompt]) {
      await _prefs.remove(k);
    }
    await recordOpen();
  }
}
