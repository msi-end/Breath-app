import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Soft sky gradient with a gentle sun and rolling hills.
class NatureBackground extends StatelessWidget {
  const NatureBackground({super.key, required this.child, this.showHills = true, this.tint});

  final Widget child;
  final bool showHills;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return CustomPaint(
      painter: _NaturePainter(dark: dark, showHills: showHills, tint: tint),
      child: child,
    );
  }
}

class _NaturePainter extends CustomPainter {
  _NaturePainter({required this.dark, required this.showHills, this.tint});

  final bool dark;
  final bool showHills;
  final Color? tint;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final top = tint ?? (dark ? const Color(0xFF16261F) : const Color(0xFFE3F3EA));
    final bottom = dark ? AppColors.night : AppColors.cream;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
          stops: const [0, 0.55],
        ).createShader(rect),
    );

    // Sun / moon glow
    final sunCenter = Offset(size.width * 0.84, size.height * 0.06);
    final sunR = math.min(size.width, 420) * 0.22;
    canvas.drawCircle(
      sunCenter,
      sunR * 1.8,
      Paint()
        ..shader = RadialGradient(
          colors: [
            (dark ? AppColors.mintDeep : AppColors.sun).withValues(alpha: dark ? 0.10 : 0.45),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: sunCenter, radius: sunR * 1.8)),
    );
    canvas.drawCircle(
      sunCenter,
      sunR * 0.55,
      Paint()..color = (dark ? AppColors.cream : AppColors.sun).withValues(alpha: dark ? 0.10 : 0.55),
    );

    if (!showHills) return;
    final h = size.height;
    final w = size.width;
    final base = math.min(h * 0.32, 260.0);
    _hill(
      canvas,
      size,
      h - base * 0.95,
      base * 0.20,
      0.0,
      (dark ? AppColors.forestSoft : AppColors.mint).withValues(alpha: dark ? 0.18 : 0.55),
    );
    _hill(
      canvas,
      size,
      h - base * 0.62,
      base * 0.16,
      1.7,
      (dark ? AppColors.forestSoft : AppColors.mintDeep).withValues(alpha: dark ? 0.22 : 0.35),
    );
    _hill(
      canvas,
      size,
      h - base * 0.32,
      base * 0.12,
      3.1,
      (dark ? AppColors.forest : AppColors.sage).withValues(alpha: dark ? 0.35 : 0.22),
    );
    // A couple of tiny leaves floating near the top
    _leaf(
      canvas,
      Offset(w * 0.12, h * 0.16),
      10,
      -0.6,
      (dark ? AppColors.mintDeep : AppColors.sage).withValues(alpha: 0.25),
    );
    _leaf(
      canvas,
      Offset(w * 0.24, h * 0.09),
      7,
      0.5,
      (dark ? AppColors.mintDeep : AppColors.sage).withValues(alpha: 0.18),
    );
  }

  void _hill(Canvas canvas, Size size, double y, double amp, double phase, Color color) {
    final path = Path()..moveTo(0, size.height);
    for (double x = 0; x <= size.width; x += 6) {
      final t = x / size.width;
      path.lineTo(x, y + math.sin(t * math.pi * 1.6 + phase) * amp + math.sin(t * math.pi * 3.4 + phase) * amp * 0.25);
    }
    path
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _leaf(Canvas canvas, Offset c, double r, double angle, Color color) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(angle);
    final p = Path()
      ..moveTo(0, -r * 1.6)
      ..quadraticBezierTo(r, 0, 0, r * 1.6)
      ..quadraticBezierTo(-r, 0, 0, -r * 1.6);
    canvas.drawPath(p, Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _NaturePainter old) =>
      old.dark != dark || old.showHills != showHills || old.tint != tint;
}
