import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/music_categories.dart';
import '../../models/music.dart';
import '../../services/music_library.dart';
import '../../theme/app_colors.dart';

/// Cover image for a track or category. Shows the uploaded artwork (cached
/// on the device) or, until it's available, generated nature-style artwork.
class CoverArt extends StatelessWidget {
  const CoverArt._({
    super.key,
    required this.cacheKey,
    required this.storagePath,
    required this.colors,
    required this.icon,
    required this.size,
    required this.radius,
    this.seed = 0,
    this.iconAlignment = Alignment.center,
  });

  factory CoverArt.track(MusicTrack t, {Key? key, double size = 56, double? radius}) {
    final cat = musicCategoryById(t.categoryId) ?? musicCategories.first;
    return CoverArt._(
      key: key,
      cacheKey: t.id,
      storagePath: t.coverPath,
      colors: cat.colors,
      icon: cat.icon,
      size: size,
      radius: radius ?? size * 0.22,
      seed: t.id.hashCode,
    );
  }

  factory CoverArt.category(MusicCategory c, {Key? key, double size = 120, double? radius}) => CoverArt._(
    key: key,
    cacheKey: 'cat_${c.id}',
    storagePath: c.coverPath,
    colors: c.colors,
    icon: c.icon,
    size: size,
    radius: radius ?? 24,
    seed: c.id.hashCode,
    iconAlignment: const Alignment(0.8, -0.65),
  );

  final String cacheKey;
  final String? storagePath;
  final List<Color> colors;
  final IconData icon;

  /// Use double.infinity to fill the parent.
  final double size;
  final double radius;
  final int seed;
  final Alignment iconAlignment;

  @override
  Widget build(BuildContext context) {
    final library = context.read<MusicLibrary>();
    final cached = library.cachedCoverSync(cacheKey);
    final generated = _Generated(
      colors: colors,
      icon: icon,
      seed: seed,
      alignment: iconAlignment,
      dark: Theme.of(context).brightness == Brightness.dark,
    );
    Widget child;
    if (cached != null) {
      child = _file(cached, generated);
    } else {
      child = FutureBuilder<File?>(
        future: library.coverFile(cacheKey, storagePath),
        builder: (context, snap) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: snap.data == null ? generated : _file(snap.data!, generated),
        ),
      );
    }
    final box = ClipRRect(borderRadius: BorderRadius.circular(radius), child: child);
    if (size == double.infinity) return box;
    return SizedBox.square(dimension: size, child: box);
  }

  Widget _file(File f, Widget fallback) => Image.file(
    f,
    key: ValueKey(f.path),
    fit: BoxFit.cover,
    width: double.infinity,
    height: double.infinity,
    errorBuilder: (_, _, _) => fallback,
  );
}

class _Generated extends StatelessWidget {
  const _Generated({
    required this.colors,
    required this.icon,
    required this.seed,
    required this.dark,
    this.alignment = Alignment.center,
  });

  final List<Color> colors;
  final IconData icon;
  final int seed;
  final bool dark;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final a = dark ? Color.lerp(colors.first, AppColors.night, 0.45)! : Color.lerp(colors.first, Colors.white, 0.2)!;
    final b = dark ? Color.lerp(colors.last, AppColors.night, 0.6)! : colors.last;
    return LayoutBuilder(
      builder: (context, box) {
        final s = box.biggest.shortestSide.isFinite ? box.biggest.shortestSide : 56.0;
        return CustomPaint(
          painter: _ArtPainter(a: a, b: b, seed: seed),
          child: Align(
            alignment: alignment,
            child: Icon(
              icon,
              size: s * (alignment == Alignment.center ? 0.34 : 0.24),
              color: (dark ? AppColors.cream : AppColors.forest).withValues(alpha: 0.75),
            ),
          ),
        );
      },
    );
  }
}

class _ArtPainter extends CustomPainter {
  _ArtPainter({required this.a, required this.b, required this.seed});

  final Color a;
  final Color b;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = math.Random(seed);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment(-1 + r.nextDouble(), -1),
          end: Alignment(1 - r.nextDouble(), 1),
          colors: [a, b],
        ).createShader(rect),
    );
    // Soft ripples + a rolling hill — calm, nature-inspired artwork.
    final c = Offset(size.width * (0.2 + 0.6 * r.nextDouble()), size.height * (0.15 + 0.3 * r.nextDouble()));
    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(
        c,
        size.shortestSide * 0.16 * i,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, size.shortestSide * 0.012)
          ..color = Colors.white.withValues(alpha: 0.22 - i * 0.04),
      );
    }
    final hill = Path()..moveTo(0, size.height);
    final phase = r.nextDouble() * math.pi;
    for (double x = 0; x <= size.width; x += size.width / 30) {
      hill.lineTo(x, size.height * 0.78 + math.sin(x / size.width * math.pi * 1.5 + phase) * size.height * 0.06);
    }
    hill
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(hill, Paint()..color = Colors.white.withValues(alpha: 0.16));
  }

  @override
  bool shouldRepaint(covariant _ArtPainter old) => old.a != a || old.b != b || old.seed != seed;
}
