import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../l10n/l_text.dart';

/// One reminder message. [payload] says where a tap should take the user:
/// `breathe`, `breathe:<techniqueId>`, `explore:<category>`,
/// `music:<categoryId>` or `challenge`.
class ReminderMessage {
  const ReminderMessage(this.title, this.body, this.payload);

  final LText title;
  final LText body;
  final String payload;
}

/// A different message for each day of the week (index 0 = Monday).
const morningMessages = <ReminderMessage>[
  ReminderMessage(
    LText('Good morning 🌿', 'सुप्रभात 🌿'),
    LText('Start the week with 3 calm minutes of breathing.', 'हफ़्ते की शुरुआत 3 शांत मिनट की श्वास से करें।'),
    'breathe',
  ),
  ReminderMessage(
    LText('Wake up your body', 'शरीर को जगाएँ'),
    LText('Try a gentle yoga stretch from Explore today.', 'आज Explore से एक हल्का योग खिंचाव आज़माएँ।'),
    'explore:yoga',
  ),
  ReminderMessage(
    LText('Morning energy ☀️', 'सुबह की ऊर्जा ☀️'),
    LText('Play some uplifting music to get going.', 'दिन शुरू करने के लिए उत्साह भरा संगीत सुनें।'),
    'music:energy',
  ),
  ReminderMessage(
    LText('A fresh breath for a fresh day', 'नए दिन के लिए ताज़ी साँस'),
    LText('Box Breathing takes just 3 minutes. Ready?', 'बॉक्स ब्रीदिंग में बस 3 मिनट लगते हैं। तैयार?'),
    'breathe:box',
  ),
  ReminderMessage(
    LText('Kitchen wisdom 🌼', 'रसोई का ज्ञान 🌼'),
    LText('Learn how haldi and tulsi are used in daily life.', 'जानें कि हल्दी और तुलसी रोज़मर्रा में कैसे इस्तेमाल होती हैं।'),
    'explore:herbs',
  ),
  ReminderMessage(
    LText('Your daily challenge is ready', 'आपका दैनिक चैलेंज तैयार है'),
    LText('A small goal for today — keep your streak going.', 'आज का छोटा लक्ष्य — अपनी स्ट्रीक जारी रखें।'),
    'challenge',
  ),
  ReminderMessage(
    LText('Slow Sunday morning', 'सुकून भरी सुबह'),
    LText('A simple lifestyle tip is waiting in Explore.', 'Explore में एक आसान जीवनशैली टिप आपका इंतज़ार कर रही है।'),
    'explore:lifestyle',
  ),
];

const eveningMessages = <ReminderMessage>[
  ReminderMessage(
    LText('Time to unwind 🌙', 'आराम का समय 🌙'),
    LText('Play soft sleep music and let the day go.', 'नींद का कोमल संगीत चलाएँ और दिन को जाने दें।'),
    'music:sleep',
  ),
  ReminderMessage(
    LText('Slow down for tonight', 'आज रात धीमे हो जाएँ'),
    LText('Try a few rounds of 4-7-8 breathing before bed.', 'सोने से पहले 4-7-8 श्वास के कुछ चक्र आज़माएँ।'),
    'breathe:478',
  ),
  ReminderMessage(
    LText('Calm piano for your evening', 'शाम के लिए शांत पियानो'),
    LText('Quiet music to help you relax.', 'आराम के लिए धीमा संगीत।'),
    'music:piano',
  ),
  ReminderMessage(
    LText('Let go of the day', 'दिन की थकान छोड़ें'),
    LText('A longer exhale can feel very relaxing. Try Deep Belly Breathing.', 'लंबी साँस छोड़ना बहुत सुकून देता है। गहरी पेट श्वास आज़माएँ।'),
    'breathe:belly',
  ),
  ReminderMessage(
    LText('Your night-time playlist', 'आपकी रात की प्लेलिस्ट'),
    LText('Sleep & Rest music is ready when you are.', 'नींद और आराम का संगीत तैयार है।'),
    'music:sleep',
  ),
  ReminderMessage(
    LText('A calmer evening', 'एक शांत शाम'),
    LText('Explore simple ways to ease stress after a long week.', 'लंबे हफ़्ते के बाद तनाव कम करने के आसान तरीके देखें।'),
    'explore:calm',
  ),
  ReminderMessage(
    LText('Rest well tonight', 'आज रात अच्छा आराम करें'),
    LText('Relaxing music for a peaceful night.', 'सुकून भरी रात के लिए आरामदायक संगीत।'),
    'music:relaxation',
  ),
];

/// Optional daily reminders: a morning nudge (default 8:00 AM) and an
/// evening wind-down (default 9:00 PM). Both are off until the user turns
/// them on, and work fully offline (local notifications).
class ReminderService extends ChangeNotifier {
  ReminderService(this._prefs);

  static const _kMorning = 'reminders.morning';
  static const _kMorningAt = 'reminders.morningAt';
  static const _kEvening = 'reminders.evening';
  static const _kEveningAt = 'reminders.eveningAt';
  static const _kAsked = 'reminders.asked';

  static const _morningBase = 100;
  static const _eveningBase = 200;

  final SharedPreferences _prefs;
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  String _lang = 'en';
  bool _tzKnown = false;

  /// Called when the user taps a reminder (also for the one that opened the app).
  void Function(String payload)? onOpen;
  String? _pendingPayload;

  bool get available => _ready;
  bool get morning => _prefs.getBool(_kMorning) ?? false;
  bool get evening => _prefs.getBool(_kEvening) ?? false;
  TimeOfDay get morningTime => _time(_kMorningAt, const TimeOfDay(hour: 8, minute: 0));
  TimeOfDay get eveningTime => _time(_kEveningAt, const TimeOfDay(hour: 21, minute: 0));

  TimeOfDay _time(String key, TimeOfDay fallback) {
    final m = _prefs.getInt(key);
    return m == null ? fallback : TimeOfDay(hour: m ~/ 60, minute: m % 60);
  }

  Future<void> init({required String lang}) async {
    _lang = lang;
    try {
      tzdata.initializeTimeZones();
      try {
        final info = await FlutterTimezone.getLocalTimezone().timeout(const Duration(seconds: 3));
        tz.setLocalLocation(tz.getLocation(info.identifier));
        _tzKnown = true;
      } catch (e) {
        debugPrint('Time zone lookup failed, using device offset: $e');
      }
      await _plugin
          .initialize(
            settings: const InitializationSettings(
              android: AndroidInitializationSettings('ic_stat_breathecare'),
              iOS: DarwinInitializationSettings(
                requestAlertPermission: false,
                requestBadgePermission: false,
                requestSoundPermission: false,
              ),
            ),
            onDidReceiveNotificationResponse: (r) => _open(r.payload),
          )
          .timeout(const Duration(seconds: 5));
      _ready = true;
      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) _pendingPayload = launch?.notificationResponse?.payload;
      // Re-schedule so messages follow the current language and times.
      await _reschedule();
    } catch (e) {
      debugPrint('Reminders unavailable: $e');
    }
  }

  void _open(String? payload) {
    if (payload == null || payload.isEmpty) return;
    final handler = onOpen;
    if (handler == null) {
      _pendingPayload = payload;
    } else {
      handler(payload);
    }
  }

  /// The payload of the reminder that launched the app, consumed once.
  String? takeLaunchPayload() {
    final p = _pendingPayload;
    _pendingPayload = null;
    return p;
  }

  /// Ask once, after the user has come back on a second day.
  bool shouldAsk({required int activeDays}) =>
      _ready && !(_prefs.getBool(_kAsked) ?? false) && !morning && !evening && activeDays >= 2;

  Future<void> markAsked() => _prefs.setBool(_kAsked, true);

  Future<void> setLang(String lang) async {
    if (lang == _lang) return;
    _lang = lang;
    await _reschedule();
  }

  /// Turns the morning reminder on/off. Returns false if notifications
  /// aren't allowed on this device.
  Future<bool> setMorning(bool on) => _setEnabled(_kMorning, on);

  Future<bool> setEvening(bool on) => _setEnabled(_kEvening, on);

  Future<bool> _setEnabled(String key, bool on) async {
    if (on && !await _requestPermission()) return false;
    await _prefs.setBool(key, on);
    await _prefs.setBool(_kAsked, true);
    notifyListeners();
    await _reschedule();
    return true;
  }

  Future<void> setMorningTime(TimeOfDay t) => _setTime(_kMorningAt, t);

  Future<void> setEveningTime(TimeOfDay t) => _setTime(_kEveningAt, t);

  Future<void> _setTime(String key, TimeOfDay t) async {
    await _prefs.setInt(key, t.hour * 60 + t.minute);
    notifyListeners();
    await _reschedule();
  }

  Future<bool> _requestPermission() async {
    if (!_ready) return false;
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) return await android.requestNotificationsPermission() ?? false;
      final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) return await ios.requestPermissions(alert: true, sound: true) ?? false;
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
    }
    return false;
  }

  Future<void> _reschedule() async {
    if (!_ready) return;
    try {
      for (var d = 0; d < 7; d++) {
        await _plugin.cancel(id: _morningBase + d);
        await _plugin.cancel(id: _eveningBase + d);
      }
      if (morning) await _scheduleWeek(_morningBase, morningTime, morningMessages);
      if (evening) await _scheduleWeek(_eveningBase, eveningTime, eveningMessages);
    } catch (e) {
      debugPrint('Could not schedule reminders: $e');
    }
  }

  Future<void> _scheduleWeek(int base, TimeOfDay at, List<ReminderMessage> messages) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'breathecare_reminders',
        'Daily reminders',
        channelDescription: 'Gentle reminders to breathe, explore or listen',
        icon: 'ic_stat_breathecare',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );
    for (var d = 0; d < 7; d++) {
      final msg = messages[d];
      await _plugin.zonedSchedule(
        id: base + d,
        title: msg.title.get(_lang),
        body: msg.body.get(_lang),
        payload: msg.payload,
        scheduledDate: nextWeekdayAt(DateTime.now(), DateTime.monday + d, at.hour, at.minute),
        notificationDetails: details,
        // Inexact: no special alarm permission, battery friendly.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  /// Next [weekday] (DateTime.monday..sunday) at [hour]:[minute], local time.
  tz.TZDateTime nextWeekdayAt(DateTime now, int weekday, int hour, int minute) {
    var day = DateTime(now.year, now.month, now.day + (weekday - now.weekday) % 7, hour, minute);
    if (!day.isAfter(now)) day = DateTime(day.year, day.month, day.day + 7, hour, minute);
    return _tzKnown
        ? tz.TZDateTime(tz.local, day.year, day.month, day.day, hour, minute)
        : tz.TZDateTime.from(day, tz.UTC);
  }

  Future<void> clear() async {
    for (final k in [_kMorning, _kMorningAt, _kEvening, _kEveningAt, _kAsked]) {
      await _prefs.remove(k);
    }
    notifyListeners();
    await _reschedule();
  }
}
