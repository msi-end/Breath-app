import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/music.dart';
import 'audio_download_service.dart' show AudioError, AudioStatus, AudioTrackState;
import 'firebase_bootstrap.dart';
import 'music_library.dart';

/// Keeps music in app storage so a track is fetched from the server only
/// once: either downloaded on request, or saved automatically the first time
/// it's played (see [MusicPlayer]). Saved tracks then always play offline.
class MusicDownloads extends ChangeNotifier {
  MusicDownloads(this._library, [this._prefs]);

  static const _kAutoSave = 'music.autoSave';

  final MusicLibrary _library;
  final SharedPreferences? _prefs;
  Directory? _dir;

  /// Save every track the first time it's streamed (on by default).
  bool get autoSave => _prefs?.getBool(_kAutoSave) ?? true;

  Future<void> setAutoSave(bool v) async {
    await _prefs?.setBool(_kAutoSave, v);
    notifyListeners();
  }

  /// Where a track is (or will be) stored. Used by the player's
  /// save-while-playing cache, so both paths share one file per track.
  File? fileFor(String id) => _dir == null ? null : File('${_dir!.path}/$id.mp3');

  /// Called when the player has finished saving a streamed track.
  Future<void> markSaved(MusicTrack track) async {
    final f = fileFor(track.id);
    if (f == null || !await f.exists() || isDownloaded(track.id)) return;
    unawaited(_library.coverFile(track.id, track.coverPath));
    _set(track.id, AudioTrackState(AudioStatus.downloaded, progress: 1, bytes: await f.length()));
  }
  final Map<String, AudioTrackState> _states = {};
  final Map<String, DownloadTask> _tasks = {};

  Future<void> init() async {
    try {
      final dir = Directory('${(await getApplicationSupportDirectory()).path}/music_downloads');
      await dir.create(recursive: true);
      _dir = dir;
      await for (final e in dir.list()) {
        if (e is! File) continue;
        final name = e.uri.pathSegments.last;
        if (name.endsWith('.part') || name.endsWith('.dl')) {
          await e.delete();
        } else if (name.endsWith('.mp3')) {
          _states[name.substring(0, name.length - 4)] = AudioTrackState(
            AudioStatus.downloaded,
            progress: 1,
            bytes: await e.length(),
          );
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Music downloads unavailable: $e');
    }
  }

  AudioTrackState stateOf(String id) => _states[id] ?? AudioTrackState.none;

  bool isDownloaded(String id) => stateOf(id).status == AudioStatus.downloaded;

  String? localPath(String id) => isDownloaded(id) && _dir != null ? '${_dir!.path}/$id.mp3' : null;

  List<String> get downloadedIds =>
      _states.entries.where((e) => e.value.status == AudioStatus.downloaded).map((e) => e.key).toList();

  int get totalBytes => _states.values.where((s) => s.status == AudioStatus.downloaded).fold(0, (a, s) => a + s.bytes);

  void _set(String id, AudioTrackState s) {
    _states[id] = s;
    notifyListeners();
  }

  /// Downloads [track] unless it's already on the device (or downloading).
  Future<void> download(MusicTrack track) async {
    final id = track.id;
    final st = stateOf(id).status;
    if (st == AudioStatus.downloaded || st == AudioStatus.downloading) return;
    if (!FirebaseBootstrap.available) {
      _set(id, const AudioTrackState(AudioStatus.failed, error: AudioError.notConfigured));
      return;
    }
    final dir = _dir;
    if (dir == null) {
      _set(id, const AudioTrackState(AudioStatus.failed, error: AudioError.storage));
      return;
    }
    final part = File('${dir.path}/$id.mp3.dl');
    final target = File('${dir.path}/$id.mp3');
    _set(id, const AudioTrackState(AudioStatus.downloading));
    StreamSubscription<TaskSnapshot>? sub;
    try {
      final task = FirebaseStorage.instance.ref(track.audioPath).writeToFile(part);
      _tasks[id] = task;
      sub = task.snapshotEvents.listen((snap) {
        if (snap.totalBytes > 0 && stateOf(id).status == AudioStatus.downloading) {
          _set(id, AudioTrackState(AudioStatus.downloading, progress: snap.bytesTransferred / snap.totalBytes));
        }
      }, onError: (_) {});
      await task;
      await part.rename(target.path);
      // Keep the cover offline as well.
      unawaited(_library.coverFile(id, track.coverPath));
      _set(id, AudioTrackState(AudioStatus.downloaded, progress: 1, bytes: await target.length()));
    } on FirebaseException catch (e) {
      await _quietDelete(part);
      if (e.code == 'canceled') {
        _set(id, AudioTrackState.none);
      } else {
        _set(
          id,
          AudioTrackState(
            AudioStatus.failed,
            error: e.code == 'object-not-found' ? AudioError.notFound : AudioError.network,
          ),
        );
      }
    } catch (_) {
      await _quietDelete(part);
      _set(id, const AudioTrackState(AudioStatus.failed, error: AudioError.network));
    } finally {
      await sub?.cancel();
      _tasks.remove(id);
    }
  }

  Future<void> cancel(String id) async => _tasks[id]?.cancel();

  Future<void> delete(String id) async {
    await cancel(id);
    if (_dir != null) {
      for (final ext in ['', '.mime', '.part']) {
        await _quietDelete(File('${_dir!.path}/$id.mp3$ext'));
      }
    }
    _set(id, AudioTrackState.none);
  }

  Future<void> deleteAll() async {
    for (final id in _states.keys.toList()) {
      await delete(id);
    }
    // Also remove any partly saved files.
    final dir = _dir;
    if (dir == null) return;
    try {
      await for (final e in dir.list()) {
        if (e is File) await _quietDelete(e);
      }
    } catch (_) {}
  }

  Future<void> _quietDelete(File f) async {
    try {
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }
}
