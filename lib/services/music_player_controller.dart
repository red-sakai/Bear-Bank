import 'dart:io';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MusicTrack {
  final String path; // file path or asset key
  final String title;
  final bool isAsset;
  const MusicTrack({required this.path, required this.title, required this.isAsset});
}

class MusicPlayerController extends ChangeNotifier {
  static const String _musicDir = r'C:\\Github Projects\\bear_bank\\assets\\audio\\music_player';

  final AudioPlayer _player = AudioPlayer();
  final List<MusicTrack> _playlist = [];
  int _index = 0;
  bool _isPlaying = false;
  bool _initialized = false;

  List<MusicTrack> get playlist => List.unmodifiable(_playlist);
  int get index => _index;
  bool get isPlaying => _isPlaying;
  bool get hasTracks => _playlist.isNotEmpty;
  String get currentTitle => hasTracks ? _playlist[_index].title : '';

  MusicPlayerController() {
    _init();
  }

  Future<void> _init() async {
    await _loadPlaylistFromFs();
    if (_playlist.isEmpty) {
      await _fallbackLoadFromAssets();
    }
    _player.onPlayerComplete.listen((_) {
      next();
    });
    _initialized = true;
    notifyListeners();
  }

  Future<void> _loadPlaylistFromFs() async {
    try {
      final dir = Directory(_musicDir);
      if (!await dir.exists()) return;
      final entries = await dir.list().toList();
      final files = entries
          .whereType<File>()
          .map((f) => f.path)
          .where((p) => p.toLowerCase().endsWith('.mp3'))
          .toList()
        ..sort();
      if (files.isEmpty) return;
      _playlist
        ..clear()
        ..addAll(files.map((p) => MusicTrack(path: p, title: p.split(Platform.pathSeparator).last, isAsset: false)));
      if (_index >= _playlist.length) _index = 0;
    } catch (_) {
      // ignore
    }
  }

  Future<void> _fallbackLoadFromAssets() async {
    try {
      final manifestRaw = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifest = json.decode(manifestRaw);
      final keys = manifest.keys
          .where((k) => k.startsWith('assets/audio/music_player/'))
          .where((k) => k.toLowerCase().endsWith('.mp3'))
          .toList()
        ..sort();
      if (keys.isEmpty) return;
      _playlist
        ..clear()
        ..addAll(keys.map((k) {
          final title = k.split('/').last;
          return MusicTrack(path: k, title: title, isAsset: true);
        }));
      _index = 0;
    } catch (_) {
      // ignore
    }
  }

  Future<void> toggle() async {
    if (!_initialized || !hasTracks) return;
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> play() async {
    if (!hasTracks) {
      // If playlist is empty attempt asset fallback one more time.
      await _fallbackLoadFromAssets();
    }
    if (!hasTracks) return;
    final track = _playlist[_index];
    try {
      if (track.isAsset) {
        await _player.play(AssetSource(track.path.replaceFirst('assets/', ''))); // AssetSource expects relative inside assets/
      } else {
        // Windows path may contain spaces; DeviceFileSource handles this directly.
        await _player.play(DeviceFileSource(track.path));
      }
      _isPlaying = true;
      notifyListeners();
    } catch (_) {
      // ignore play failures
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
      _isPlaying = false;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> next() async {
    if (!hasTracks) return;
    _index = (_index + 1) % _playlist.length;
    await play();
  }

  Future<void> previous() async {
    if (!hasTracks) return;
    _index = (_index - 1 + _playlist.length) % _playlist.length;
    await play();
  }

  Future<void> refresh() async {
    final wasPlaying = _isPlaying;
    await pause();
    _index = 0;
    _playlist.clear();
    await _loadPlaylistFromFs();
    if (_playlist.isEmpty) {
      await _fallbackLoadFromAssets();
    }
    if (wasPlaying && _playlist.isNotEmpty) {
      await play();
    } else {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
