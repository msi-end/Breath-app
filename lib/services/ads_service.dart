import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Central place for every advertising rule in BreatheCare:
///
///  * Only small banner ads are used — no full-screen/interstitial ads.
///  * Ads are never requested or shown while a breathing session or
///    Emergency Calm Mode is active ([suppress]/[release]).
///  * Every request is non-personalized and carries no keywords, so mood or
///    wellness information is never used for ad targeting.
class AdsService {
  AdsService._();

  static final AdsService instance = AdsService._();

  final ValueNotifier<bool> _sdkReady = ValueNotifier(false);
  final ValueNotifier<int> _suppressCount = ValueNotifier(0);
  bool _started = false;
  bool privacyOptionsRequired = false;

  Listenable get changes => Listenable.merge([_sdkReady, _suppressCount]);

  bool get isSupportedPlatform => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Whether a banner may be visible right now.
  bool get adsAllowed => _sdkReady.value && _suppressCount.value == 0;

  /// Non-personalized request with no targeting information.
  AdRequest get request => const AdRequest(nonPersonalizedAds: true);

  /// Requests consent (UMP, where legally required) then starts the SDK.
  Future<void> initialize() async {
    if (_started || !isSupportedPlatform) return;
    _started = true;
    try {
      final done = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () async {
          await ConsentForm.loadAndShowConsentFormIfRequired((FormError? e) {
            if (e != null) debugPrint('Consent form: ${e.message}');
          });
          if (!done.isCompleted) done.complete();
        },
        (FormError e) {
          debugPrint('Consent info update failed: ${e.message}');
          if (!done.isCompleted) done.complete();
        },
      );
      await done.future.timeout(const Duration(seconds: 20), onTimeout: () {});

      privacyOptionsRequired =
          await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;

      if (!await ConsentInformation.instance.canRequestAds()) return;
      await MobileAds.instance.initialize();
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(maxAdContentRating: MaxAdContentRating.g),
      );
      _sdkReady.value = true;
    } catch (e) {
      debugPrint('Ads unavailable: $e');
    }
  }

  /// Shows Google's privacy options form (only when required in the region).
  Future<void> showPrivacyOptions() async {
    if (!isSupportedPlatform) return;
    await ConsentForm.showPrivacyOptionsForm((FormError? e) {
      if (e != null) debugPrint('Privacy options: ${e.message}');
    });
  }

  /// Call when a breathing experience starts. Hides and disposes all banners.
  void suppress() => _suppressCount.value++;

  /// Call when the breathing experience ends.
  void release() {
    if (_suppressCount.value > 0) _suppressCount.value--;
  }
}
