// Renders the app icon, adaptive-icon foreground and Play Store icon from
// the same painter the app uses.
//   flutter test tool/store/render_brand_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:breathecare/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _paint(String path, int px, LogoPainter painter, {Color? fill}) async {
  final rec = ui.PictureRecorder();
  final canvas = Canvas(rec);
  final size = Size.square(px.toDouble());
  if (fill != null) canvas.drawRect(Offset.zero & size, Paint()..color = fill);
  painter.paint(canvas, size);
  final img = await rec.endRecording().toImage(px, px);
  final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  test('render brand icons', () async {
    // Launcher / iOS icon: full-bleed square (the OS applies its own mask).
    await _paint('assets/branding/icon.png', 1024, LogoPainter(tile: true, dark: false, cornerRadius: 0));
    // Android adaptive foreground: transparent, mark kept in the safe zone.
    await _paint(
      'assets/branding/icon_foreground.png',
      1024,
      LogoPainter(tile: true, dark: false, background: false, contentScale: 0.86),
    );
    // Android adaptive background: the tile gradient and glow, without the mark.
    await _paint('assets/branding/icon_background.png', 1024, _BackgroundOnly());
    // Google Play listing icon: 512x512, square (Play rounds the corners).
    await _paint('store/play/icon-512.png', 512, LogoPainter(tile: true, dark: false, cornerRadius: 0));
    // Logo on light background, for the website / marketing.
    await _paint('store/brand/logo-mark-light.png', 1024, LogoPainter(tile: false, dark: false));
    await _paint('store/brand/logo-rounded.png', 1024, LogoPainter(tile: true, dark: false));
  });
}

class _BackgroundOnly extends LogoPainter {
  _BackgroundOnly() : super(tile: true, dark: false, cornerRadius: 0, contentScale: 0.0001);
}
