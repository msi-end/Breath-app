import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/music_categories.dart';
import '../models/music.dart';
import 'firebase_bootstrap.dart';

enum LibraryStatus { loading, ready, offline, notConfigured, error }

/// The music catalog, read from `music/catalog.json` in Firebase Storage and
/// cached on the device so the library (and cover art) works offline.
class MusicLibrary extends ChangeNotifier {
  MusicLibrary(this._prefs);

  /// For tests and previews.
  MusicLibrary.withTracks(this._prefs, List<MusicTrack> tracks) : _demo = true {
    _tracks = tracks;
    status = LibraryStatus.ready;
  }

  static const catalogPath = 'music/catalog.json';
  static const _kCatalog = 'music.catalog.v1';
  static const _kUrls = 'music.urls.v1';
  static const shortTrackSeconds = 5 * 60;

  final SharedPreferences _prefs;
  bool _demo = false;
  List<MusicTrack> _tracks = const [];
  LibraryStatus status = LibraryStatus.loading;
  DateTime? lastUpdated;
  Directory? _coverDir;
  final Map<String, Future<File?>> _coverJobs = {};
  final Map<String, String> _urls = {};

  List<MusicTrack> get tracks => _tracks;
  bool get hasTracks => _tracks.isNotEmpty;

  Future<void> init() async {
    if (_demo) return;
    try {
      _coverDir = Directory('${(await getApplicationSupportDirectory()).path}/music_covers');
      await _coverDir!.create(recursive: true);
    } catch (e) {
      debugPrint('Cover cache unavailable: $e');
    }
    final urls = _prefs.getString(_kUrls);
    if (urls != null) {
      try {
        _urls.addAll(Map<String, String>.from(jsonDecode(urls) as Map));
      } catch (_) {}
    }
    final cached = _prefs.getString(_kCatalog);
    if (cached != null) {
      _parse(cached);
      status = LibraryStatus.ready;
      notifyListeners();
    }
    unawaited(refresh());
  }

  void _parse(String raw) {
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final list = (data['tracks'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((e) => MusicTrack.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      final ids = <String>{};
      _tracks = [
        for (final t in list)
          if (ids.add(t.id)) t,
      ];
      lastUpdated = DateTime.tryParse((data['updated'] as String?) ?? '');
    } catch (e) {
      debugPrint('Music catalog could not be read: $e');
    }
  }

  /// Fetches the latest catalog. Keeps the cached copy when offline.
  Future<void> refresh() async {
    if (_demo) return;
    if (!FirebaseBootstrap.available) {
      status = hasTracks ? LibraryStatus.ready : LibraryStatus.notConfigured;
      notifyListeners();
      return;
    }
    if (!hasTracks) {
      status = LibraryStatus.loading;
      notifyListeners();
    }
    try {
      final bytes = await FirebaseStorage.instance
          .ref(catalogPath)
          .getData(4 * 1024 * 1024)
          .timeout(const Duration(seconds: 20));
      if (bytes != null) {
        final raw = utf8.decode(bytes);
        _parse(raw);
        await _prefs.setString(_kCatalog, raw);
      }
      status = LibraryStatus.ready;
    } on FirebaseException catch (e) {
      debugPrint('Music catalog: ${e.code}');
      status = hasTracks
          ? LibraryStatus.ready
          : (e.code == 'object-not-found' ? LibraryStatus.ready : LibraryStatus.offline);
    } catch (e) {
      debugPrint('Music catalog: $e');
      status = hasTracks ? LibraryStatus.ready : LibraryStatus.offline;
    }
    notifyListeners();
  }

  MusicTrack? byId(String id) {
    for (final t in _tracks) {
      if (t.id == id) return t;
    }
    return null;
  }

  List<MusicTrack> byIds(Iterable<String> ids) => [for (final id in ids) ?byId(id)];

  List<MusicTrack> inCategory(String categoryId) {
    if (categoryId == 'short') {
      return _tracks
          .where((t) => t.categoryId == 'short' || (t.durationSeconds > 0 && t.durationSeconds <= shortTrackSeconds))
          .toList();
    }
    return _tracks.where((t) => t.categoryId == categoryId).toList();
  }

  /// Categories that currently have at least one track.
  List<MusicCategory> get activeCategories => musicCategories.where((c) => inCategory(c.id).isNotEmpty).toList();

  List<MusicTrack> get featured {
    final f = _tracks.where((t) => t.featured).toList();
    if (f.isNotEmpty) return f;
    return sorted(_tracks, MusicSort.newest).take(8).toList();
  }

  List<MusicTrack> search(String query, {String? categoryId, MusicSort sort = MusicSort.featured, String lang = 'en'}) {
    final q = query.trim().toLowerCase();
    Iterable<MusicTrack> list = categoryId == null ? _tracks : inCategory(categoryId);
    if (q.isNotEmpty) {
      list = list.where((t) {
        final cat = musicCategoryById(t.categoryId);
        return t.title.toLowerCase().contains(q) ||
            (t.titleHi?.toLowerCase().contains(q) ?? false) ||
            t.artist.toLowerCase().contains(q) ||
            (cat != null && (cat.name.en.toLowerCase().contains(q) || cat.name.hi.contains(q)));
      });
    }
    return sorted(list.toList(), sort, lang: lang);
  }

  static List<MusicTrack> sorted(List<MusicTrack> input, MusicSort sort, {String lang = 'en'}) {
    final list = [...input];
    switch (sort) {
      case MusicSort.featured:
        list.sort((a, b) => (b.featured ? 1 : 0) - (a.featured ? 1 : 0));
      case MusicSort.titleAz:
        list.sort((a, b) => a.titleFor(lang).toLowerCase().compareTo(b.titleFor(lang).toLowerCase()));
      case MusicSort.artistAz:
        list.sort((a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()));
      case MusicSort.shortest:
        list.sort((a, b) => a.durationSeconds.compareTo(b.durationSeconds));
      case MusicSort.longest:
        list.sort((a, b) => b.durationSeconds.compareTo(a.durationSeconds));
      case MusicSort.newest:
        final epoch = DateTime(2000);
        list.sort((a, b) => (b.added ?? epoch).compareTo(a.added ?? epoch));
    }
    return list;
  }

  // ---------- Covers ----------

  /// Cached cover file, downloading it once when online. Null = use the
  /// generated artwork.
  Future<File?> coverFile(String key, String? storagePath) {
    if (storagePath == null || storagePath.isEmpty || _demo) return Future.value(null);
    return _coverJobs.putIfAbsent(key, () => _loadCover(key, storagePath));
  }

  File? cachedCoverSync(String key) {
    final dir = _coverDir;
    if (dir == null) return null;
    final f = File('${dir.path}/$key.img');
    return f.existsSync() ? f : null;
  }

  Future<File?> _loadCover(String key, String path) async {
    final dir = _coverDir;
    if (dir == null) return null;
    final file = File('${dir.path}/$key.img');
    if (await file.exists()) return file;
    if (!FirebaseBootstrap.available) return null;
    try {
      final data = await FirebaseStorage.instance
          .ref(path)
          .getData(6 * 1024 * 1024)
          .timeout(const Duration(seconds: 20));
      if (data == null) return null;
      await file.writeAsBytes(data, flush: true);
      return file;
    } catch (e) {
      _coverJobs.remove(key); // allow a retry later
      return null;
    }
  }

  // ---------- Streaming URLs ----------

  /// A streamable URL for [track], cached so it is resolved only once.
  Future<String?> streamUrl(MusicTrack track) async {
    final cached = _urls[track.id];
    if (cached != null) return cached;
    if (!FirebaseBootstrap.available || track.audioPath.isEmpty) return null;
    try {
      final url = await FirebaseStorage.instance
          .ref(track.audioPath)
          .getDownloadURL()
          .timeout(const Duration(seconds: 12));
      _urls[track.id] = url;
      unawaited(_prefs.setString(_kUrls, jsonEncode(_urls)));
      return url;
    } catch (e) {
      debugPrint('No stream URL for ${track.id}: $e');
      return null;
    }
  }

  Future<void> clearCaches() async {
    _urls.clear();
    _coverJobs.clear();
    await _prefs.remove(_kUrls);
    try {
      if (_coverDir != null && await _coverDir!.exists()) {
        await _coverDir!.delete(recursive: true);
        await _coverDir!.create(recursive: true);
      }
    } catch (_) {}
  }
}
