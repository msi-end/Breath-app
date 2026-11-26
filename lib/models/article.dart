import 'package:flutter/material.dart';

import '../l10n/l_text.dart';

/// Explore sections. Every Explore item is an [Article] in one of these.
enum ExploreCategory { yoga, pranayama, calm, herbs, lifestyle, guides }

class ArticleSection {
  const ArticleSection({this.heading, required this.body, this.bullets = const []});

  final LText? heading;
  final LText body;
  final List<LText> bullets;
}

class Article {
  const Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.readMinutes,
    required this.icon,
    required this.color,
    required this.sections,
    this.category = ExploreCategory.guides,
    this.subtitle,
    this.youtubeQuery,
  });

  final String id;
  final LText title;
  final LText summary;
  final int readMinutes;
  final IconData icon;
  final Color color;
  final List<ArticleSection> sections;
  final ExploreCategory category;

  /// A secondary name, e.g. the Sanskrit name of a yoga pose.
  final LText? subtitle;

  /// When set, the item shows a "Watch on YouTube" button that searches
  /// YouTube for this phrase.
  final String? youtubeQuery;

  Uri? get youtubeSearchUri => youtubeQuery == null
      ? null
      : Uri.https('www.youtube.com', '/results', {'search_query': youtubeQuery!});
}

/// Shared section headings for Explore content.
class Headings {
  Headings._();
  static const how = LText('How to do it', 'कैसे करें');
  static const why = LText('Why people enjoy it', 'लोग इसे क्यों पसंद करते हैं');
  static const gently = LText('Go gently', 'धीरे और सावधानी से');
  static const traditional = LText('Traditional use', 'पारंपरिक उपयोग');
  static const ways = LText('Simple ways to enjoy it', 'इस्तेमाल के आसान तरीके');
  static const goodToKnow = LText('Good to know', 'ध्यान रखें');
  static const tryThis = LText('Try this', 'ऐसे आज़माएँ');
}
