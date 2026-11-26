import 'dart:io';

import 'package:flutter/services.dart';

/// Loads the app font and Material icons so rendered images show real text
/// (flutter test otherwise draws placeholder boxes).
Future<void> loadRealFonts() async {
  Future<void> load(String family, List<String> paths) async {
    final loader = FontLoader(family);
    for (final p in paths) {
      final bytes = File(p).readAsBytesSync();
      loader.addFont(Future.value(ByteData.view(Uint8List.fromList(bytes).buffer)));
    }
    await loader.load();
  }

  await load('PlusJakartaSans', [
    for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) 'assets/fonts/PlusJakartaSans-$w.ttf',
  ]);
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? '/opt/flutter';
  await load('MaterialIcons', ['$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
  // Devanagari for Hindi screenshots, when the system has it.
  for (final p in [
    '/usr/share/fonts/truetype/noto/NotoSansDevanagari-Regular.ttf',
    '/usr/share/fonts/opentype/noto/NotoSansDevanagari-Regular.ttf',
  ]) {
    if (File(p).existsSync()) await load('NotoSansDevanagari', [p]);
  }
}
