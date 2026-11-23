import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l_text.dart';
import '../l10n/strings.dart';
import '../models/breath_pattern.dart';
import '../models/technique.dart';
import '../services/progress_store.dart';
import '../theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Semantics(header: true, child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
          ),
          if (action != null) TextButton(onPressed: onAction, child: Text(action!)),
        ],
      ),
    );
  }
}

/// The one card style: flat surface, hairline border, gentle press feedback.
class SoftCard extends StatefulWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(18),
    this.color,
    this.gradient,
    this.radius = 24,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final Color? color;
  final Gradient? gradient;
  final double radius;

  @override
  State<SoftCard> createState() => _SoftCardState();
}

class _SoftCardState extends State<SoftCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.radius);
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 120),
      child: Container(
        decoration: BoxDecoration(
          color: widget.gradient == null ? (widget.color ?? context.cardColor) : null,
          gradient: widget.gradient,
          borderRadius: radius,
          border: context.isDark && widget.gradient == null && widget.color == null
              ? Border.all(color: AppColors.nightLine)
              : null,
          boxShadow: context.isDark || widget.color != null
              ? null
              : [
                  BoxShadow(
                    color: AppColors.forest.withValues(alpha: 0.05),
                    blurRadius: 24,
                    spreadRadius: -10,
                    offset: const Offset(0, 10),
                  ),
                ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: widget.onTap,
            onHighlightChanged: widget.onTap == null ? null : (v) => setState(() => _pressed = v),
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ),
      ),
    );
  }
}

/// Round icon badge on a soft pastel.
class IconBadge extends StatelessWidget {
  const IconBadge(this.icon, {super.key, required this.color, this.size = 48});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: dark ? color.withValues(alpha: 0.22) : Color.alphaBlend(color.withValues(alpha: 0.5), Colors.white),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: size * 0.48, color: dark ? AppColors.cream : AppColors.forest),
    );
  }
}

/// Pastel background used by tiles (mood, stats, quick actions).
Color pastelOf(BuildContext context, Color c) => context.isDark
    ? Color.alphaBlend(c.withValues(alpha: 0.14), AppColors.nightCard)
    : Color.alphaBlend(c.withValues(alpha: 0.38), Colors.white);

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.techniqueId});

  final String techniqueId;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ProgressStore>();
    final fav = store.isFavorite(techniqueId);
    final s = context.s;
    return IconButton(
      tooltip: fav ? s.removeFavorite : s.addFavorite,
      onPressed: () {
        store.toggleFavorite(techniqueId);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(fav ? s.removedFromFavorites : s.addedToFavorites),
              duration: const Duration(seconds: 2),
            ),
          );
      },
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
        child: Icon(
          fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          key: ValueKey(fav),
          color: fav ? const Color(0xFFD9695F) : null,
        ),
      ),
    );
  }
}

/// "In 4 · Hold 4 · Out 4" chips describing a rhythm.
class PatternChips extends StatelessWidget {
  const PatternChips(this.pattern, {super.key, this.dense = false});

  final BreathPattern pattern;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final p in pattern.phases)
          Container(
            padding: EdgeInsets.symmetric(horizontal: dense ? 10 : 12, vertical: dense ? 4 : 6),
            decoration: BoxDecoration(
              color: (p.isHold ? AppColors.sky : AppColors.mint).withValues(alpha: context.isDark ? 0.18 : 0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${s.phaseShort(p.type)} ${p.seconds}${s.secondsShort}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

/// Small vertical bar chart.
class MiniBarChart extends StatelessWidget {
  const MiniBarChart({
    super.key,
    required this.values,
    required this.labels,
    this.height = 90,
    this.highlightLast = true,
    this.barColor,
  });

  final List<int> values;
  final List<String> labels;
  final double height;
  final bool highlightLast;
  final Color? barColor;

  @override
  Widget build(BuildContext context) {
    final maxV = values.fold<int>(0, (m, v) => v > m ? v : m);
    final dark = context.isDark;
    final base = barColor ?? (dark ? AppColors.mintDeep : AppColors.sage);
    return SizedBox(
      height: height + 22,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: maxV == 0 ? 0 : values[i] / maxV),
                      duration: Duration(milliseconds: 500 + i * 60),
                      curve: Curves.easeOutCubic,
                      builder: (context, f, _) => Container(
                        height: 6 + (height - 6) * f,
                        decoration: BoxDecoration(
                          color: values[i] == 0
                              ? base.withValues(alpha: 0.18)
                              : (highlightLast && i == values.length - 1
                                    ? (dark ? AppColors.sky : AppColors.forestSoft)
                                    : base),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      labels[i],
                      maxLines: 1,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.softText),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.icon, required this.value, required this.label, this.color});

  final IconData icon;
  final String value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? AppColors.mint;
    return SoftCard(
      color: pastelOf(context, c),
      radius: 26,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.isDark ? c.withValues(alpha: 0.22) : Colors.white.withValues(alpha: 0.75),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20),
          ),
          const SizedBox(height: 14),
          Text(value, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: context.softText)),
        ],
      ),
    );
  }
}

/// Tall gradient card for a technique, with a quick-start play button.
class TechniqueTile extends StatelessWidget {
  const TechniqueTile({super.key, required this.technique, required this.onTap, required this.onPlay, this.width});

  final Technique technique;
  final VoidCallback onTap;
  final VoidCallback onPlay;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final t = technique;
    final s = context.s;
    final theme = Theme.of(context);
    final dark = context.isDark;
    final top = dark ? Color.lerp(t.color, AppColors.night, 0.55)! : Color.lerp(t.color, Colors.white, 0.45)!;
    final bottom = dark ? Color.lerp(t.color, AppColors.night, 0.75)! : t.color;
    final fg = dark ? AppColors.cream : AppColors.forest;
    return SizedBox(
      width: width,
      child: SoftCard(
        padding: EdgeInsets.zero,
        radius: 26,
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [top, bottom]),
        onTap: onTap,
        child: Stack(
          children: [
            Positioned(right: -18, top: -14, child: Icon(t.icon, size: 110, color: fg.withValues(alpha: 0.07))),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: dark ? 0.1 : 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(t.icon, size: 22, color: fg),
                      ),
                      const Spacer(),
                      if (context.watch<ProgressStore>().isFavorite(t.id))
                        Icon(Icons.favorite_rounded, size: 18, color: dark ? AppColors.blush : const Color(0xFFD9695F)),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    context.l(t.name),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(color: fg, height: 1.2),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.minutesCount(t.recommendedMinutes),
                          style: theme.textTheme.labelMedium?.copyWith(color: fg.withValues(alpha: 0.7)),
                        ),
                      ),
                      Material(
                        color: dark ? AppColors.mintDeep : AppColors.forest,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: onPlay,
                          child: Tooltip(
                            message: s.startBreathing,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.play_arrow_rounded,
                                size: 20,
                                color: dark ? AppColors.forest : AppColors.cream,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Two-column grid whose rows size to their content (no fixed aspect ratio,
/// so large accessibility font sizes never overflow).
class StatGrid extends StatelessWidget {
  const StatGrid({super.key, required this.children, this.spacing = 12});

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 2) {
      if (i > 0) rows.add(SizedBox(height: spacing));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: children[i]),
              SizedBox(width: spacing),
              Expanded(child: i + 1 < children.length ? children[i + 1] : const SizedBox()),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

/// Weekday initials for the last [n] days ending today.
List<String> lastDayLabels(BuildContext context, int n) {
  final narrow = MaterialLocalizations.of(context).narrowWeekdays; // Sunday first
  final now = DateTime.now();
  return [for (var i = n - 1; i >= 0; i--) narrow[DateTime(now.year, now.month, now.day - i).weekday % 7]];
}
