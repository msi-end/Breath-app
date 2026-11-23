import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../l10n/l_text.dart';
import '../l10n/strings.dart';
import '../models/technique.dart';
import '../services/breathing_clock.dart';
import '../services/settings_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/audio_guidance_card.dart';
import '../widgets/breathing_visual.dart';
import '../widgets/common.dart';
import 'navigation.dart';

const sessionLengths = [1, 2, 3, 5, 10, 15];

class TechniqueDetailScreen extends StatefulWidget {
  const TechniqueDetailScreen({super.key, required this.technique});

  final Technique technique;

  @override
  State<TechniqueDetailScreen> createState() => _TechniqueDetailScreenState();
}

class _TechniqueDetailScreenState extends State<TechniqueDetailScreen> {
  late int _minutes = widget.technique.recommendedMinutes;
  late bool _gentle = context.read<SettingsController>().gentleModeDefault;

  @override
  Widget build(BuildContext context) {
    final t = widget.technique;
    final s = context.s;
    final theme = Theme.of(context);
    final dark = context.isDark;
    final lengths = {...sessionLengths, t.recommendedMinutes}.toList()..sort();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 300,
            backgroundColor: Color.lerp(t.color, dark ? AppColors.night : AppColors.cream, dark ? 0.75 : 0.35),
            actions: [FavoriteButton(techniqueId: t.id)],
            flexibleSpace: FlexibleSpaceBar(
              background: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.lerp(t.color, dark ? AppColors.night : Colors.white, dark ? 0.7 : 0.15)!,
                      dark ? AppColors.night : AppColors.cream,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: _PreviewLotus(technique: t, gentle: _gentle),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            sliver: SliverList.list(
              children: [
                Text(context.l(t.name), style: theme.textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(context.l(t.tagline), style: theme.textTheme.bodyLarge?.copyWith(color: context.softText)),
                const SizedBox(height: 14),
                PatternChips(_gentle ? t.pattern.withoutHolds() : t.pattern),
                const SizedBox(height: 18),
                Text(context.l(t.description), style: theme.textTheme.bodyLarge),
                SectionHeader(s.benefitsAndPurpose),
                SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l(t.purpose),
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      for (final b in t.benefits)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.eco_rounded, size: 18, color: dark ? AppColors.mintDeep : AppColors.sageDark),
                              const SizedBox(width: 10),
                              Expanded(child: Text(context.l(b), style: theme.textTheme.bodyMedium)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                SectionHeader(s.howToPerform),
                SoftCard(
                  child: Column(
                    children: [
                      for (var i = 0; i < t.steps.length; i++)
                        Padding(
                          padding: EdgeInsets.only(bottom: i == t.steps.length - 1 ? 0 : 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: t.color.withValues(alpha: dark ? 0.3 : 0.6),
                                child: Text(
                                  '${i + 1}',
                                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(context.l(t.steps[i]), style: theme.textTheme.bodyMedium)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (t.caution != null) ...[
                  const SizedBox(height: 14),
                  SoftCard(
                    color: dark ? const Color(0xFF26323A) : const Color(0xFFE8F3FA),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded),
                        const SizedBox(width: 12),
                        Expanded(child: Text(context.l(t.caution!), style: theme.textTheme.bodyMedium)),
                      ],
                    ),
                  ),
                ],
                SectionHeader(s.recommendedDuration),
                SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.recommendedMinutesText(t.recommendedMinutes), style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final m in lengths)
                            ChoiceChip(
                              label: Text(s.minutesShort(m)),
                              avatar: m == t.recommendedMinutes ? const Icon(Icons.star_rounded, size: 16) : null,
                              selected: _minutes == m,
                              onSelected: (_) => setState(() => _minutes = m),
                            ),
                        ],
                      ),
                      if (t.pattern.hasHolds) ...[
                        const SizedBox(height: 8),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(s.gentleMode),
                          subtitle: Text(s.gentleModeSub),
                          value: _gentle,
                          onChanged: (v) => setState(() => _gentle = v),
                        ),
                      ],
                    ],
                  ),
                ),
                SectionHeader(s.audioGuidance),
                AudioGuidanceCard(technique: t),
                const SizedBox(height: 16),
                Text(s.stopAnytime, style: theme.textTheme.bodySmall?.copyWith(color: context.softText)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: FilledButton.icon(
          onPressed: () => startSession(context, t, minutes: _minutes, gentle: _gentle),
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(s.startPractice),
        ),
      ),
    );
  }
}

/// Small looping preview of the technique's rhythm.
class _PreviewLotus extends StatefulWidget {
  const _PreviewLotus({required this.technique, required this.gentle});

  final Technique technique;
  final bool gentle;

  @override
  State<_PreviewLotus> createState() => _PreviewLotusState();
}

class _PreviewLotusState extends State<_PreviewLotus> with SingleTickerProviderStateMixin {
  late BreathingClock _clock;
  late final Ticker _ticker;
  Duration _last = Duration.zero;

  BreathingClock _makeClock() =>
      BreathingClock(widget.gentle ? widget.technique.pattern.withoutHolds() : widget.technique.pattern);

  @override
  void initState() {
    super.initState();
    _clock = _makeClock();
    _ticker = createTicker((d) {
      setState(() => _clock.advance((d - _last).inMicroseconds / 1e6));
      _last = d;
    })..start();
  }

  @override
  void didUpdateWidget(covariant _PreviewLotus old) {
    super.didUpdateWidget(old);
    if (old.gentle != widget.gentle) _clock = _makeClock();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BreathingVisual(
          size: 190,
          expansion: _clock.expansion,
          rotation: _clock.elapsed * 0.04,
          color: widget.technique.color,
          child: Icon(widget.technique.icon, color: AppColors.forest, size: 30),
        ),
        const SizedBox(height: 6),
        Text(s.phaseCue(_clock.phase.type), style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}
