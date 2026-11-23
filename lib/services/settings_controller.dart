import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._prefs) {
    _load();
  }

  static const _kLang = 'settings.lang';
  static const _kTheme = 'settings.theme';
  static const _kVoice = 'settings.voice';
  static const _kVoiceVolume = 'settings.voiceVolume';
  static const _kHaptics = 'settings.haptics';
  static const _kGentle = 'settings.gentleDefault';

  final SharedPreferences _prefs;

  String lang = 'en';
  ThemeMode themeMode = ThemeMode.system;
  bool voiceGuidance = true;
  double voiceVolume = 0.8;
  bool haptics = true;
  bool gentleModeDefault = false;

  Locale get locale => Locale(lang);

  void _load() {
    lang = _prefs.getString(_kLang) ?? _systemLang();
    themeMode = ThemeMode.values[(_prefs.getInt(_kTheme) ?? 0).clamp(0, 2)];
    voiceGuidance = _prefs.getBool(_kVoice) ?? true;
    voiceVolume = _prefs.getDouble(_kVoiceVolume) ?? 0.8;
    haptics = _prefs.getBool(_kHaptics) ?? true;
    gentleModeDefault = _prefs.getBool(_kGentle) ?? false;
  }

  static String _systemLang() {
    final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return code == 'hi' ? 'hi' : 'en';
  }

  Future<void> setLang(String value) async {
    lang = value;
    notifyListeners();
    await _prefs.setString(_kLang, value);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    notifyListeners();
    await _prefs.setInt(_kTheme, mode.index);
  }

  Future<void> setVoiceGuidance(bool v) async {
    voiceGuidance = v;
    notifyListeners();
    await _prefs.setBool(_kVoice, v);
  }

  Future<void> setVoiceVolume(double v) async {
    voiceVolume = v;
    notifyListeners();
    await _prefs.setDouble(_kVoiceVolume, v);
  }

  Future<void> setHaptics(bool v) async {
    haptics = v;
    notifyListeners();
    await _prefs.setBool(_kHaptics, v);
  }

  Future<void> setGentleModeDefault(bool v) async {
    gentleModeDefault = v;
    notifyListeners();
    await _prefs.setBool(_kGentle, v);
  }

  Future<void> reset() async {
    for (final k in [_kLang, _kTheme, _kVoice, _kVoiceVolume, _kHaptics, _kGentle]) {
      await _prefs.remove(k);
    }
    _load();
    notifyListeners();
  }
}
