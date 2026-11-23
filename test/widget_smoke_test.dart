import 'package:breathecare/app.dart';
import 'package:breathecare/data/moods.dart';
import 'package:breathecare/data/techniques.dart';
import 'package:breathecare/screens/emergency_calm_screen.dart';
import 'package:breathecare/screens/home_screen.dart';
import 'package:breathecare/screens/mood_results_screen.dart';
import 'package:breathecare/screens/technique_detail_screen.dart';
import 'package:breathecare/screens/breathing_session_screen.dart';
import 'package:breathecare/services/account_service.dart';
import 'package:breathecare/services/ads_service.dart';
import 'package:breathecare/services/audio_download_service.dart';
import 'package:breathecare/models/music.dart';
import 'package:breathecare/services/music_downloads.dart';
import 'package:breathecare/services/music_library.dart';
import 'package:breathecare/services/music_player.dart';
import 'package:breathecare/services/my_music_store.dart';
import 'package:breathecare/services/progress_store.dart';
import 'package:breathecare/services/settings_controller.dart';
import 'package:breathecare/services/usage_tracker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Widget> buildApp({String lang = 'en', Widget? home}) async {
  SharedPreferences.setMockInitialValues({'settings.lang': lang, 'settings.voice': false});
  final prefs = await SharedPreferences.getInstance();
  final usage = UsageTracker(prefs);
  await usage.recordOpen();
  final library = MusicLibrary.withTracks(prefs, demoTracks);
  final downloads = MusicDownloads(library);
  final mine = MyMusicStore(prefs);
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SettingsController(prefs)),
      ChangeNotifierProvider(create: (_) => ProgressStore(prefs)),
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

const demoTracks = [
  MusicTrack(
    id: 'a',
    title: 'Morning Stillness',
    artist: 'Asha',
    categoryId: 'piano',
    durationSeconds: 245,
    featured: true,
  ),
  MusicTrack(id: 'b', title: 'Soft Bansuri', artist: 'Ravi', categoryId: 'flute', durationSeconds: 412),
  MusicTrack(id: 'c', title: 'Quiet Focus', artist: 'Mira', categoryId: 'focus', durationSeconds: 900),
];

void usePhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532); // 390 x 844 logical
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  // Looping ambient animations honour "remove animations"; keeps pumpAndSettle finite.
  tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}

void main() {
  for (final lang in ['en', 'hi']) {
    testWidgets('all four tabs render ($lang)', (tester) async {
      usePhone(tester);
      await tester.pumpWidget(await buildApp(lang: lang));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);
      for (final icon in [
        Icons.menu_book_outlined,
        Icons.music_note_outlined,
        Icons.insights_outlined,
        Icons.settings_outlined,
      ]) {
        await tester.tap(find.byIcon(icon));
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('mood popup opens and leads to recommendations', (tester) async {
    usePhone(tester);
    await tester.pumpWidget(await buildApp());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Mood-Based Breathing'),
      250,
      scrollable: find.descendant(of: find.byType(HomeScreen), matching: find.byType(Scrollable)).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mood-Based Breathing'));
    await tester.pumpAndSettle();
    expect(find.text('How are you feeling right now?'), findsOneWidget);
    await tester.tap(find.text('Anxious'));
    await tester.pumpAndSettle();
    expect(find.byType(MoodResultsScreen), findsOneWidget);
    expect(find.text('Slow Breathing'), findsOneWidget);
  });

  testWidgets('every technique detail page renders', (tester) async {
    usePhone(tester);
    for (final t in allTechniques) {
      await tester.pumpWidget(await buildApp(home: TechniqueDetailScreen(technique: t)));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Start Practice'), findsOneWidget, reason: t.id);
    }
  });

  testWidgets('every mood page renders', (tester) async {
    usePhone(tester);
    for (final m in allMoods) {
      await tester.pumpWidget(await buildApp(home: MoodResultsScreen(mood: m)));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: m.id);
    }
  });

  testWidgets('session runs, suppresses ads, pauses and records on end', (tester) async {
    usePhone(tester);
    final app = await buildApp(home: BreathingSessionScreen(technique: techniqueById('box')!, minutes: 1));
    await tester.pumpWidget(app);
    expect(AdsService.instance.adsAllowed, isFalse);
    // 3s preparation then 30s of breathing.
    for (var i = 0; i < 34 * 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Pause'), findsNothing); // icon only, tooltip
    await tester.tap(find.byTooltip('Pause'));
    await tester.pump();
    expect(find.text('Paused'), findsOneWidget);
    await tester.tap(find.text('End Session'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Well done'), findsOneWidget);
    final store = Provider.of<ProgressStore>(tester.element(find.text('Well done')), listen: false);
    expect(store.totalSessions, 1);
    expect(store.sessions.single.durationSeconds, inInclusiveRange(28, 32));
  });

  testWidgets('emergency calm starts immediately, shows disclaimer, and stops', (tester) async {
    usePhone(tester);
    await tester.pumpWidget(await buildApp(home: const Scaffold(body: SizedBox())));
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    nav.push(MaterialPageRoute(builder: (_) => const EmergencyCalmScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Breathe in'), findsOneWidget);
    expect(find.textContaining('seek urgent medical help'), findsOneWidget);
    for (var i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Breathe out'), findsOneWidget);
    await tester.tap(find.text('Stop'));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.byType(EmergencyCalmScreen), findsNothing);
  });
}
