import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/music.dart';

/// Favorites, recently played and playlists — stored on the device.
class MyMusicStore extends ChangeNotifier {
  MyMusicStore(this._prefs) {
    _favorites.addAll(_prefs.getStringList(_kFav) ?? const []);
    _recent.addAll(_prefs.getStringList(_kRecent) ?? const []);
    final raw = _prefs.getString(_kPlaylists);
    if (raw != null) {
      try {
        _playlists.addAll(
          (jsonDecode(raw) as List<dynamic>).map((e) => Playlist.fromJson(Map<String, dynamic>.from(e as Map))),
        );
      } catch (_) {}
    }
  }

  static const _kFav = 'music.favorites.v1';
  static const _kRecent = 'music.recent.v1';
  static const _kPlaylists = 'music.playlists.v1';
  static const maxRecent = 30;

  final SharedPreferences _prefs;
  final List<String> _favorites = [];
  final List<String> _recent = [];
  final List<Playlist> _playlists = [];

  List<String> get favoriteIds => List.unmodifiable(_favorites);
  List<String> get recentIds => List.unmodifiable(_recent);
  List<Playlist> get playlists => List.unmodifiable(_playlists);

  bool isFavorite(String id) => _favorites.contains(id);

  Future<void> toggleFavorite(String id) async {
    if (!_favorites.remove(id)) _favorites.insert(0, id);
    notifyListeners();
    await _prefs.setStringList(_kFav, _favorites);
  }

  Future<void> markPlayed(String id) async {
    _recent
      ..remove(id)
      ..insert(0, id);
    if (_recent.length > maxRecent) _recent.removeRange(maxRecent, _recent.length);
    notifyListeners();
    await _prefs.setStringList(_kRecent, _recent);
  }

  Future<void> clearRecent() async {
    _recent.clear();
    notifyListeners();
    await _prefs.remove(_kRecent);
  }

  Playlist? playlist(String id) {
    for (final p in _playlists) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<Playlist> createPlaylist(String name, {List<String> trackIds = const []}) async {
    final p = Playlist(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      trackIds: [...trackIds],
      created: DateTime.now(),
    );
    _playlists.insert(0, p);
    await _savePlaylists();
    return p;
  }

  Future<void> renamePlaylist(String id, String name) async {
    playlist(id)?.name = name.trim();
    await _savePlaylists();
  }

  Future<void> deletePlaylist(String id) async {
    _playlists.removeWhere((p) => p.id == id);
    await _savePlaylists();
  }

  /// Returns false when the track was already in the playlist.
  Future<bool> addToPlaylist(String playlistId, String trackId) async {
    final p = playlist(playlistId);
    if (p == null || p.trackIds.contains(trackId)) return false;
    p.trackIds.add(trackId);
    await _savePlaylists();
    return true;
  }

  Future<void> removeFromPlaylist(String playlistId, String trackId) async {
    playlist(playlistId)?.trackIds.remove(trackId);
    await _savePlaylists();
  }

  Future<void> reorderPlaylist(String playlistId, int oldIndex, int newIndex) async {
    final p = playlist(playlistId);
    if (p == null) return;
    if (newIndex > oldIndex) newIndex--;
    final id = p.trackIds.removeAt(oldIndex);
    p.trackIds.insert(newIndex, id);
    await _savePlaylists();
  }

  Future<void> _savePlaylists() async {
    notifyListeners();
    await _prefs.setString(_kPlaylists, jsonEncode(_playlists.map((p) => p.toJson()).toList()));
  }

  Future<void> clear() async {
    _favorites.clear();
    _recent.clear();
    _playlists.clear();
    notifyListeners();
    for (final k in [_kFav, _kRecent, _kPlaylists]) {
      await _prefs.remove(k);
    }
  }
}
