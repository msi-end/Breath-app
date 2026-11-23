import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'services/account_service.dart';
import 'services/audio_download_service.dart';
import 'services/firebase_bootstrap.dart';
import 'services/progress_store.dart';
import 'services/settings_controller.dart';
import 'services/usage_tracker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Optional cloud features; the app is fully usable offline without them.
  await FirebaseBootstrap.init();

  final usage = UsageTracker(prefs);
  await usage.recordOpen();
  final audio = AudioDownloadService();
  await audio.init();
  final account = AccountService(prefs)..init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsController(prefs)),
        ChangeNotifierProvider(create: (_) => ProgressStore(prefs)),
        ChangeNotifierProvider.value(value: audio),
        ChangeNotifierProvider.value(value: account),
        Provider.value(value: usage),
      ],
      child: const BreatheCareApp(),
    ),
  );
}
