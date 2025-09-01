import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:linguess/features/settings/settings_controller.dart';

final sfxProvider = Provider<SfxService>((ref) => SfxService(ref));

class SfxService {
  SfxService(this._ref) {
    if (!kIsWeb) {
      _player = AudioPlayer();
      _preload(); // preload at start
    }
  }

  final Ref _ref;
  AudioPlayer? _player;

  bool get _enabled =>
      !kIsWeb &&
      (_ref.read(settingsControllerProvider).value?.soundEffects ?? false);

  // Asset map
  final Map<String, String> _assets = const {
    'select': 'assets/sfx/buttonSelect.wav',
    'confetti': 'assets/sfx/confetti.wav',
    'wrong': 'assets/sfx/wrong.wav',
  };

  String? _current; // loaded asset
  final _cooldowns = <String, DateTime>{}; // min interval
  final Duration _minGap = const Duration(milliseconds: 80);

  Future<void> _preload() async {
    if (kIsWeb || _player == null) return;
    try {
      // Preload the most used asset
      await _player!.setAsset(_assets['select']!);
      _current = _assets['select'];
    } catch (_) {}
  }

  Future<void> _playKey(String key, {double volume = 1.0}) async {
    if (!_enabled || kIsWeb || _player == null) return;
    final asset = _assets[key];
    if (asset == null) return;

    // cooldown
    final now = DateTime.now();
    final last = _cooldowns[key];
    if (last != null && now.difference(last) < _minGap) return;
    _cooldowns[key] = now;

    try {
      if (_current == asset) {
        // same source → restart immediately
        await _player!.stop();
        await _player!.setVolume(volume);
        await _player!.seek(Duration.zero);
        await _player!.play();
      } else {
        // different source → setAsset + play
        await _player!.stop();
        await _player!.setVolume(volume);
        await _player!.setAsset(asset);
        _current = asset;
        await _player!.seek(Duration.zero);
        await _player!.play();
      }
    } catch (_) {}
  }

  // Shortcuts
  Future<void> select() => _playKey('select');
  Future<void> confetti() => _playKey('confetti');
  Future<void> wrong() => _playKey('wrong');

  Future<void> dispose() async {
    if (!kIsWeb && _player != null) {
      await _player!.dispose();
    }
  }
}
