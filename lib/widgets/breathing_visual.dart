import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A lotus of leaves inside soft rings that grows on the in-breath and
/// softens on the out-breath. [expansion] runs from 0 (empty) to 1 (full).
class BreathingVisual extends StatelessWidget {
  const BreathingVisual({
    super.key,
    required this.expansion,
    required this.color,
    this.rotation = 0,
    this.child,
    this.size = 300,
  });

  final double expansion;
  final double rotation;
  final Color color;
  final Widget? child;
  final double size;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _LotusPainter(expansion: expansion, color: color, rotation: rotation, dark: dark),
        child: Center(child: child),
      ),
    );
  }
}

class _LotusPainter extends CustomPainter {
  _LotusPainter({required this.expansion, required this.color, required this.rotation, required this.dark});

  final double expansion;
  final double rotation;
  final Color color;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final maxR = size.shortestSide / 2;
    final e = expansion.clamp(0.0, 1.0);
    final r = maxR * (0.46 + 0.50 * e);

    // Halo
    canvas.drawCircle(
      c,
      r * 1.08,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: dark ? 0.30 : 0.38),
            color.withValues(alpha: 0),
          ],
          stops: const [0.55, 1],
        ).createShader(Rect.fromCircle(center: c, radius: r * 1.08)),
    );

    // Rings
    for (final (f, a) in [(0.98, 0.10), (0.84, 0.14), (0.70, 0.20)]) {
      canvas.drawCircle(c, r * f, Paint()..color = color.withValues(alpha: a + (dark ? 0.02 : 0)));
      canvas.drawCircle(
        c,
        r * f,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = color.withValues(alpha: 0.35),
      );
    }

    // Petals
    const petals = 8;
    final petalLen = r * (0.55 + 0.30 * e);
    final petalWidth = r * 0.22;
    final petalPaint = Paint()..color = color.withValues(alpha: dark ? 0.42 : 0.34);
    final veinPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: dark ? 0.18 : 0.45);
    for (var i = 0; i < petals; i++) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(rotation + i * 2 * math.pi / petals);
      final p = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(petalWidth, -petalLen * 0.5, 0, -petalLen)
        ..quadraticBezierTo(-petalWidth, -petalLen * 0.5, 0, 0);
      canvas.drawPath(p, petalPaint);
      canvas.drawLine(Offset.zero, Offset(0, -petalLen * 0.85), veinPaint);
      canvas.restore();
    }

    // Core
    final coreR = r * 0.42;
    canvas.drawCircle(
      c,
      coreR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: dark ? 0.30 : 0.95),
            Color.lerp(color, Colors.white, 0.35)!.withValues(alpha: dark ? 0.55 : 0.9),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: coreR)),
    );
  }

  @override
  bool shouldRepaint(covariant _LotusPainter old) =>
      old.expansion != expansion || old.rotation != rotation || old.color != color || old.dark != dark;
}
