import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Optional spoken cues ("Breathe in", "Breathe out") using the device's
/// built-in text-to-speech engine, which works offline.
class VoiceGuide {
  static const _timeout = Duration(seconds: 2);

  FlutterTts? _tts;
  String? _configuredLang;
  double? _configuredVolume;

  Future<FlutterTts?> _engine(String lang, double volume) async {
    try {
      final tts = _tts ??= FlutterTts();
      if (_configuredLang != lang) {
        final code = lang == 'hi' ? 'hi-IN' : 'en-US';
        final ok = await tts.isLanguageAvailable(code).timeout(_timeout);
        await tts.setLanguage(ok == true ? code : 'en-US').timeout(_timeout);
        await tts.setSpeechRate(0.4).timeout(_timeout);
        await tts.setPitch(0.95).timeout(_timeout);
        _configuredLang = lang;
      }
      if (_configuredVolume != volume) {
        await tts.setVolume(volume).timeout(_timeout);
        _configuredVolume = volume;
      }
      return tts;
    } catch (e) {
      debugPrint('Voice guidance unavailable: $e');
      return null;
    }
  }

  Future<void> say(String text, {required String lang, double volume = 0.8}) async {
    final tts = await _engine(lang, volume);
    try {
      await tts?.stop().timeout(_timeout);
      await tts?.speak(text).timeout(_timeout);
    } catch (e) {
      debugPrint('Voice guidance failed: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _tts?.stop().timeout(_timeout);
    } catch (_) {}
  }
}
