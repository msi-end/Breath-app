import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/ad_config.dart';
import '../l10n/strings.dart';
import '../services/ads_service.dart';

/// A small, clearly-labelled banner. Renders nothing when ads are not allowed
/// (offline, no consent, unsupported platform, or a breathing session is
/// active).
class BannerAdSlot extends StatefulWidget {
  const BannerAdSlot({super.key, this.padding = const EdgeInsets.symmetric(vertical: 12)});

  final EdgeInsets padding;

  @override
  State<BannerAdSlot> createState() => _BannerAdSlotState();
}

class _BannerAdSlotState extends State<BannerAdSlot> {
  final _ads = AdsService.instance;
  BannerAd? _banner;
  bool _loaded = false;

  /// False while this slot is on a hidden tab or under another route.
  bool? _visible;

  bool get _shouldShow => _ads.adsAllowed && _visible == true;

  @override
  void initState() {
    super.initState();
    _ads.changes.addListener(_sync);
    // The first _sync happens in didChangeDependencies, once visibility is known.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final visible = TickerMode.of(context);
    if (visible != _visible) {
      _visible = visible;
      _sync();
    }
  }

  void _sync() {
    if (!mounted) return;
    if (_shouldShow) {
      if (_banner == null) _load();
    } else {
      _disposeAd();
      setState(() {});
    }
  }

  void _load() {
    final ad = BannerAd(
      adUnitId: AdConfig.bannerUnitId,
      size: AdSize.banner,
      request: _ads.request,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _banner = null;
              _loaded = false;
            });
          }
        },
      ),
    );
    _banner = ad;
    ad.load();
  }

  void _disposeAd() {
    _banner?.dispose();
    _banner = null;
    _loaded = false;
  }

  @override
  void dispose() {
    _ads.changes.removeListener(_sync);
    _disposeAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = _banner;
    if (!_shouldShow || banner == null || !_loaded) return const SizedBox.shrink();
    return Padding(
      padding: widget.padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.s.advertisement,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45)),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: banner.size.width.toDouble(),
            height: banner.size.height.toDouble(),
            child: AdWidget(ad: banner),
          ),
        ],
      ),
    );
  }
}
