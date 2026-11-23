import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// True when the user asked the system to remove animations.
bool reduceMotion(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Keeps a looping controller running only while motion is allowed.
void syncLoop(BuildContext context, AnimationController c, {bool reverse = false}) {
  if (reduceMotion(context)) {
    if (c.isAnimating) c.stop();
  } else if (!c.isAnimating) {
    c.repeat(reverse: reverse);
  }
}

/// Accent used for overlines, counters and glows.
Color accentOf(BuildContext context) => context.isDark ? AppColors.mintDeep : AppColors.sageDark;

/// Small, letter-spaced, all-caps label ("FIND YOUR RHYTHM").
class Overline extends StatelessWidget {
  const Overline(this.text, {super.key, this.color, this.leading});

  final String text;
  final Color? color;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.6,
        color: color ?? accentOf(context),
      ),
    );
    if (leading == null) return label;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        leading!,
        const SizedBox(width: 10),
        Flexible(child: label),
      ],
    );
  }
}

/// Card tinted with a palette colour, with a soft border and press animation.
class TintCard extends StatefulWidget {
  const TintCard({
    super.key,
    required this.child,
    required this.tint,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22,
    this.strength = 1,
  });

  final Widget child;
  final Color tint;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double radius;

  /// Multiplies the tint opacity.
  final double strength;

  @override
  State<TintCard> createState() => _TintCardState();
}

class _TintCardState extends State<TintCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final base = dark ? AppColors.nightCard : Colors.white;
    final bg = Color.alphaBlend(widget.tint.withValues(alpha: (dark ? 0.16 : 0.30) * widget.strength), base);
    final border = widget.tint.withValues(alpha: dark ? 0.30 : 0.45);
    final radius = BorderRadius.circular(widget.radius);
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: radius,
          border: Border.all(color: border),
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

/// Round outlined icon button used in top bars.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({super.key, required this.icon, required this.onPressed, required this.tooltip});

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: (dark ? AppColors.nightCard : Colors.white).withValues(alpha: dark ? 0.8 : 0.85),
        shape: CircleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(dimension: 44, child: Icon(icon, size: 21)),
        ),
      ),
    );
  }
}

/// Rounded-square toggle (sound / vibration / voice) for the session top bar.
class ToggleTile extends StatelessWidget {
  const ToggleTile({super.key, required this.icon, required this.active, required this.onTap, required this.tooltip});

  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final accent = accentOf(context);
    return Tooltip(
      message: tooltip,
      child: Semantics(
        toggled: active,
        button: true,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: active
                ? accent.withValues(alpha: dark ? 0.22 : 0.18)
                : (dark ? Colors.white : AppColors.forest).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active ? accent.withValues(alpha: 0.7) : Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onTap,
              child: Icon(icon, size: 20, color: active ? accent : context.softText),
            ),
          ),
        ),
      ),
    );
  }
}

/// A glowing orb. With [expansion] it follows the breath; without it, it
/// gently pulses on its own.
class GlowOrb extends StatefulWidget {
  const GlowOrb({super.key, this.size = 120, this.color, this.expansion, this.child, this.rings = true});

  final double size;
  final Color? color;
  final double? expansion;
  final Widget? child;
  final bool rings;

  @override
  State<GlowOrb> createState() => _GlowOrbState();
}

class _GlowOrbState extends State<GlowOrb> with SingleTickerProviderStateMixin {
  AnimationController? _pulse;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant GlowOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (widget.expansion == null && _pulse == null) {
      _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 4), value: 0.5);
    } else if (widget.expansion != null && _pulse != null) {
      _pulse!.dispose();
      _pulse = null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_pulse != null) syncLoop(context, _pulse!, reverse: true);
  }

  @override
  void dispose() {
    _pulse?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.mintDeep;
    final dark = context.isDark;
    Widget paint(double e) => CustomPaint(
      painter: _OrbPainter(expansion: e, color: color, rings: widget.rings, dark: dark),
      child: SizedBox.square(
        dimension: widget.size,
        child: Center(child: widget.child),
      ),
    );
    final pulse = _pulse;
    if (pulse != null) syncLoop(context, pulse, reverse: true);
    if (pulse == null) return RepaintBoundary(child: paint(widget.expansion!.clamp(0.0, 1.0)));
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: pulse,
        builder: (_, _) => paint(0.25 + 0.5 * Curves.easeInOut.transform(pulse.value)),
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  _OrbPainter({required this.expansion, required this.color, required this.rings, required this.dark});

  final double expansion;
  final Color color;
  final bool rings;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final maxR = size.shortestSide / 2;
    final core = maxR * (0.30 + 0.28 * expansion);

    canvas.drawCircle(
      c,
      maxR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: dark ? 0.45 : 0.40),
            color.withValues(alpha: 0),
          ],
          stops: const [0.25, 1],
        ).createShader(Rect.fromCircle(center: c, radius: maxR)),
    );
    if (rings) {
      for (final (f, a) in [(1.55, 0.18), (1.28, 0.32)]) {
        canvas.drawCircle(
          c,
          math.min(core * f, maxR * 0.98),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6
            ..color = color.withValues(alpha: a),
        );
      }
    }
    canvas.drawCircle(
      c,
      core,
      Paint()
        ..color = color.withValues(alpha: 0.65)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, core * 0.35),
    );
    canvas.drawCircle(
      c,
      core * 0.86,
      Paint()
        ..shader = RadialGradient(colors: [Color.lerp(color, Colors.white, 0.75)!, color])
            .createShader(Rect.fromCircle(center: c, radius: core)),
    );
  }

  @override
  bool shouldRepaint(covariant _OrbPainter old) =>
      old.expansion != expansion || old.color != color || old.rings != rings || old.dark != dark;
}

/// Concentric glowing rings that slowly ripple outward.
class RippleRings extends StatefulWidget {
  const RippleRings({super.key, this.color, this.size = 260, this.count = 3, this.period = const Duration(seconds: 7)});

  final Color? color;
  final double size;
  final int count;
  final Duration period;

  @override
  State<RippleRings> createState() => _RippleRingsState();
}

class _RippleRingsState extends State<RippleRings> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.period, value: 0.3);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    syncLoop(context, _c);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? accentOf(context);
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, _) => CustomPaint(
            size: Size.square(widget.size),
            painter: _RipplePainter(t: _c.value, color: color, count: widget.count),
          ),
        ),
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  _RipplePainter({required this.t, required this.color, required this.count});

  final double t;
  final Color color;
  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final maxR = size.shortestSide / 2;
    for (var i = 0; i < count; i++) {
      final p = (t + i / count) % 1.0;
      final r = maxR * (0.35 + 0.65 * p);
      final a = math.sin(p * math.pi) * 0.55;
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..color = color.withValues(alpha: a * 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = color.withValues(alpha: a),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter old) => old.t != t || old.color != color;
}

/// Softly drifting, twinkling particles ("fireflies").
class Fireflies extends StatefulWidget {
  const Fireflies({super.key, this.color, this.count = 22});

  final Color? color;
  final int count;

  @override
  State<Fireflies> createState() => _FirefliesState();
}

class _FirefliesState extends State<Fireflies> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 30));
  late final List<_Fly> _flies = List.generate(widget.count, (i) => _Fly(math.Random(i * 7919 + 13)));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    syncLoop(context, _c);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? (context.isDark ? AppColors.mintDeep : Colors.white);
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, _) => CustomPaint(
            size: Size.infinite,
            painter: _FlyPainter(t: _c.value, flies: _flies, color: color, dark: context.isDark),
          ),
        ),
      ),
    );
  }
}

class _Fly {
  _Fly(math.Random r)
    : x = r.nextDouble(),
      y = r.nextDouble(),
      radius = 1.2 + r.nextDouble() * 2.2,
      speed = 0.5 + r.nextDouble(),
      phase = r.nextDouble() * math.pi * 2,
      drift = 0.02 + r.nextDouble() * 0.05;

  final double x, y, radius, speed, phase, drift;
}

class _FlyPainter extends CustomPainter {
  _FlyPainter({required this.t, required this.flies, required this.color, required this.dark});

  final double t;
  final List<_Fly> flies;
  final Color color;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final a = t * math.pi * 2;
    for (final f in flies) {
      final dx = math.sin(a * f.speed + f.phase) * f.drift;
      final dy = ((f.y - t * f.speed * 0.25) % 1.0 + 1) % 1.0;
      final p = Offset((f.x + dx) * size.width, dy * size.height);
      final twinkle = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(a * 6 * f.speed + f.phase));
      final alpha = (dark ? 0.75 : 0.9) * twinkle;
      canvas.drawCircle(
        p,
        f.radius * 3.2,
        Paint()
          ..color = color.withValues(alpha: alpha * 0.35)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, f.radius * 2.5),
      );
      canvas.drawCircle(p, f.radius, Paint()..color = color.withValues(alpha: alpha));
    }
  }

  @override
  bool shouldRepaint(covariant _FlyPainter old) => old.t != t || old.color != color;
}

/// Fades and slides its child in once, after [delay].
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({super.key, required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 550));
  late final Animation<double> _a = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (reduceMotion(context) || widget.delay == Duration.zero) {
      reduceMotion(context) ? _c.value = 1 : _c.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _a,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(_a),
        child: widget.child,
      ),
    );
  }
}
