import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// AdMob configuration.
///
/// Before publishing:
///  1. Create the app and a *Banner* ad unit in https://apps.admob.com
///  2. Put the ad unit IDs below.
///  3. Put the AdMob **App IDs** in android/app/src/main/AndroidManifest.xml
///     (com.google.android.gms.ads.APPLICATION_ID) and ios/Runner/Info.plist
///     (GADApplicationIdentifier).
///
/// Debug builds always use Google's official test ad units, so you can never
/// accidentally click your own live ads during development.
class AdConfig {
  AdConfig._();

  // TODO: Replace with your production banner ad unit IDs.
  static const String androidBannerUnitId = 'ca-app-pub-0000000000000000/0000000000';
  static const String iosBannerUnitId = 'ca-app-pub-0000000000000000/0000000000';

  // Google's public test ad units.
  static const String _testAndroidBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testIosBanner = 'ca-app-pub-3940256099942544/2934735716';

  static bool get _hasProductionIds =>
      !androidBannerUnitId.startsWith('ca-app-pub-0000000000000000') &&
      !iosBannerUnitId.startsWith('ca-app-pub-0000000000000000');

  static bool get useTestAds => kDebugMode || !_hasProductionIds;

  static String get bannerUnitId {
    if (Platform.isIOS) return useTestAds ? _testIosBanner : iosBannerUnitId;
    return useTestAds ? _testAndroidBanner : androidBannerUnitId;
  }
}
