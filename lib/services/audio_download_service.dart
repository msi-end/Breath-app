import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/technique.dart';
import 'firebase_bootstrap.dart';

enum AudioStatus { notDownloaded, downloading, downloaded, failed }

/// Error codes surfaced to the UI (localized there).
enum AudioError { notConfigured, notFound, network, storage }

class AudioTrackState {
  const AudioTrackState(this.status, {this.progress = 0, this.error, this.bytes = 0});

  final AudioStatus status;
  final double progress;
  final AudioError? error;
  final int bytes;

  static const none = AudioTrackState(AudioStatus.notDownloaded);
}

/// Downloads guidance MP3s from Firebase Storage once, keeps them on the
/// device and serves them for offline playback.
class AudioDownloadService extends ChangeNotifier {
  Directory? _dir;
  final Map<String, AudioTrackState> _states = {};
  final Map<String, DownloadTask> _tasks = {};

  Future<void> init() async {
    try {
      final base = await getApplicationSupportDirectory();
      final dir = Directory('${base.path}/guidance_audio');
      if (!await dir.exists()) await dir.create(recursive: true);
      _dir = dir;
      await for (final entity in dir.list()) {
        if (entity is File) {
          final name = entity.uri.pathSegments.last;
          if (name.endsWith('.part')) {
            await entity.delete();
          } else if (name.endsWith('.mp3')) {
            final id = name.substring(0, name.length - 4);
            _states[id] = AudioTrackState(AudioStatus.downloaded, progress: 1, bytes: await entity.length());
          }
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Audio storage unavailable: $e');
    }
  }

  bool get cloudAvailable => FirebaseBootstrap.available;

  AudioTrackState stateOf(String id) => _states[id] ?? AudioTrackState.none;

  String? localPath(String id) =>
      stateOf(id).status == AudioStatus.downloaded && _dir != null ? '${_dir!.path}/$id.mp3' : null;

  List<String> get downloadedIds =>
      _states.entries.where((e) => e.value.status == AudioStatus.downloaded).map((e) => e.key).toList();

  int get totalBytes =>
      _states.values.where((s) => s.status == AudioStatus.downloaded).fold(0, (sum, s) => sum + s.bytes);

  void _set(String id, AudioTrackState state) {
    _states[id] = state;
    notifyListeners();
  }

  /// Downloads the track for [technique] unless it is already on the device.
  Future<void> download(Technique technique) async {
    final id = technique.id;
    final current = stateOf(id).status;
    if (current == AudioStatus.downloaded || current == AudioStatus.downloading) return;
    if (!cloudAvailable) {
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
      final task = FirebaseStorage.instance.ref(technique.audioStoragePath).writeToFile(part);
      _tasks[id] = task;
      sub = task.snapshotEvents.listen((snap) {
        if (snap.totalBytes > 0 && stateOf(id).status == AudioStatus.downloading) {
          _set(id, AudioTrackState(AudioStatus.downloading, progress: snap.bytesTransferred / snap.totalBytes));
        }
      }, onError: (_) {});
      await task;
      await part.rename(target.path);
      _set(id, AudioTrackState(AudioStatus.downloaded, progress: 1, bytes: await target.length()));
    } on FirebaseException catch (e) {
      await _deleteQuietly(part);
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
    } catch (e) {
      await _deleteQuietly(part);
      _set(id, const AudioTrackState(AudioStatus.failed, error: AudioError.network));
    } finally {
      await sub?.cancel();
      _tasks.remove(id);
    }
  }

  Future<void> cancel(String id) async {
    await _tasks[id]?.cancel();
  }

  Future<void> delete(String id) async {
    await cancel(id);
    if (_dir != null) await _deleteQuietly(File('${_dir!.path}/$id.mp3'));
    _set(id, AudioTrackState.none);
  }

  Future<void> deleteAll() async {
    for (final id in _states.keys.toList()) {
      await delete(id);
    }
  }

  Future<void> _deleteQuietly(File f) async {
    try {
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }
}
