import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/music_categories.dart';
import '../models/music.dart';
import 'firebase_bootstrap.dart';
import 'music_downloads.dart';
import 'music_library.dart';
import 'my_music_store.dart';

enum MusicError { offline, notConfigured, playback }

enum MusicRepeat { off, all, one }

/// The app's single audio player (music and breathing guidance).
///
/// Built on just_audio + just_audio_background, so playback continues in the
/// background and on the lock screen with notification media controls, and
/// keeps playing while the user moves between tabs.
class MusicPlayer extends ChangeNotifier {
  MusicPlayer(this._prefs, this._library, this._downloads, this._mine) {
    _repeat = MusicRepeat.values[(_prefs.getInt(_kRepeat) ?? 0).clamp(0, 2)];
    _shuffle = _prefs.getBool(_kShuffle) ?? false;
    _readLastSession();
  }

  static const _kLast = 'music.last.v1';
  static const _kRepeat = 'music.repeat';
  static const _kShuffle = 'music.shuffle';
  static const guidancePrefix = 'guide_';

  final SharedPreferences _prefs;
  final MusicLibrary _library;
  final MusicDownloads _downloads;
  final MyMusicStore _mine;

  AudioPlayer? _player;
  final List<StreamSubscription<dynamic>> _subs = [];
  List<MusicTrack> _queue = const [];
  int? _index;
  bool loading = false;
  MusicError? error;
  int skippedOffline = 0;
  MusicRepeat _repeat = MusicRepeat.off;
  bool _shuffle = false;

  // Last session restored on launch (shown in the mini player, loaded on play).
  MusicTrack? _pendingTrack;
  List<String> _pendingQueue = const [];
  Duration _pendingPosition = Duration.zero;
  Timer? _saveTimer;

  AudioPlayer get player => _player ??= _createPlayer();

  bool get isLoaded => _index != null && _queue.isNotEmpty;

  MusicTrack? get current => isLoaded ? _queue[_index!.clamp(0, _queue.length - 1)] : _pendingTrack;

  bool get hasSession => current != null;

  bool get isPlaying => _player?.playing ?? false;

  bool get hasNext => isLoaded && (_player?.hasNext ?? false);

  List<MusicTrack> get queue => _queue;

  MusicRepeat get repeat => _repeat;

  bool get shuffle => _shuffle;

  bool isCurrent(String id) => current?.id == id;

  AudioPlayer _createPlayer() {
    final p = AudioPlayer();
    _subs.addAll([
      p.currentIndexStream.listen(_onIndex),
      p.playerStateStream.listen((s) {
        if (s.processingState == ProcessingState.ready || s.processingState == ProcessingState.completed) {
          if (loading) loading = false;
        }
        notifyListeners();
        _scheduleSave();
      }),
      p.errorStream.listen(_onError),
    ]);
    unawaited(p.setLoopMode(_loopFor(_repeat)));
    unawaited(p.setShuffleModeEnabled(_shuffle));
    return p;
  }

  void _onIndex(int? i) {
    if (i == null || i >= _queue.length) return;
    _index = i;
    error = null;
    final t = _queue[i];
    if (!t.id.startsWith(guidancePrefix)) unawaited(_mine.markPlayed(t.id));
    notifyListeners();
    _scheduleSave();
  }

  void _onError(PlayerException e) {
    debugPrint('Playback error: ${e.code} ${e.message}');
    final t = current;
    final local = t != null && (t.isLocalOnly || _downloads.isDownloaded(t.id));
    error = local ? MusicError.playback : MusicError.offline;
    loading = false;
    notifyListeners();
    // Try the next track so one bad file doesn't stop the session.
    if (_player?.hasNext ?? false) unawaited(_player!.seekToNext());
  }

  static LoopMode _loopFor(MusicRepeat r) => switch (r) {
    MusicRepeat.off => LoopMode.off,
    MusicRepeat.all => LoopMode.all,
    MusicRepeat.one => LoopMode.one,
  };

  Future<AudioSource?> _sourceFor(MusicTrack t) async {
    final tag = MediaItem(
      id: t.id,
      title: t.title,
      artist: t.artist.isEmpty ? 'BreatheCare' : t.artist,
      album: musicCategoryById(t.categoryId)?.name.en ?? 'BreatheCare',
      duration: t.durationSeconds > 0 ? Duration(seconds: t.durationSeconds) : null,
      artUri: _library.cachedCoverSync(t.id)?.uri,
    );
    if (t.localPath != null) return AudioSource.file(t.localPath!, tag: tag);
    final local = _downloads.localPath(t.id);
    if (local != null && File(local).existsSync()) return AudioSource.file(local, tag: tag);
    final url = await _library.streamUrl(t);
    if (url == null) return null;
    return AudioSource.uri(Uri.parse(url), tag: tag);
  }

  /// Plays [tracks] starting at [index]. Tracks that can't be reached
  /// (offline and not downloaded) are skipped.
  Future<void> playQueue(List<MusicTrack> tracks, {int index = 0, Duration? position, bool autoplay = true}) async {
    if (tracks.isEmpty) return;
    loading = true;
    error = null;
    skippedOffline = 0;
    _pendingTrack = tracks[index.clamp(0, tracks.length - 1)];
    notifyListeners();

    final sources = await Future.wait(tracks.map(_sourceFor));
    final playable = <MusicTrack>[];
    final audio = <AudioSource>[];
    var start = 0;
    for (var i = 0; i < tracks.length; i++) {
      final s = sources[i];
      if (s == null) {
        skippedOffline++;
        continue;
      }
      if (i == index) start = playable.length;
      playable.add(tracks[i]);
      audio.add(s);
    }
    if (audio.isEmpty) {
      loading = false;
      error = FirebaseBootstrap.available ? MusicError.offline : MusicError.notConfigured;
      notifyListeners();
      return;
    }
    _queue = playable;
    _index = start;
    _pendingTrack = null;
    try {
      await player.setAudioSources(audio, initialIndex: start, initialPosition: position);
      if (autoplay) unawaited(player.play());
    } on PlayerInterruptedException {
      // A newer request replaced this one.
    } catch (e) {
      debugPrint('Could not start playback: $e');
      error = MusicError.playback;
    }
    loading = false;
    notifyListeners();
    _scheduleSave();
  }

  Future<void> playTrack(MusicTrack track, {List<MusicTrack>? context}) async {
    final list = context ?? [track];
    final i = list.indexWhere((t) => t.id == track.id);
    if (isCurrent(track.id) && isLoaded) {
      if (!isPlaying) await player.play();
      return;
    }
    await playQueue(list, index: i < 0 ? 0 : i);
  }

  /// Plays a downloaded breathing-guidance file through the same player.
  Future<void> playGuidance({required String techniqueId, required String title, required String path}) => playQueue([
    MusicTrack(
      id: '$guidancePrefix$techniqueId',
      title: title,
      artist: 'BreatheCare',
      categoryId: 'guided',
      localPath: path,
    ),
  ]);

  Future<void> shufflePlay(List<MusicTrack> tracks) async {
    if (!_shuffle) await toggleShuffle();
    final copy = [...tracks]..shuffle();
    await playQueue(copy);
  }

  Future<void> togglePlay() async {
    if (!isLoaded) {
      final t = _pendingTrack;
      if (t == null) return;
      final q = _library.byIds(_pendingQueue);
      final list = q.isEmpty ? [t] : q;
      final i = list.indexWhere((x) => x.id == t.id);
      await playQueue(list, index: i < 0 ? 0 : i, position: _pendingPosition);
      return;
    }
    if (player.playing) {
      await player.pause();
    } else {
      if (player.processingState == ProcessingState.completed) await player.seek(Duration.zero, index: 0);
      await player.play();
    }
  }

  Future<void> pause() async => _player?.pause();

  Future<void> next() async {
    if (_player?.hasNext ?? false) await _player!.seekToNext();
  }

  Future<void> previous() async {
    final p = _player;
    if (p == null) return;
    if (p.position > const Duration(seconds: 3) || !p.hasPrevious) {
      await p.seek(Duration.zero);
    } else {
      await p.seekToPrevious();
    }
  }

  Future<void> seek(Duration d) async => _player?.seek(d);

  Future<void> toggleShuffle() async {
    _shuffle = !_shuffle;
    await _prefs.setBool(_kShuffle, _shuffle);
    if (_shuffle) await _player?.shuffle();
    await _player?.setShuffleModeEnabled(_shuffle);
    notifyListeners();
  }

  Future<void> cycleRepeat() async {
    _repeat = MusicRepeat.values[(_repeat.index + 1) % MusicRepeat.values.length];
    await _prefs.setInt(_kRepeat, _repeat.index);
    await _player?.setLoopMode(_loopFor(_repeat));
    notifyListeners();
  }

  /// Stops playback and hides the mini player.
  Future<void> close() async {
    await _player?.stop();
    _queue = const [];
    _index = null;
    _pendingTrack = null;
    error = null;
    await _prefs.remove(_kLast);
    notifyListeners();
  }

  // ---------- Remember last session ----------

  void _readLastSession() {
    final raw = _prefs.getString(_kLast);
    if (raw == null) return;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      _pendingQueue = (j['queue'] as List<dynamic>).cast<String>();
      _pendingPosition = Duration(milliseconds: (j['pos'] as num?)?.toInt() ?? 0);
      final id = j['id'] as String;
      // The catalog may load after us; resolve lazily.
      _pendingId = id;
    } catch (_) {}
  }

  String? _pendingId;

  /// Called once the catalog is available so the last track can be shown.
  void attachLibrary() {
    final id = _pendingId;
    if (id == null || isLoaded) return;
    final t = _library.byId(id);
    if (t != null) {
      _pendingTrack = t;
      _pendingId = null;
      notifyListeners();
    }
  }

  Duration get resumePosition => _pendingPosition;

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 2), saveNow);
  }

  Future<void> saveNow() async {
    final t = current;
    if (t == null || !isLoaded || t.id.startsWith(guidancePrefix)) return;
    final pos = _player?.position ?? Duration.zero;
    // Only remember the position for longer tracks.
    final keepPos = t.durationSeconds == 0 || t.durationSeconds > 180;
    await _prefs.setString(
      _kLast,
      jsonEncode({
        'id': t.id,
        'queue': _queue.where((q) => !q.isLocalOnly).map((q) => q.id).toList(),
        'pos': keepPos ? pos.inMilliseconds : 0,
      }),
    );
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    for (final s in _subs) {
      s.cancel();
    }
    _player?.dispose();
    super.dispose();
  }
}
