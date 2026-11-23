import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Calm page background: the page colour with a faint tint at the top and,
/// optionally, one soft hill along the bottom. Deliberately quiet.
class NatureBackground extends StatelessWidget {
  const NatureBackground({super.key, required this.child, this.tint, this.showHills = false});

  final Widget child;
  final Color? tint;
  final bool showHills;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CalmPainter(dark: context.isDark, tint: tint, showHills: showHills),
      child: child,
    );
  }
}

class _CalmPainter extends CustomPainter {
  _CalmPainter({required this.dark, required this.showHills, this.tint});

  final bool dark;
  final bool showHills;
  final Color? tint;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final base = dark ? AppColors.night : AppColors.cream;
    final top = tint ?? (dark ? const Color(0xFF11201A) : const Color(0xFFEAF5EE));
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, base],
          stops: const [0, 0.45],
        ).createShader(rect),
    );
    if (!showHills) return;
    final h = math.min(size.height * 0.16, 140.0);
    final y = size.height - h;
    final path = Path()..moveTo(0, size.height);
    for (double x = 0; x <= size.width; x += 6) {
      final t = x / size.width;
      path.lineTo(x, y + math.sin(t * math.pi * 1.4 + 0.6) * h * 0.22);
    }
    path
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = (dark ? AppColors.forestSoft : AppColors.mint).withValues(alpha: dark ? 0.18 : 0.45),
    );
  }

  @override
  bool shouldRepaint(covariant _CalmPainter old) => old.dark != dark || old.tint != tint || old.showHills != showHills;
}
