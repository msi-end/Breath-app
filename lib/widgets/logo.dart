import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// BreatheCare mark: a five-petal lotus under a rising "breath" sun, resting
/// on two calm water lines.
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
  LogoPainter({
    required this.tile,
    required this.dark,
    this.cornerRadius = 0.26,
    this.contentScale = 1,
    this.background = true,
  });

  final bool tile;
  final bool dark;

  /// Tile corner radius as a fraction of the size (0 = square, for stores).
  final double cornerRadius;

  /// Shrinks the mark inside the tile (adaptive-icon safe zone).
  final double contentScale;

  /// Paint the tile background (false = transparent foreground layer).
  final bool background;

  static const tileTop = Color(0xFF2F6650);
  static const tileMid = AppColors.forest;
  static const tileBottom = Color(0xFF13261B);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final onTile = tile || dark;

    if (tile && background) {
      final rect = Offset.zero & size;
      final rr = RRect.fromRectAndRadius(rect, Radius.circular(s * cornerRadius));
      canvas.save();
      canvas.clipRRect(rr);
      canvas.drawRect(
        rect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [tileTop, tileMid, tileBottom],
            stops: [0, 0.55, 1],
          ).createShader(rect),
      );
      // Soft glow behind the lotus.
      canvas.drawCircle(
        Offset(s * 0.5, s * 0.5),
        s * 0.48,
        Paint()
          ..shader = RadialGradient(
            colors: [AppColors.mintDeep.withValues(alpha: 0.28), AppColors.mintDeep.withValues(alpha: 0)],
          ).createShader(Rect.fromCircle(center: Offset(s * 0.5, s * 0.5), radius: s * 0.48)),
      );
      canvas.restore();
    }

    canvas.save();
    // Scale the mark about the centre.
    final k = (tile ? 0.86 : 1.0) * contentScale;
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(k);
    canvas.translate(-s / 2, -s / 2);
    _mark(canvas, s, onTile);
    canvas.restore();
  }

  void _mark(Canvas canvas, double s, bool onTile) {
    Offset p(double x, double y) => Offset(x * s, y * s);

    // Rising sun / breath orb.
    final sunC = p(0.5, 0.235);
    final sunR = s * 0.075;
    canvas.drawCircle(
      sunC,
      sunR * 1.9,
      Paint()
        ..shader = RadialGradient(
          colors: [AppColors.sun.withValues(alpha: onTile ? 0.45 : 0.35), AppColors.sun.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: sunC, radius: sunR * 1.9)),
    );
    canvas.drawCircle(
      sunC,
      sunR,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFE9C2), Color(0xFFF2BE86)],
        ).createShader(Rect.fromCircle(center: sunC, radius: sunR)),
    );

    // Lotus petals, back to front.
    final base = p(0.5, 0.70);
    final sep = onTile ? LogoPainter.tileMid : AppColors.cream;
    final petals = <(double angle, double len, double width, List<Color>)>[
      (-66, 0.25, 0.105, onTile ? [AppColors.sky, AppColors.skyDeep] : [AppColors.skyDeep, const Color(0xFF4E8FB5)]),
      (66, 0.25, 0.105, onTile ? [AppColors.sky, AppColors.skyDeep] : [AppColors.skyDeep, const Color(0xFF4E8FB5)]),
      (-33, 0.30, 0.125, onTile ? [AppColors.mintDeep, AppColors.sage] : [AppColors.sage, AppColors.sageDark]),
      (33, 0.30, 0.125, onTile ? [AppColors.mintDeep, AppColors.sage] : [AppColors.sage, AppColors.sageDark]),
      (0, 0.34, 0.15, onTile ? [AppColors.mint, AppColors.mintDeep] : [AppColors.mintDeep, AppColors.sage]),
    ];
    for (final (deg, len, width, colors) in petals) {
      canvas.save();
      canvas.translate(base.dx, base.dy);
      canvas.rotate(deg * math.pi / 180);
      final l = len * s;
      final w = width * s;
      final petal = Path()
        ..moveTo(0, 0)
        ..cubicTo(-w * 0.95, -l * 0.28, -w * 0.62, -l * 0.78, 0, -l)
        ..cubicTo(w * 0.62, -l * 0.78, w * 0.95, -l * 0.28, 0, 0)
        ..close();
      canvas.drawPath(
        petal,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.022
          ..strokeJoin = StrokeJoin.round
          ..color = sep,
      );
      canvas.drawPath(
        petal,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colors,
          ).createShader(Rect.fromLTWH(-w, -l, w * 2, l)),
      );
      // Midrib.
      canvas.drawLine(
        Offset(0, -l * 0.18),
        Offset(0, -l * 0.72),
        Paint()
          ..strokeWidth = s * 0.008
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.35),
      );
      canvas.restore();
    }

    // Calm water / breath lines.
    final lineColor = onTile ? AppColors.cream : AppColors.sageDark;
    for (final (y, half, alpha) in [(0.775, 0.27, 0.9), (0.835, 0.17, 0.55)]) {
      final path = Path();
      const steps = 48;
      for (var i = 0; i <= steps; i++) {
        final t = i / steps;
        final x = 0.5 - half + t * half * 2;
        final yy = y + math.sin(t * math.pi * 2) * 0.012;
        if (i == 0) {
          path.moveTo(x * s, yy * s);
        } else {
          path.lineTo(x * s, yy * s);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.026
          ..strokeCap = StrokeCap.round
          ..color = lineColor.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant LogoPainter old) =>
      old.tile != tile ||
      old.dark != dark ||
      old.cornerRadius != cornerRadius ||
      old.contentScale != contentScale ||
      old.background != background;
}
