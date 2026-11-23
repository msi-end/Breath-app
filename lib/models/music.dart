import 'package:flutter/material.dart';

import '../l10n/l_text.dart';

class MusicCategory {
  const MusicCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.colors,
  });

  final String id;
  final LText name;
  final LText description;
  final IconData icon;

  /// Gradient used for the category card and generated cover art.
  final List<Color> colors;

  /// Optional cover image in Firebase Storage.
  String get coverPath => 'music/covers/categories/$id.jpg';
}

/// One audio track. Catalog tracks come from `music/catalog.json` in
/// Firebase Storage; guidance tracks are local-only.
class MusicTrack {
  const MusicTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.categoryId,
    this.titleHi,
    this.description = '',
    this.descriptionHi,
    this.durationSeconds = 0,
    this.audioPath = '',
    this.coverPath,
    this.added,
    this.featured = false,
    this.localPath,
  });

  final String id;
  final String title;
  final String? titleHi;
  final String artist;
  final String categoryId;
  final String description;
  final String? descriptionHi;
  final int durationSeconds;

  /// Path of the MP3 in Firebase Storage.
  final String audioPath;

  /// Path of the cover image in Firebase Storage (square JPG/PNG/WebP).
  final String? coverPath;
  final DateTime? added;
  final bool featured;

  /// For local-only audio such as downloaded breathing guidance.
  final String? localPath;

  bool get isLocalOnly => localPath != null;

  String titleFor(String lang) => lang == 'hi' && (titleHi?.isNotEmpty ?? false) ? titleHi! : title;

  String descriptionFor(String lang) =>
      lang == 'hi' && (descriptionHi?.isNotEmpty ?? false) ? descriptionHi! : description;

  factory MusicTrack.fromJson(Map<String, dynamic> j) {
    final id = (j['id'] as String).trim();
    return MusicTrack(
      id: id,
      title: (j['title'] as String?)?.trim() ?? id,
      titleHi: j['title_hi'] as String?,
      artist: (j['artist'] as String?)?.trim() ?? '',
      categoryId: (j['category'] as String?)?.trim() ?? 'relaxation',
      description: (j['description'] as String?) ?? '',
      descriptionHi: j['description_hi'] as String?,
      durationSeconds: (j['duration'] as num?)?.toInt() ?? 0,
      audioPath: (j['audio'] as String?) ?? 'music/audio/$id.mp3',
      coverPath: j['cover'] as String?,
      added: DateTime.tryParse((j['added'] as String?) ?? ''),
      featured: j['featured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    if (titleHi != null) 'title_hi': titleHi,
    'artist': artist,
    'category': categoryId,
    'description': description,
    if (descriptionHi != null) 'description_hi': descriptionHi,
    'duration': durationSeconds,
    'audio': audioPath,
    if (coverPath != null) 'cover': coverPath,
    if (added != null) 'added': added!.toIso8601String().substring(0, 10),
    'featured': featured,
  };
}

class Playlist {
  Playlist({required this.id, required this.name, required this.trackIds, required this.created});

  final String id;
  String name;
  final List<String> trackIds;
  final DateTime created;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'tracks': trackIds,
    'created': created.millisecondsSinceEpoch,
  };

  factory Playlist.fromJson(Map<String, dynamic> j) => Playlist(
    id: j['id'] as String,
    name: j['name'] as String,
    trackIds: (j['tracks'] as List<dynamic>).cast<String>().toList(),
    created: DateTime.fromMillisecondsSinceEpoch((j['created'] as num).toInt()),
  );
}

enum MusicSort { featured, titleAz, artistAz, shortest, longest, newest }
