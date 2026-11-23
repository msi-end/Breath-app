import 'dart:convert';

import 'package:breathecare/app.dart';
import 'package:breathecare/models/music.dart';
import 'package:breathecare/screens/music/music_category_screen.dart';
import 'package:breathecare/screens/music/music_screen.dart';
import 'package:breathecare/screens/music/music_search_screen.dart';
import 'package:breathecare/screens/music/my_music_screen.dart';
import 'package:breathecare/data/music_categories.dart';
import 'package:breathecare/services/account_service.dart';
import 'package:breathecare/services/audio_download_service.dart';
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

final tracks = [
  MusicTrack(
    id: 'a',
    title: 'Morning Stillness',
    artist: 'Asha',
    categoryId: 'piano',
    durationSeconds: 245,
    featured: true,
    added: DateTime(2026, 1, 1),
  ),
  MusicTrack(
    id: 'b',
    title: 'Soft Bansuri',
    artist: 'Ravi',
    categoryId: 'flute',
    durationSeconds: 412,
    added: DateTime(2026, 3, 1),
  ),
  MusicTrack(
    id: 'c',
    title: 'Quiet Focus',
    artist: 'Mira',
    categoryId: 'focus',
    durationSeconds: 900,
    added: DateTime(2026, 2, 1),
  ),
];

Future<(Widget, MusicLibrary, MyMusicStore)> buildApp({Widget? home}) async {
  SharedPreferences.setMockInitialValues({'settings.lang': 'en'});
  final prefs = await SharedPreferences.getInstance();
  final library = MusicLibrary.withTracks(prefs, tracks);
  final downloads = MusicDownloads(library);
  final mine = MyMusicStore(prefs);
  final app = MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SettingsController(prefs)),
      ChangeNotifierProvider(create: (_) => ProgressStore(prefs)),
      ChangeNotifierProvider(create: (_) => AudioDownloadService()),
      ChangeNotifierProvider(create: (_) => AccountService(prefs)),
      Provider.value(value: UsageTracker(prefs)),
      ChangeNotifierProvider.value(value: library),
      ChangeNotifierProvider.value(value: downloads),
      ChangeNotifierProvider.value(value: mine),
      ChangeNotifierProvider.value(value: MusicPlayer(prefs, library, downloads, mine)),
    ],
    child: BreatheCareApp(home: home),
  );
  return (app as Widget, library, mine);
}

void phone(WidgetTester t) {
  t.view.physicalSize = const Size(1170, 2532);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  t.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('catalog JSON parses with sensible defaults', () {
    final t = MusicTrack.fromJson(
      jsonDecode('{"id":"x","title":"T","category":"yoga","duration":61}') as Map<String, dynamic>,
    );
    expect(t.audioPath, 'music/audio/x.mp3');
    expect(t.artist, '');
    expect(t.titleFor('hi'), 'T');
    final round = MusicTrack.fromJson(t.toJson());
    expect(round.categoryId, 'yoga');
    expect(round.durationSeconds, 61);
  });

  test('every category has a unique id', () {
    expect(musicCategories.map((c) => c.id).toSet().length, musicCategories.length);
  });

  test('search matches title, artist and category; sorting works', () async {
    final prefs = await SharedPreferences.getInstance();
    final lib = MusicLibrary.withTracks(prefs, tracks);
    expect(lib.search('bansuri').single.id, 'b');
    expect(lib.search('mira').single.id, 'c');
    expect(lib.search('piano').single.id, 'a'); // category name
    expect(lib.search('', categoryId: 'focus').single.id, 'c');
    expect(lib.search('', sort: MusicSort.longest).first.id, 'c');
    expect(lib.search('', sort: MusicSort.newest).first.id, 'b');
    expect(lib.search('', sort: MusicSort.titleAz).first.id, 'a');
    // Short tracks (≤ 5 min) appear in "Short Relaxation".
    expect(lib.inCategory('short').map((t) => t.id), ['a']);
    expect(lib.activeCategories.map((c) => c.id), containsAll(['piano', 'flute', 'focus', 'short']));
  });

  test('favorites, recents and playlists persist', () async {
    final prefs = await SharedPreferences.getInstance();
    final store = MyMusicStore(prefs);
    await store.toggleFavorite('a');
    await store.markPlayed('b');
    await store.markPlayed('a');
    final p = await store.createPlaylist('Calm', trackIds: ['a']);
    expect(await store.addToPlaylist(p.id, 'a'), isFalse);
    expect(await store.addToPlaylist(p.id, 'c'), isTrue);
    await store.reorderPlaylist(p.id, 1, 0);

    final again = MyMusicStore(prefs);
    expect(again.isFavorite('a'), isTrue);
    expect(again.recentIds, ['a', 'b']);
    expect(again.playlists.single.trackIds, ['c', 'a']);
    await again.renamePlaylist(p.id, 'Evening');
    expect(MyMusicStore(prefs).playlists.single.name, 'Evening');
  });

  test('last played track is restored for the mini player', () async {
    SharedPreferences.setMockInitialValues({
      'music.last.v1': jsonEncode({
        'id': 'b',
        'queue': ['a', 'b'],
        'pos': 30000,
      }),
    });
    final prefs = await SharedPreferences.getInstance();
    final lib = MusicLibrary.withTracks(prefs, tracks);
    final player = MusicPlayer(prefs, lib, MusicDownloads(lib), MyMusicStore(prefs));
    player.attachLibrary();
    expect(player.current?.id, 'b');
    expect(player.resumePosition, const Duration(seconds: 30));
    expect(player.isLoaded, isFalse);
  });

  testWidgets('music tab shows featured music, categories and search', (t) async {
    phone(t);
    final (app, _, _) = await buildApp(home: const Scaffold(body: MusicScreen()));
    await t.pumpWidget(app);
    await t.pumpAndSettle();
    expect(find.text('Music'), findsOneWidget);
    expect(find.text('Morning Stillness'), findsWidgets);
    await t.scrollUntilVisible(find.text('Calm Piano'), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('Bansuri & Flute'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('search filters results as you type', (t) async {
    phone(t);
    final (app, _, _) = await buildApp(home: const MusicSearchScreen());
    await t.pumpWidget(app);
    await t.pumpAndSettle();
    expect(find.text('3 results'), findsOneWidget);
    await t.enterText(find.byType(TextField), 'focus');
    await t.pumpAndSettle();
    expect(find.text('1 result'), findsOneWidget);
    expect(find.text('Quiet Focus'), findsOneWidget);
  });

  testWidgets('category page lists its tracks; favorites appear in My Music', (t) async {
    phone(t);
    final (app, _, mine) = await buildApp(
      home: MusicCategoryScreen(category: musicCategories.firstWhere((c) => c.id == 'piano')),
    );
    await t.pumpWidget(app);
    await t.pumpAndSettle();
    expect(find.text('Morning Stillness'), findsOneWidget);
    await t.tap(find.byTooltip('Add to favorites'));
    await t.pumpAndSettle();
    expect(mine.isFavorite('a'), isTrue);

    final (app2, _, _) = await buildApp(home: const MyMusicScreen(initialTab: 3));
    await t.pumpWidget(app2);
    await t.pumpAndSettle();
    expect(find.text('New playlist'), findsOneWidget);
  });
}
