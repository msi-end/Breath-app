import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/strings.dart';
import '../models/article.dart';

/// YouTube's brand red, used only on the "Watch on YouTube" buttons.
const youtubeRed = Color(0xFFE62117);

/// Opens a YouTube search for [article] in the YouTube app (or browser).
Future<void> openYoutube(BuildContext context, Article article) async {
  final uri = article.youtubeSearchUri;
  if (uri == null) return;
  final messenger = ScaffoldMessenger.of(context);
  final failed = context.s.youtubeFailed;
  var ok = false;
  try {
    ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {}
  if (!ok) messenger.showSnackBar(SnackBar(content: Text(failed)));
}

/// Small round play button for cards.
class YoutubeChip extends StatelessWidget {
  const YoutubeChip({super.key, required this.article, this.compact = false});

  final Article article;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    if (compact) {
      return Semantics(
        button: true,
        label: s.watchOnYoutube,
        child: Material(
          color: Colors.white,
          shape: const StadiumBorder(),
          elevation: 0,
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: () => openYoutube(context, article),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Icon(Icons.smart_display_rounded, color: youtubeRed, size: 22),
            ),
          ),
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: () => openYoutube(context, article),
      icon: const Icon(Icons.smart_display_rounded, color: youtubeRed),
      label: Text(s.watchOnYoutube),
    );
  }
}
