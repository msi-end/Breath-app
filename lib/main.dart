import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'services/account_service.dart';
import 'services/audio_download_service.dart';
import 'screens/music/music_nav.dart';
import 'services/firebase_bootstrap.dart';
import 'services/music_downloads.dart';
import 'services/music_library.dart';
import 'services/music_player.dart';
import 'services/my_music_store.dart';
import 'services/progress_store.dart';
import 'services/settings_controller.dart';
import 'services/usage_tracker.dart';
import 'theme/app_colors.dart';
import 'widgets/music/music_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Background playback with lock-screen and notification media controls.
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.breathecare.breathecare.channel.audio',
      androidNotificationChannelName: 'Music playback',
      androidNotificationChannelDescription: 'Playback controls for BreatheCare music',
      androidNotificationOngoing: true,
      androidNotificationIcon: 'drawable/ic_stat_breathecare',
      notificationColor: AppColors.forest,
    );
  } catch (e) {
    debugPrint('Background audio unavailable: $e');
  }

  final prefs = await SharedPreferences.getInstance();

  // Optional cloud features; the app is fully usable offline without them.
  await FirebaseBootstrap.init();

  final usage = UsageTracker(prefs);
  await usage.recordOpen();
  final audio = AudioDownloadService();
  await audio.init();
  final account = AccountService(prefs)..init();

  final library = MusicLibrary(prefs);
  final musicDownloads = MusicDownloads(library);
  final myMusic = MyMusicStore(prefs);
  final player = MusicPlayer(prefs, library, musicDownloads, myMusic);
  library.addListener(player.attachLibrary);
  await musicDownloads.init();
  await library.init();
  openMusicPlayer = openMusicPlayerScreen;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsController(prefs)),
        ChangeNotifierProvider(create: (_) => ProgressStore(prefs)),
        ChangeNotifierProvider.value(value: audio),
        ChangeNotifierProvider.value(value: account),
        Provider.value(value: usage),
        ChangeNotifierProvider.value(value: library),
        ChangeNotifierProvider.value(value: musicDownloads),
        ChangeNotifierProvider.value(value: myMusic),
        ChangeNotifierProvider.value(value: player),
      ],
      child: const BreatheCareApp(),
    ),
  );
}
