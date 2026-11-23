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
import '../services/audio_download_service.dart';
import '../services/breathing_clock.dart';
import '../services/challenge_service.dart';
import '../services/date_utils.dart';
import '../services/music_player.dart';
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
  late final MusicPlayer _music;

  bool get _guideActive =>
      _audioOn && _music.isLoaded && _music.isCurrent('${MusicPlayer.guidancePrefix}${widget.technique.id}');

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
    _music = context.read<MusicPlayer>();
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
    if (_guideActive) unawaited(_music.pause());
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
    if (_guideActive) unawaited(_music.pause());
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
    if (_guideActive && !_music.isPlaying) unawaited(_music.togglePlay());
  }

  Future<void> _toggleAudio() async {
    final s = context.s;
    if (_audioOn) {
      if (_guideActive) await _music.pause();
      setState(() => _audioOn = false);
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
    await _music.playGuidance(techniqueId: widget.technique.id, title: context.l(widget.technique.name), path: path);
    if (_stage == _Stage.paused || _stage == _Stage.finished) await _music.pause();
    if (mounted && _music.error != null) setState(() => _audioOn = false);
  }

  Future<void> _finish({required bool completed}) async {
    if (_stage == _Stage.finished) return;
    setState(() => _stage = _Stage.finished);
    _voice.stop();
    if (_guideActive) unawaited(_music.pause());
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
          tint: Color.lerp(t.color, dark ? AppColors.night : AppColors.cream, dark ? 0.88 : 0.7),
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

    final String label;
    final String counter;
    if (preparing) {
      label = s.getReady;
      counter = '$prepCount';
    } else {
      label = paused ? s.paused : s.phaseCue(_clock.phase.type);
      counter = '${_clock.phaseSecondsLeft}';
    }
    final patternText = _pattern.phases.map((p) => '${s.phaseName(p.type)} ${p.seconds}').join(' · ');

    Widget toggle(IconData on, IconData off, bool active, String tip, VoidCallback onTap) => IconButton(
      tooltip: tip,
      isSelected: active,
      onPressed: onTap,
      icon: Icon(active ? on : off, color: active ? accent : context.softText),
    );

    return Column(
      key: const ValueKey('session'),
      children: [
        // Minimal top bar
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
          child: Row(
            children: [
              IconButton(tooltip: s.endSession, onPressed: _endPressed, icon: const Icon(Icons.close_rounded)),
              const Spacer(),
              toggle(
                Icons.music_note_rounded,
                Icons.music_off_rounded,
                _audioOn,
                _audioOn ? s.audioGuideOff : s.audioGuideOn,
                _toggleAudio,
              ),
              toggle(
                Icons.vibration_rounded,
                Icons.mobile_off_rounded,
                _hapticsOn,
                _hapticsOn ? s.hapticsOff : s.hapticsOn,
                () => setState(() => _hapticsOn = !_hapticsOn),
              ),
              toggle(
                Icons.record_voice_over_rounded,
                Icons.voice_over_off_rounded,
                _voiceOn,
                _voiceOn ? s.voiceOff : s.voiceOn,
                () {
                  setState(() => _voiceOn = !_voiceOn);
                  if (!_voiceOn) _voice.stop();
                },
              ),
            ],
          ),
        ),
        Text(context.l(t.name), style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
        const SizedBox(height: 2),
        Text(
          preparing
              ? ' '
              : s.roundOf(round, totalRounds) + (_gentle && t.pattern.hasHolds ? ' · ${s.gentleModeOn}' : ''),
          style: theme.textTheme.bodySmall?.copyWith(color: context.softText),
        ),
        // The guide
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) {
              final size = (box.maxWidth * 0.82 < box.maxHeight ? box.maxWidth * 0.82 : box.maxHeight).clamp(
                120.0,
                360.0,
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
                    expansion: preparing ? 0.1 : _clock.expansion,
                    color: dark ? AppColors.mintDeep : AppColors.sageDark,
                  ),
                ),
              );
            },
          ),
        ),
        // Phase + count
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(label, key: ValueKey(label), style: theme.textTheme.headlineMedium),
        ),
        Text(
          counter,
          style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700, color: accent, height: 1.15),
        ),
        Text(patternText, style: theme.textTheme.bodySmall?.copyWith(color: context.softText)),
        const SizedBox(height: 22),
        SizedBox.square(
          dimension: 68,
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
        const SizedBox(height: 4),
        TextButton(onPressed: _endPressed, child: Text(s.endSession)),
        // Session progress
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _clock.sessionProgress,
                    minHeight: 4,
                    color: accent,
                    backgroundColor: accent.withValues(alpha: 0.16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                formatClock(_clock.remainingSeconds),
                style: theme.textTheme.labelMedium?.copyWith(color: context.softText),
              ),
            ],
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
        SoftCard(
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
