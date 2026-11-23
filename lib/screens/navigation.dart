import 'package:flutter/material.dart';

import '../data/moods.dart';
import '../models/article.dart';
import '../models/technique.dart';
import 'article_screen.dart';
import 'breathing_session_screen.dart';
import 'challenges_screen.dart';
import 'emergency_calm_screen.dart';
import 'favorites_screen.dart';
import 'mood_results_screen.dart';
import 'technique_detail_screen.dart';
import 'techniques_screen.dart';

Future<T?> _push<T>(BuildContext context, Widget page, {bool fullscreen = false}) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => page, fullscreenDialog: fullscreen));

void openTechniques(BuildContext context) => _push(context, const TechniquesScreen());

void openTechnique(BuildContext context, Technique t) => _push(context, TechniqueDetailScreen(technique: t));

void startSession(BuildContext context, Technique t, {int? minutes, bool? gentle}) => _push(
  context,
  BreathingSessionScreen(technique: t, minutes: minutes ?? t.recommendedMinutes, gentle: gentle),
  fullscreen: true,
);

void openEmergencyCalm(BuildContext context) => _push(context, const EmergencyCalmScreen(), fullscreen: true);

void openMoodResults(BuildContext context, Mood mood) => _push(context, MoodResultsScreen(mood: mood));

void openChallenges(BuildContext context) => _push(context, const ChallengesScreen());

void openFavorites(BuildContext context) => _push(context, const FavoritesScreen());

void openArticle(BuildContext context, Article a) => _push(context, ArticleScreen(article: a));
