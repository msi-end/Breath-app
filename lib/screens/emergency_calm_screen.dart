import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../data/techniques.dart';
import '../l10n/l_text.dart';
import '../l10n/strings.dart';
import '../models/breath_pattern.dart';
import '../services/ads_service.dart';
import '../services/breathing_clock.dart';
import '../services/date_utils.dart';
import '../services/progress_store.dart';
import '../services/settings_controller.dart';
import '../services/voice_guide.dart';
import '../theme/app_colors.dart';
import '../widgets/glow.dart';
import '../widgets/nature_background.dart';

/// Immediate, simple, hold-free breathing. Works offline and never shows ads.
class EmergencyCalmScreen extends StatefulWidget {
  const EmergencyCalmScreen({super.key});

  @override
  State<EmergencyCalmScreen> createState() => _EmergencyCalmScreenState();
}

class _EmergencyCalmScreenState extends State<EmergencyCalmScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const _shorterPattern = BreathPattern([BreathPhase(PhaseType.inhale, 3), BreathPhase(PhaseType.exhale, 4)]);

  final _clock = BreathingClock(calmModeTechnique.pattern);
  late final Ticker _ticker;
  final _voice = VoiceGuide();
  late bool _voiceOn;
  final _startedAt = DateTime.now();
  Duration _last = Duration.zero;
  double _total = 0;
  int _lastSerial = -1;
  int _messageIndex = 0;
  Timer? _messageTimer;
  bool _shorter = false;
  bool _stopped = false;

  @override
  void initState() {
    super.initState();
    AdsService.instance.suppress();
    _voiceOn = context.read<SettingsController>().voiceGuidance;
    _ticker = createTicker(_onTick)..start();
    WidgetsBinding.instance.addObserver(this);
    _messageTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      if (mounted) setState(() => _messageIndex++);
    });
    unawaited(WakelockPlus.enable().catchError((_) {}));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _messageTimer?.cancel();
    _voice.stop();
    AdsService.instance.release();
    unawaited(WakelockPlus.disable().catchError((_) {}));
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) _voice.stop();
  }

  void _onTick(Duration now) {
    final dt = ((now - _last).inMicroseconds / 1e6).clamp(0.0, 0.25);
    _last = now;
    _clock.advance(dt);
    _total += dt;
    final serial = _clock.phaseSerial;
    if (serial != _lastSerial) {
      _lastSerial = serial;
      final settings = context.read<SettingsController>();
      if (settings.haptics) HapticFeedback.selectionClick();
      if (_voiceOn) _voice.say(context.s.phaseCue(_clock.phase.type), lang: context.lang, volume: settings.voiceVolume);
    }
    setState(() {});
  }

  Future<void> _stop() async {
    if (_stopped) return;
    // Rebuild with canPop: true first, so our own pop isn't blocked.
    setState(() => _stopped = true);
    _ticker.stop();
    unawaited(_voice.stop());
    final s = context.s;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await context.read<ProgressStore>().addSession(
      techniqueId: calmModeTechnique.id,
      startedAt: _startedAt,
      durationSeconds: _total.round(),
      completed: true,
    );
    await SchedulerBinding.instance.endOfFrame;
    if (!mounted) return;
    navigator.pop();
    messenger.showSnackBar(SnackBar(content: Text(s.calmStoppedMessage)));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final dark = context.isDark;
    final messages = s.calmMessages;

    return PopScope(
      canPop: _stopped,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _stop();
      },
      child: Scaffold(
        body: NatureBackground(
          tint: dark ? const Color(0xFF10222A) : const Color(0xFFDDEFF3),
          fireflies: true,
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
                  child: Row(
                    children: [
                      Expanded(child: Text(s.emergencyCalm, style: theme.textTheme.titleMedium)),
                      IconButton(
                        tooltip: _voiceOn ? s.voiceOff : s.voiceOn,
                        onPressed: () {
                          setState(() => _voiceOn = !_voiceOn);
                          if (!_voiceOn) _voice.stop();
                        },
                        icon: Icon(_voiceOn ? Icons.record_voice_over_rounded : Icons.voice_over_off_rounded),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: SizedBox(
                    height: 64,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 800),
                      child: Text(
                        messages[_messageIndex % messages.length],
                        key: ValueKey(_messageIndex % messages.length),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(color: context.softText, height: 1.4),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, box) {
                      final visual =
                          (box.maxWidth * 0.9 < box.maxHeight - 110 ? box.maxWidth * 0.9 : box.maxHeight - 110).clamp(
                            120.0,
                            400.0,
                          );
                      return Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            width: box.maxWidth,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Semantics(
                                  liveRegion: true,
                                  label: s.phaseCue(_clock.phase.type),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      RippleRings(size: visual, color: dark ? AppColors.sky : AppColors.skyDeep),
                                      GlowOrb(
                                        size: visual * 0.92,
                                        expansion: _clock.expansion,
                                        color: dark ? AppColors.sky : AppColors.skyDeep,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  child: Text(
                                    s.phaseCue(_clock.phase.type),
                                    key: ValueKey(_clock.phase.type),
                                    style: theme.textTheme.headlineLarge,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  formatClock(_total.floor()),
                                  style: theme.textTheme.labelLarge?.copyWith(color: context.softText),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                FilterChip(
                  label: Text(s.shorterBreaths),
                  selected: _shorter,
                  onSelected: (v) => setState(() {
                    _shorter = v;
                    _clock.changePattern(v ? _shorterPattern : calmModeTechnique.pattern);
                    _lastSerial = -1;
                  }),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(minimumSize: const Size(64, 58)),
                      onPressed: _stop,
                      icon: const Icon(Icons.stop_rounded),
                      label: Text(s.stop),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: dark ? const Color(0xFF2B2A33) : const Color(0xFFFCE9E1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.medical_services_outlined, size: 20),
                        const SizedBox(width: 10),
                        Expanded(child: Text(s.medicalDisclaimer, style: theme.textTheme.bodySmall)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
