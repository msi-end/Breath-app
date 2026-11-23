import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../l10n/l_text.dart';
import '../l10n/strings.dart';
import '../models/breath_pattern.dart';
import '../models/technique.dart';
import '../services/ads_service.dart';
import '../services/breathing_clock.dart';
import '../services/challenge_service.dart';
import '../services/date_utils.dart';
import '../services/progress_store.dart';
import '../services/settings_controller.dart';
import '../services/voice_guide.dart';
import '../theme/app_colors.dart';
import '../widgets/breathing_visual.dart';
import '../widgets/common.dart';
import '../widgets/nature_background.dart';

enum _Stage { preparing, running, paused, finished }

/// Distraction-free guided session. No advertisements are ever shown here.
class BreathingSessionScreen extends StatefulWidget {
  const BreathingSessionScreen({super.key, required this.technique, required this.minutes, this.gentle});

  final Technique technique;
  final int minutes;

  /// Remove breath holds. Defaults to the user's setting.
  final bool? gentle;

  @override
  State<BreathingSessionScreen> createState() => _BreathingSessionScreenState();
}

class _BreathingSessionScreenState extends State<BreathingSessionScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const _prepSeconds = 3;

  late final BreathingClock _clock;
  late final Ticker _ticker;
  final _voice = VoiceGuide();
  late bool _voiceOn;
  late final bool _gentle;

  _Stage _stage = _Stage.preparing;
  double _prepElapsed = 0;
  Duration _lastTick = Duration.zero;
  int _lastSerial = -1;
  DateTime _startedAt = DateTime.now();
  bool _recorded = false;
  int _recordedSeconds = 0;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsController>();
    _voiceOn = settings.voiceGuidance;
    _gentle = widget.gentle ?? settings.gentleModeDefault;
    final pattern = _gentle ? widget.technique.pattern.withoutHolds() : widget.technique.pattern;
    _clock = BreathingClock(pattern, targetSeconds: widget.minutes * 60);
    _ticker = createTicker(_onTick)..start();
    WidgetsBinding.instance.addObserver(this);
    AdsService.instance.suppress();
    _keepAwake(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _voice.stop();
    AdsService.instance.release();
    _keepAwake(false);
    super.dispose();
  }

  void _keepAwake(bool on) {
    // The screen stays on during a session; failures are harmless.
    unawaited((on ? WakelockPlus.enable() : WakelockPlus.disable()).catchError((_) {}));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      if (_stage == _Stage.running || _stage == _Stage.preparing) _pause();
    }
  }

  void _onTick(Duration now) {
    final dt = (now - _lastTick).inMicroseconds / 1e6;
    _lastTick = now;
    if (_stage == _Stage.preparing) {
      _prepElapsed += dt.clamp(0.0, 0.25);
      if (_prepElapsed >= _prepSeconds) {
        _stage = _Stage.running;
        _startedAt = DateTime.now();
      }
      setState(() {});
      return;
    }
    if (_stage != _Stage.running) return;
    _clock.advance(dt);
    final serial = _clock.phaseSerial;
    if (serial != _lastSerial) {
      _lastSerial = serial;
      _onPhaseChange(_clock.phase.type);
    }
    if (_clock.isFinished) {
      _finish(completed: true);
      return;
    }
    setState(() {});
  }

  void _onPhaseChange(PhaseType type) {
    final settings = context.read<SettingsController>();
    if (settings.haptics) HapticFeedback.selectionClick();
    if (_voiceOn) {
      _voice.say(context.s.phaseCue(type), lang: context.lang, volume: settings.voiceVolume);
    }
  }

  void _pause() {
    setState(() => _stage = _Stage.paused);
    _voice.stop();
  }

  void _resume() {
    setState(() {
      _stage = _clock.elapsed == 0 ? _Stage.preparing : _Stage.running;
      if (_stage == _Stage.preparing) {
        _prepElapsed = 0;
      } else {
        // Re-announce the current phase on resume.
        _lastSerial = -1;
      }
    });
  }

  Future<void> _finish({required bool completed}) async {
    if (_stage == _Stage.finished) return;
    setState(() => _stage = _Stage.finished);
    _voice.stop();
    _keepAwake(false);
    final seconds = _clock.elapsed.round();
    if (!_recorded) {
      _recorded = true;
      final record = await context.read<ProgressStore>().addSession(
        techniqueId: widget.technique.id,
        startedAt: _startedAt,
        durationSeconds: seconds,
        completed: completed,
      );
      _recordedSeconds = record?.durationSeconds ?? 0;
      if (mounted) setState(() {});
    }
    if (completed && mounted) {
      final settings = context.read<SettingsController>();
      if (settings.haptics) HapticFeedback.mediumImpact();
      if (_voiceOn) _voice.say(context.s.sessionCompleteCue, lang: context.lang, volume: settings.voiceVolume);
    }
  }

  void _endPressed() {
    if (_clock.elapsed < 1) {
      Navigator.of(context).pop();
      return;
    }
    _finish(completed: false);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.technique;
    final dark = context.isDark;
    return PopScope(
      canPop: _stage == _Stage.finished || _clock.elapsed < 1,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _finish(completed: false);
      },
      child: Scaffold(
        body: NatureBackground(
          tint: Color.lerp(t.color, dark ? AppColors.night : AppColors.cream, dark ? 0.82 : 0.5),
          child: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _stage == _Stage.finished ? _buildSummary(context) : _buildSession(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSession(BuildContext context) {
    final s = context.s;
    final t = widget.technique;
    final theme = Theme.of(context);
    final preparing = _stage == _Stage.preparing;
    final paused = _stage == _Stage.paused;
    final prepCount = (_prepSeconds - _prepElapsed.floor()).clamp(1, _prepSeconds);

    final String label;
    final String counter;
    if (preparing) {
      label = s.getComfortable;
      counter = '$prepCount';
    } else {
      label = paused ? s.paused : s.phaseCue(_clock.phase.type);
      counter = '${_clock.phaseSecondsLeft}';
    }

    return Column(
      key: const ValueKey('session'),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
          child: Row(
            children: [
              IconButton(tooltip: s.endSession, onPressed: _endPressed, icon: const Icon(Icons.close_rounded)),
              Expanded(
                child: Column(
                  children: [
                    Text(context.l(t.name), style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
                    if (_gentle && t.pattern.hasHolds)
                      Text(s.gentleModeOn, style: theme.textTheme.labelSmall?.copyWith(color: context.softText)),
                  ],
                ),
              ),
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
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) {
              final visualSize = (box.maxWidth * 0.86 < box.maxHeight - 150 ? box.maxWidth * 0.86 : box.maxHeight - 150)
                  .clamp(120.0, 380.0);
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
                          label: label,
                          child: BreathingVisual(
                            size: visualSize,
                            expansion: preparing ? 0.15 + 0.1 * (_prepElapsed % 1) : _clock.expansion,
                            rotation: _clock.elapsed * 0.05,
                            color: t.color,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  counter,
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.forest,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          child: Text(label, key: ValueKey(label), style: theme.textTheme.headlineMedium),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            preparing ? s.prepHint : s.followAtYourPace,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(color: context.softText),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(value: _clock.sessionProgress, minHeight: 6),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(formatClock(_clock.elapsed.floor()), style: theme.textTheme.labelLarge),
                  const Spacer(),
                  Text(s.timeLeft(formatClock(_clock.remainingSeconds)), style: theme.textTheme.labelLarge),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 76,
              height: 76,
              child: IconButton.filled(
                tooltip: paused ? s.resume : s.pause,
                iconSize: 38,
                onPressed: paused ? _resume : _pause,
                icon: Icon(paused ? Icons.play_arrow_rounded : Icons.pause_rounded),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: _endPressed,
          icon: const Icon(Icons.stop_circle_outlined),
          label: Text(s.endSession),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSummary(BuildContext context) {
    final s = context.s;
    final t = widget.technique;
    final theme = Theme.of(context);
    final store = context.watch<ProgressStore>();
    final challenge = ChallengeService.todayProgress(store.sessions);
    final tooShort = _recorded && _recordedSeconds == 0;
    return ListView(
      key: const ValueKey('summary'),
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      children: [
        Center(
          child: BreathingVisual(
            size: 180,
            expansion: 0.65,
            color: t.color,
            child: const Icon(Icons.check_rounded, size: 46, color: AppColors.forest),
          ),
        ),
        const SizedBox(height: 18),
        Text(s.wellDone, textAlign: TextAlign.center, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(
          tooShort ? s.sessionTooShort : s.sessionSummary(s.durationText(_clock.elapsed.round()), context.l(t.name)),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(color: context.softText),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: StatTile(
                icon: Icons.local_fire_department_outlined,
                value: '${store.currentStreak}',
                label: s.dayStreak,
                color: AppColors.sun,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatTile(
                icon: Icons.today_rounded,
                value: s.durationText(store.secondsOn(today())),
                label: s.today,
                color: AppColors.mint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SoftCard(
          child: Row(
            children: [
              Icon(
                challenge.done ? Icons.emoji_events_rounded : challenge.def.icon,
                color: challenge.done ? const Color(0xFFE0A84F) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l(challenge.def.title), style: theme.textTheme.titleSmall),
                    Text(
                      challenge.done ? s.challengeCompleted : s.challengeKeepGoing,
                      style: theme.textTheme.bodySmall?.copyWith(color: context.softText),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        FilledButton(onPressed: () => Navigator.of(context).pop(), child: Text(s.done)),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => BreathingSessionScreen(technique: t, minutes: widget.minutes, gentle: _gentle),
              ),
            );
          },
          icon: const Icon(Icons.replay_rounded),
          label: Text(s.practiceAgain),
        ),
      ],
    );
  }
}
