import 'package:flutter/material.dart';

import '../l10n/l_text.dart';
import '../models/article.dart';
import '../theme/app_colors.dart';
import 'articles.dart';
import 'explore_breathing.dart';
import 'explore_herbs.dart';
import 'explore_yoga.dart';

class ExploreCategoryInfo {
  const ExploreCategoryInfo(this.category, this.name, this.description, this.icon, this.color);

  final ExploreCategory category;
  final LText name;
  final LText description;
  final IconData icon;
  final Color color;
}

const exploreCategories = <ExploreCategoryInfo>[
  ExploreCategoryInfo(
    ExploreCategory.yoga,
    LText('Yoga Asanas', 'योगासन'),
    LText('Gentle poses with step-by-step guidance.', 'चरण-दर-चरण मार्गदर्शन के साथ सरल आसन।'),
    Icons.self_improvement_rounded,
    AppColors.sage,
  ),
  ExploreCategoryInfo(
    ExploreCategory.pranayama,
    LText('Pranayama & Breath Tricks', 'प्राणायाम और श्वास तरकीबें'),
    LText('Traditional breathing and quick resets.', 'पारंपरिक श्वास और तुरंत रीसेट।'),
    Icons.air_rounded,
    AppColors.sky,
  ),
  ExploreCategoryInfo(
    ExploreCategory.calm,
    LText('Calm & Stress Relief', 'शांति और तनाव से राहत'),
    LText('Simple practices for busy minds.', 'व्यस्त मन के लिए आसान अभ्यास।'),
    Icons.spa_rounded,
    AppColors.lavender,
  ),
  ExploreCategoryInfo(
    ExploreCategory.herbs,
    LText('Herbs & Kitchen Wisdom', 'जड़ी-बूटियाँ और रसोई का ज्ञान'),
    LText('Haldi, tulsi and other traditional favourites.', 'हल्दी, तुलसी और अन्य पारंपरिक पसंदीदा।'),
    Icons.local_florist_rounded,
    AppColors.sun,
  ),
  ExploreCategoryInfo(
    ExploreCategory.lifestyle,
    LText('Better Lifestyle', 'बेहतर जीवनशैली'),
    LText('Small daily habits that add up.', 'छोटी रोज़ की आदतें जो फ़र्क लाती हैं।'),
    Icons.wb_sunny_rounded,
    AppColors.blush,
  ),
  ExploreCategoryInfo(
    ExploreCategory.guides,
    LText('Breathing Guides', 'श्वास गाइड'),
    LText('Friendly reads about breathing well.', 'अच्छी श्वास पर आसान लेख।'),
    Icons.menu_book_rounded,
    AppColors.mintDeep,
  ),
];

ExploreCategoryInfo exploreCategoryInfo(ExploreCategory c) => exploreCategories.firstWhere((i) => i.category == c);

ExploreCategory? exploreCategoryByName(String name) {
  for (final c in ExploreCategory.values) {
    if (c.name == name) return c;
  }
  return null;
}

final List<Article> allExploreItems = [
  ...yogaArticles,
  ...breathingArticles,
  ...calmArticles,
  ...herbArticles,
  ...lifestyleArticles,
  ...allArticles,
];

List<Article> exploreItemsIn(ExploreCategory c) => allExploreItems.where((a) => a.category == c).toList();

/// A different pick each day, rotating through everything.
Article explorePickOfTheDay(DateTime day) {
  final n = DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
  return allExploreItems[n % allExploreItems.length];
}

/// Case-insensitive search in both languages.
List<Article> searchExplore(String query, {ExploreCategory? category}) {
  final q = query.trim().toLowerCase();
  return allExploreItems.where((a) {
    if (category != null && a.category != category) return false;
    if (q.isEmpty) return true;
    final hay = [a.title.en, a.title.hi, a.summary.en, a.summary.hi, a.subtitle?.en ?? '', a.subtitle?.hi ?? '']
        .join(' ')
        .toLowerCase();
    return hay.contains(q);
  }).toList();
}
