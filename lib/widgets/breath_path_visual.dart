import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../models/breath_pattern.dart';
import '../theme/app_colors.dart';

/// Traces the breathing rhythm as a shape: a glowing dot travels one side per
/// phase. 4 phases → square (box), 3 → inverted triangle, 2 → circle.
/// The soft inner glow grows on the in-breath and fades on the out-breath.
class BreathPathVisual extends StatelessWidget {
  const BreathPathVisual({
    super.key,
    required this.pattern,
    required this.phaseIndex,
    required this.phaseProgress,
    required this.expansion,
    required this.color,
    this.size = 280,
    this.child,
  });

  final BreathPattern pattern;
  final int phaseIndex;
  final double phaseProgress;
  final double expansion;
  final Color color;
  final double size;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _PathPainter(
            phases: pattern.phases.length,
            phaseIndex: phaseIndex,
            progress: phaseProgress.clamp(0.0, 1.0),
            expansion: expansion.clamp(0.0, 1.0),
            color: color,
            dark: context.isDark,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  _PathPainter({
    required this.phases,
    required this.phaseIndex,
    required this.progress,
    required this.expansion,
    required this.color,
    required this.dark,
  });

  final int phases;
  final int phaseIndex;
  final double progress;
  final double expansion;
  final Color color;
  final bool dark;

  /// One sub-path per phase, in order.
  List<Path> _segments(Rect r) {
    if (phases == 4) {
      // Up the left side (in), across the top (hold), down (out), back (rest).
      final pts = [r.bottomLeft, r.topLeft, r.topRight, r.bottomRight];
      return [
        for (var i = 0; i < 4; i++)
          Path()
            ..moveTo(pts[i].dx, pts[i].dy)
            ..lineTo(pts[(i + 1) % 4].dx, pts[(i + 1) % 4].dy),
      ];
    }
    if (phases == 3) {
      // Inverted triangle: up (in), across (hold), down (out).
      final bottom = Offset(r.center.dx, r.bottom - r.height * 0.06);
      final tl = Offset(r.left, r.top + r.height * 0.12);
      final tr = Offset(r.right, r.top + r.height * 0.12);
      return [
        Path()
          ..moveTo(bottom.dx, bottom.dy)
          ..lineTo(tl.dx, tl.dy),
        Path()
          ..moveTo(tl.dx, tl.dy)
          ..lineTo(tr.dx, tr.dy),
        Path()
          ..moveTo(tr.dx, tr.dy)
          ..lineTo(bottom.dx, bottom.dy),
      ];
    }
    // Circle split evenly: from the bottom, up the left (in), down the right (out).
    final n = math.max(phases, 1);
    final sweep = 2 * math.pi / n;
    return [for (var i = 0; i < n; i++) Path()..addArc(r, math.pi / 2 + i * sweep, sweep)];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final inset = size.shortestSide * 0.16;
    final r = (Offset.zero & size).deflate(inset);
    final stroke = size.shortestSide * 0.022;
    final segments = _segments(r);
    final c = r.center;

    // Breathing inner glow.
    final glowR = r.width * (0.18 + 0.38 * expansion);
    canvas.drawCircle(
      c,
      glowR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: dark ? 0.40 : 0.32),
            color.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: glowR)),
    );

    // Base track.
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color.withValues(alpha: dark ? 0.30 : 0.35);
    for (final seg in segments) {
      canvas.drawPath(seg, track);
    }

    // Trail of the current cycle.
    final trail = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.95);
    final trailGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke * 2.4
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: dark ? 0.35 : 0.22)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, stroke * 1.4);
    final idx = phaseIndex.clamp(0, segments.length - 1);
    Offset dot = c;
    for (var i = 0; i <= idx; i++) {
      final PathMetric m = segments[i].computeMetrics().first;
      final len = i < idx ? m.length : m.length * progress;
      final part = m.extractPath(0, len);
      canvas.drawPath(part, trailGlow);
      canvas.drawPath(part, trail);
      if (i == idx) dot = m.getTangentForOffset(len)?.position ?? dot;
    }

    // The guiding dot.
    final dotR = size.shortestSide * 0.042;
    canvas.drawCircle(
      dot,
      dotR * 2.6,
      Paint()
        ..color = (dark ? Colors.white : color).withValues(alpha: dark ? 0.35 : 0.30)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, dotR * 1.6),
    );
    canvas.drawCircle(dot, dotR, Paint()..color = dark ? Colors.white : AppColors.forest);
    canvas.drawCircle(dot, dotR * 0.55, Paint()..color = dark ? AppColors.mint : color);
  }

  @override
  bool shouldRepaint(covariant _PathPainter old) =>
      old.phaseIndex != phaseIndex ||
      old.progress != progress ||
      old.expansion != expansion ||
      old.phases != phases ||
      old.color != color ||
      old.dark != dark;
}
