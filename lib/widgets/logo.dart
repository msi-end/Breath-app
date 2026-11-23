import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// BreatheCare mark: a leaf carrying a breath wave, inside glowing ripples.
class BreatheCareLogo extends StatelessWidget {
  const BreatheCareLogo({super.key, this.size = 32, this.tile = false});

  final double size;

  /// Draw on a rounded forest tile (app-icon style).
  final bool tile;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'BreatheCare',
      image: true,
      child: CustomPaint(
        size: Size.square(size),
        painter: LogoPainter(tile: tile, dark: context.isDark),
      ),
    );
  }
}

class LogoPainter extends CustomPainter {
  LogoPainter({required this.tile, required this.dark});

  final bool tile;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final c = size.center(Offset.zero);
    final onTile = tile || dark;
    final ring = onTile ? AppColors.mintDeep : AppColors.sageDark;
    if (tile) {
      final rr = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(s * 0.26));
      canvas.drawRRect(
        rr,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2E5A3E), AppColors.forest, Color(0xFF15291D)],
          ).createShader(Offset.zero & size),
      );
    }
    // Ripples
    final outer = s * (tile ? 0.36 : 0.47);
    canvas.drawCircle(
      c,
      outer,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.035
        ..color = ring.withValues(alpha: 0.45)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.02),
    );
    canvas.drawCircle(
      c,
      outer,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.03
        ..color = ring,
    );
    canvas.drawCircle(
      c,
      outer * 0.78,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.018
        ..color = ring.withValues(alpha: 0.45),
    );

    // Leaf (pointed oval, tilted 45°)
    final len = outer * 1.18;
    final w = len * 0.42;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-math.pi / 4);
    final leaf = Path()
      ..moveTo(-len / 2, 0)
      ..quadraticBezierTo(0, -w, len / 2, 0)
      ..quadraticBezierTo(0, w, -len / 2, 0)
      ..close();
    canvas.drawPath(
      leaf,
      Paint()
        ..shader = LinearGradient(
          colors: [onTile ? AppColors.mint : AppColors.mintDeep, onTile ? AppColors.mintDeep : AppColors.sage],
        ).createShader(Rect.fromCenter(center: Offset.zero, width: len, height: w)),
    );
    // Breath wave as the leaf's vein
    final wave = Path()..moveTo(-len * 0.38, 0);
    for (var i = 0; i <= 40; i++) {
      final t = i / 40;
      final x = -len * 0.38 + t * len * 0.76;
      wave.lineTo(x, math.sin(t * math.pi * 2) * w * 0.16);
    }
    canvas.drawPath(
      wave,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.03
        ..strokeCap = StrokeCap.round
        ..color = onTile ? AppColors.forest : AppColors.cream,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LogoPainter old) => old.tile != tile || old.dark != dark;
}
