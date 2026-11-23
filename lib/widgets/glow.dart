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
