import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../l10n/l_text.dart';
import '../l10n/strings.dart';
import '../models/breath_pattern.dart';
import '../models/technique.dart';
import '../services/ads_service.dart';
import '../services/audio_download_service.dart';
import '../services/breathing_clock.dart';
import '../services/challenge_service.dart';
import '../services/date_utils.dart';
import '../services/progress_store.dart';
import '../services/settings_controller.dart';
import '../services/voice_guide.dart';
import '../theme/app_colors.dart';
import '../widgets/breath_path_visual.dart';
import '../widgets/common.dart';
import '../widgets/glow.dart';
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
  late bool _hapticsOn;
  late final bool _gentle;
  bool _audioOn = false;
  AudioPlayer? _player;

  _Stage _stage = _Stage.preparing;
  double _prepElapsed = 0;
  Duration _lastTick = Duration.zero;
  int _lastSerial = -1;
  DateTime _startedAt = DateTime.now();
  bool _recorded = false;
  int _recordedSeconds = 0;

  BreathPattern get _pattern => _clock.pattern;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsController>();
    _voiceOn = settings.voiceGuidance;
    _hapticsOn = settings.haptics;
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
    _player?.dispose();
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
    if (_hapticsOn) HapticFeedback.selectionClick();
    if (_voiceOn) {
      final settings = context.read<SettingsController>();
      _voice.say(context.s.phaseCue(type), lang: context.lang, volume: settings.voiceVolume);
    }
  }

  void _pause() {
    setState(() => _stage = _Stage.paused);
    _voice.stop();
    _player?.pause();
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
    if (_audioOn) _player?.play();
  }

  Future<void> _toggleAudio() async {
    final s = context.s;
    if (_audioOn) {
      setState(() => _audioOn = false);
      await _player?.pause();
      return;
    }
    final path = context.read<AudioDownloadService>().localPath(widget.technique.id);
    if (path == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(s.audioGuideNotDownloaded)));
      return;
    }
    setState(() => _audioOn = true);
    try {
      final player = _player ??= AudioPlayer();
      if (player.audioSource == null) await player.setFilePath(path);
      if (_stage != _Stage.paused && _stage != _Stage.finished) unawaited(player.play());
    } catch (_) {
      if (mounted) setState(() => _audioOn = false);
    }
  }

  Future<void> _finish({required bool completed}) async {
    if (_stage == _Stage.finished) return;
    setState(() => _stage = _Stage.finished);
    _voice.stop();
    unawaited(_player?.stop());
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
      if (_hapticsOn) HapticFeedback.mediumImpact();
      if (_voiceOn) {
        _voice.say(
          context.s.sessionCompleteCue,
          lang: context.lang,
          volume: context.read<SettingsController>().voiceVolume,
        );
      }
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
          tint: Color.lerp(t.color, dark ? AppColors.night : AppColors.cream, dark ? 0.86 : 0.55),
          fireflies: true,
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
    final dark = context.isDark;
    final accent = accentOf(context);
    final preparing = _stage == _Stage.preparing;
    final paused = _stage == _Stage.paused;
    final prepCount = (_prepSeconds - _prepElapsed.floor()).clamp(1, _prepSeconds);
    final totalRounds = _clock.totalRounds ?? 1;
    final round = _clock.round.clamp(1, totalRounds);
    final visualColor = dark ? AppColors.mintDeep : AppColors.sageDark;

    final String label;
    final String counter;
    if (preparing) {
      label = s.getReady;
      counter = '$prepCount';
    } else {
      label = paused ? s.paused : s.phaseCue(_clock.phase.type);
      counter = '${_clock.phaseSecondsLeft}';
    }
    final patternText = _pattern.phases
        .map((p) => '${s.phaseName(p.type)} ${p.seconds}${s.secondsShort}')
        .join('  ·  ');

    return Column(
      key: const ValueKey('session'),
      children: [
        // Top bar: back + toggles
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 16, 0),
          child: Row(
            children: [
              IconButton(tooltip: s.endSession, onPressed: _endPressed, icon: const Icon(Icons.arrow_back_rounded)),
              const Spacer(),
              ToggleTile(
                icon: Icons.music_note_rounded,
                active: _audioOn,
                tooltip: _audioOn ? s.audioGuideOff : s.audioGuideOn,
                onTap: _toggleAudio,
              ),
              const SizedBox(width: 8),
              ToggleTile(
                icon: Icons.vibration_rounded,
                active: _hapticsOn,
                tooltip: _hapticsOn ? s.hapticsOff : s.hapticsOn,
                onTap: () => setState(() => _hapticsOn = !_hapticsOn),
              ),
              const SizedBox(width: 8),
              ToggleTile(
                icon: Icons.record_voice_over_rounded,
                active: _voiceOn,
                tooltip: _voiceOn ? s.voiceOff : s.voiceOn,
                onTap: () {
                  setState(() => _voiceOn = !_voiceOn);
                  if (!_voiceOn) _voice.stop();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(context.l(t.name), style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Overline(preparing ? s.getReady : s.roundOf(round, totalRounds)),
        const SizedBox(height: 10),
        SizedBox(
          width: 150,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _clock.sessionProgress,
              minHeight: 4,
              color: accent,
              backgroundColor: accent.withValues(alpha: 0.18),
            ),
          ),
        ),
        if (_gentle && t.pattern.hasHolds) ...[
          const SizedBox(height: 6),
          Text(s.gentleModeOn, style: theme.textTheme.labelSmall?.copyWith(color: context.softText)),
        ],
        // Shape tracer
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) {
              final size = (box.maxWidth * 0.86 < box.maxHeight ? box.maxWidth * 0.86 : box.maxHeight).clamp(
                120.0,
                380.0,
              );
              return Center(
                child: Semantics(
                  liveRegion: true,
                  label: label,
                  child: BreathPathVisual(
                    size: size,
                    pattern: _pattern,
                    phaseIndex: preparing ? 0 : _clock.phaseIndex,
                    phaseProgress: preparing ? 0 : _clock.phaseProgress,
                    expansion: preparing ? 0.1 + 0.1 * (_prepElapsed % 1) : _clock.expansion,
                    color: visualColor,
                  ),
                ),
              );
            },
          ),
        ),
        // Bottom panel
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: TintCard(
            tint: dark ? AppColors.forestSoft : AppColors.mint,
            strength: dark ? 1.4 : 1,
            radius: 28,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (c, a) => FadeTransition(
                    opacity: a,
                    child: SlideTransition(
                      position: Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(a),
                      child: c,
                    ),
                  ),
                  child: Overline(label, key: ValueKey(label), color: dark ? AppColors.cream : AppColors.forest),
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (c, a) => ScaleTransition(scale: Tween(begin: 0.8, end: 1.0).animate(a), child: c),
                  child: Text(
                    counter,
                    key: ValueKey(counter + label),
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      color: accent,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  patternText,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(color: context.softText),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Tooltip(
                          message: s.endSession,
                          child: TextButton.icon(
                            onPressed: _endPressed,
                            icon: const Icon(Icons.stop_rounded, size: 20),
                            label: Text(s.end),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: IconButton.filled(
                        tooltip: paused ? s.resume : s.pause,
                        iconSize: 32,
                        style: IconButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: dark ? AppColors.forest : Colors.white,
                        ),
                        onPressed: paused ? _resume : _pause,
                        icon: Icon(paused ? Icons.play_arrow_rounded : Icons.pause_rounded),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          s.timeLeft(formatClock(_clock.remainingSeconds)),
                          style: theme.textTheme.labelLarge?.copyWith(color: context.softText),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
          child: GlowOrb(
            size: 190,
            color: context.isDark ? AppColors.mintDeep : AppColors.sage,
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
        StatGrid(
          children: [
            StatTile(
              icon: Icons.local_fire_department_outlined,
              value: '${store.currentStreak}',
              label: s.dayStreak,
              color: AppColors.sun,
            ),
            StatTile(
              icon: Icons.today_rounded,
              value: s.durationText(store.secondsOn(today())),
              label: s.today,
              color: AppColors.mint,
            ),
          ],
        ),
        const SizedBox(height: 12),
        TintCard(
          tint: challenge.done ? AppColors.mintDeep : AppColors.sun,
          child: Row(
            children: [
              Icon(challenge.done ? Icons.emoji_events_rounded : challenge.def.icon),
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
