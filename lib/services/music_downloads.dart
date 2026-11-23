import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/music.dart';
import 'audio_download_service.dart' show AudioError, AudioStatus, AudioTrackState;
import 'firebase_bootstrap.dart';
import 'music_library.dart';

/// Downloads music once into app storage for offline listening.
class MusicDownloads extends ChangeNotifier {
  MusicDownloads(this._library);

  final MusicLibrary _library;
  Directory? _dir;
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
        if (name.endsWith('.part')) {
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
    final part = File('${dir.path}/$id.mp3.part');
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
    if (_dir != null) await _quietDelete(File('${_dir!.path}/$id.mp3'));
    _set(id, AudioTrackState.none);
  }

  Future<void> deleteAll() async {
    for (final id in _states.keys.toList()) {
      await delete(id);
    }
  }

  Future<void> _quietDelete(File f) async {
    try {
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }
}
