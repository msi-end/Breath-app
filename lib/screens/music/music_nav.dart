import 'package:flutter/material.dart';

import '../../models/music.dart';
import 'music_category_screen.dart';
import 'music_player_screen.dart';
import 'music_search_screen.dart';
import 'my_music_screen.dart';
import 'playlist_screen.dart';

void openMusicPlayerScreen(BuildContext context) => Navigator.of(context, rootNavigator: true).push(
  PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 380),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, _, _) => const MusicPlayerScreen(),
    transitionsBuilder: (_, a, _, child) => SlideTransition(
      position: Tween(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic)),
      child: child,
    ),
  ),
);

void openMusicCategory(BuildContext context, MusicCategory c) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => MusicCategoryScreen(category: c)));

void openMusicSearch(BuildContext context, {String? categoryId}) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => MusicSearchScreen(initialCategory: categoryId)));

void openMyMusic(BuildContext context, {int tab = 0}) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => MyMusicScreen(initialTab: tab)));

void openPlaylist(BuildContext context, Playlist p) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlaylistScreen(playlistId: p.id)));
