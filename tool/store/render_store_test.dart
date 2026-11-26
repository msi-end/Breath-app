// Renders Google Play store graphics from the real app UI:
//   * 8 phone screenshots, 1080 x 1920 (store/play/screenshots/)
//   * the feature graphic, 1024 x 500 (store/play/feature-graphic.png)
//
//   flutter test tool/store/render_store_test.dart
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:breathecare/app.dart';
import 'package:breathecare/data/explore_yoga.dart';
import 'package:breathecare/data/techniques.dart';
import 'package:breathecare/models/music.dart';
import 'package:breathecare/screens/article_screen.dart';
import 'package:breathecare/screens/breathing_session_screen.dart';
import 'package:breathecare/screens/emergency_calm_screen.dart';
import 'package:breathecare/services/account_service.dart';
import 'package:breathecare/services/audio_download_service.dart';
import 'package:breathecare/services/music_downloads.dart';
import 'package:breathecare/services/music_library.dart';
import 'package:breathecare/services/music_player.dart';
import 'package:breathecare/services/my_music_store.dart';
import 'package:breathecare/services/progress_store.dart';
import 'package:breathecare/services/settings_controller.dart';
import 'package:breathecare/services/usage_tracker.dart';
import 'package:breathecare/theme/app_colors.dart';
import 'package:breathecare/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fonts.dart';

const _font = 'PlusJakartaSans';

/// Sample music shown in screenshots (titles only; no audio needed).
const _tracks = [
  MusicTrack(id: 'm1', title: 'Morning Stillness', artist: 'BreatheCare', categoryId: 'piano', durationSeconds: 245, featured: true),
  MusicTrack(id: 'm2', title: 'Riverside Bansuri', artist: 'BreatheCare', categoryId: 'flute', durationSeconds: 412, featured: true),
  MusicTrack(id: 'm3', title: 'Deep Night Rest', artist: 'BreatheCare', categoryId: 'sleep', durationSeconds: 1200, featured: true),
  MusicTrack(id: 'm4', title: 'Quiet Focus', artist: 'BreatheCare', categoryId: 'focus', durationSeconds: 900),
  MusicTrack(id: 'm5', title: 'Rise & Shine', artist: 'BreatheCare', categoryId: 'energy', durationSeconds: 210),
  MusicTrack(id: 'm6', title: 'Singing Bowls', artist: 'BreatheCare', categoryId: 'bowls', durationSeconds: 600),
  MusicTrack(id: 'm7', title: 'Soft Rain Piano', artist: 'BreatheCare', categoryId: 'relaxation', durationSeconds: 480),
  MusicTrack(id: 'm8', title: 'Evening Raga', artist: 'BreatheCare', categoryId: 'indian', durationSeconds: 720),
  MusicTrack(id: 'm9', title: 'Gentle Flow', artist: 'BreatheCare', categoryId: 'yoga', durationSeconds: 540),
  MusicTrack(id: 'm10', title: 'Still Mind', artist: 'BreatheCare', categoryId: 'meditation', durationSeconds: 660),
];

Future<Widget> _app({required Widget? home, bool dark = false, bool seed = true}) async {
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({
    'settings.lang': 'en',
    'settings.voice': false,
    'settings.theme': dark ? ThemeMode.dark.index : ThemeMode.light.index,
  });
  final prefs = await SharedPreferences.getInstance();
  final usage = UsageTracker(prefs);
  await usage.recordOpen();
  final progress = ProgressStore(prefs);
  if (seed) {
    final now = DateTime.now();
    final ids = ['box', 'belly', '478', 'focus', 'relax', 'resonant'];
    for (var d = 13; d >= 0; d--) {
      if (d % 5 == 4) continue;
      final day = DateTime(now.year, now.month, now.day - d, 8, 10);
      await progress.addSession(
        techniqueId: ids[d % ids.length],
        startedAt: day,
        durationSeconds: 180 + (d * 37) % 240,
        completed: true,
      );
    }
    for (final f in ['box', '478', 'belly']) {
      await progress.toggleFavorite(f);
    }
  }
  final library = MusicLibrary.withTracks(prefs, _tracks);
  final downloads = MusicDownloads(library);
  final mine = MyMusicStore(prefs);
  await mine.markPlayed('m3');
  await mine.markPlayed('m1');
  await mine.toggleFavorite('m2');
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SettingsController(prefs)),
      ChangeNotifierProvider.value(value: progress),
      ChangeNotifierProvider(create: (_) => AudioDownloadService()),
      ChangeNotifierProvider(create: (_) => AccountService(prefs)),
      Provider.value(value: usage),
      ChangeNotifierProvider.value(value: library),
      ChangeNotifierProvider.value(value: downloads),
      ChangeNotifierProvider.value(value: mine),
      ChangeNotifierProvider.value(value: MusicPlayer(prefs, library, downloads, mine)),
    ],
    child: BreatheCareApp(home: home),
  );
}

/// Logical size of the phone screen shown inside the frame.
const _screen = Size(390, 800);

/// A phone with a status bar, showing [app] at a real phone size.
class _Phone extends StatelessWidget {
  const _Phone({required this.app, this.dark = false, this.width = 300});

  final Widget app;
  final bool dark;
  final double width;

  @override
  Widget build(BuildContext context) {
    final bezel = width * 0.035;
    final inner = width - bezel * 2;
    final scale = inner / _screen.width;
    return Container(
      width: width,
      padding: EdgeInsets.all(bezel),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1612),
        borderRadius: BorderRadius.circular(width * 0.13),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 40, offset: const Offset(0, 18)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width * 0.1),
        child: SizedBox(
          width: inner,
          height: _screen.height * scale,
          child: FittedBox(
            child: SizedBox.fromSize(
              size: _screen,
              child: MediaQuery(
                data: const MediaQueryData(
                  size: _screen,
                  devicePixelRatio: 3,
                  padding: EdgeInsets.only(top: 30, bottom: 8),
                  viewPadding: EdgeInsets.only(top: 30, bottom: 8),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(child: app),
                    Positioned(left: 0, right: 0, top: 0, child: _StatusBar(dark: dark)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final c = dark ? AppColors.cream : AppColors.forest;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          children: [
            Text('9:41', style: TextStyle(fontFamily: _font, fontWeight: FontWeight.w700, fontSize: 14, color: c)),
            const Spacer(),
            Icon(Icons.signal_cellular_alt_rounded, size: 16, color: c),
            const SizedBox(width: 4),
            Icon(Icons.wifi_rounded, size: 16, color: c),
            const SizedBox(width: 4),
            Icon(Icons.battery_full_rounded, size: 16, color: c),
          ],
        ),
      ),
    );
  }
}

/// Brand backdrop: deep forest with a soft glow and rolling hills.
class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.child, this.light = false});

  final Widget child;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BackdropPainter(light: light),
      child: child,
    );
  }
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter({required this.light});

  final bool light;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: light
              ? const [Color(0xFFE6F4EA), AppColors.cream]
              : const [Color(0xFF2F6650), AppColors.forest, Color(0xFF15291D)],
        ).createShader(rect),
    );
    final glowC = Offset(size.width * 0.8, size.height * 0.12);
    canvas.drawCircle(
      glowC,
      size.width * 0.55,
      Paint()
        ..shader = RadialGradient(
          colors: [
            (light ? AppColors.sun : AppColors.mintDeep).withValues(alpha: light ? 0.55 : 0.25),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: glowC, radius: size.width * 0.55)),
    );
    for (final (y, amp, alpha) in [(0.62, 0.035, 0.07), (0.75, 0.03, 0.09)]) {
      final hill = Path()..moveTo(0, size.height);
      for (double x = 0; x <= size.width; x += 4) {
        hill.lineTo(x, size.height * y + math.sin(x / size.width * math.pi * 1.6 + y * 9) * size.height * amp);
      }
      hill
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(hill, Paint()..color = (light ? AppColors.sage : AppColors.mintDeep).withValues(alpha: alpha));
    }
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter old) => old.light != light;
}

class _Shot {
  const _Shot(this.file, this.title, this.subtitle, this.home, {this.dark = false, this.light = false, this.prepare});

  final String file;
  final String title;
  final String subtitle;
  final Widget? Function() home;
  final bool dark;

  /// Light backdrop instead of the forest one.
  final bool light;
  final Future<void> Function(WidgetTester t)? prepare;
}

Future<void> _tapIcon(WidgetTester t, IconData icon) async {
  await t.tap(find.byIcon(icon).last);
  await t.pump(const Duration(milliseconds: 400));
  await t.pump(const Duration(milliseconds: 400));
}

final _shots = <_Shot>[
  _Shot('01_home', 'Breathe better,\nfeel calmer', 'Guided breathing in just a few minutes a day', () => null),
  _Shot(
    '02_breathing',
    'Follow the shape,\nfind your rhythm',
    'Inhale, hold and exhale — never forced',
    () => BreathingSessionScreen(technique: techniqueById('box')!, minutes: 3),
    dark: true,
    prepare: (t) async {
      for (var i = 0; i < 52; i++) {
        await t.pump(const Duration(milliseconds: 100));
      }
    },
  ),
  _Shot(
    '03_explore',
    'Yoga, pranayama\n& healthy habits',
    'Asanas, herbs, calm practices and daily tips',
    () => null,
    light: true,
    prepare: (t) => _tapIcon(t, Icons.explore_outlined),
  ),
  _Shot(
    '04_yoga',
    'Learn each pose\nstep by step',
    'Watch it on YouTube with one tap',
    () => ArticleScreen(article: yogaArticles.firstWhere((a) => a.id == 'yoga_vrikshasana')),
  ),
  _Shot(
    '05_listen',
    'Music to relax,\nfocus and sleep',
    'Saved on your phone after the first play',
    () => null,
    light: true,
    prepare: (t) => _tapIcon(t, Icons.headphones_outlined),
  ),
  _Shot(
    '06_emergency',
    'Calm, in one tap',
    'Works offline. Never shows ads.',
    () => const EmergencyCalmScreen(),
    dark: true,
    prepare: (t) async {
      for (var i = 0; i < 30; i++) {
        await t.pump(const Duration(milliseconds: 100));
      }
    },
  ),
  _Shot(
    '07_progress',
    'Build a calm\ndaily habit',
    'Streaks, challenges and weekly insights',
    () => null,
    light: true,
    prepare: (t) => _tapIcon(t, Icons.insights_outlined),
  ),
  _Shot(
    '08_dark',
    'Beautiful by day\nand by night',
    'Light & dark themes · English & Hindi',
    () => null,
    dark: true,
  ),
];

Future<void> _save(WidgetTester t, GlobalKey key, String path, double pixelRatio) async {
  final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final bytes = await t.runAsync(() async {
    final img = await boundary.toImage(pixelRatio: pixelRatio);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes!);
}

void main() {
  setUpAll(loadRealFonts);

  for (final shot in _shots) {
    testWidgets('screenshot ${shot.file}', (t) async {
      // 1080 x 1920 px output.
      const ratio = 2.5;
      t.view.physicalSize = const Size(1080, 1920);
      t.view.devicePixelRatio = ratio;
      addTearDown(t.view.reset);

      final key = GlobalKey();
      final app = await _app(home: shot.home(), dark: shot.dark);
      final textColor = shot.light ? AppColors.forest : AppColors.cream;
      await t.pumpWidget(
        RepaintBoundary(
          key: key,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: _Backdrop(
              light: shot.light,
              child: Stack(
                children: [
                  Positioned(
                    left: 28,
                    right: 28,
                    top: 46,
                    child: Column(
                      children: [
                        Text(
                          shot.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: _font,
                            fontWeight: FontWeight.w800,
                            fontSize: 31,
                            height: 1.15,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          shot.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: _font,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: textColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 178,
                    left: 0,
                    right: 0,
                    child: Center(child: _Phone(app: app, dark: shot.dark, width: 306)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await t.pump(const Duration(milliseconds: 300));
      await t.pump(const Duration(milliseconds: 300));
      if (shot.prepare != null) await shot.prepare!(t);
      await t.pump(const Duration(milliseconds: 50));
      await _save(t, key, 'store/play/screenshots/${shot.file}.png', ratio);
      // Leave the app idle so pending timers finish.
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(seconds: 5));
    });
  }

  testWidgets('feature graphic', (t) async {
    t.view.physicalSize = const Size(1024, 500);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final key = GlobalKey();
    final app = await _app(home: null);
    await t.pumpWidget(
      RepaintBoundary(
        key: key,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: _Backdrop(
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  left: 64,
                  top: 0,
                  bottom: 0,
                  width: 560,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CustomPaint(
                            size: const Size.square(96),
                            painter: LogoPainter(tile: true, dark: false),
                          ),
                          const SizedBox(width: 22),
                          const Text(
                            'BreatheCare',
                            style: TextStyle(
                              fontFamily: _font,
                              fontWeight: FontWeight.w800,
                              fontSize: 58,
                              color: AppColors.cream,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      const Text(
                        'Breathe · Explore · Listen',
                        style: TextStyle(
                          fontFamily: _font,
                          fontWeight: FontWeight.w700,
                          fontSize: 30,
                          color: AppColors.mintDeep,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Guided breathing, yoga & calming music — works offline',
                        style: TextStyle(
                          fontFamily: _font,
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          color: AppColors.cream.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 70,
                  top: 46,
                  child: Transform.rotate(angle: 0.06, child: _Phone(app: app, width: 250)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await t.pump(const Duration(milliseconds: 300));
    await t.pump(const Duration(milliseconds: 300));
    await _save(t, key, 'store/play/feature-graphic.png', 1);
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 5));
  });
}
