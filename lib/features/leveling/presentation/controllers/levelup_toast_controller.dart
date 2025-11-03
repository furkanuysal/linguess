import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linguess/features/leveling/data/models/leveling_model.dart';
import 'package:linguess/features/leveling/presentation/providers/leveling_provider.dart';
import 'package:linguess/features/auth/presentation/providers/auth_provider.dart';

class LevelUpEvent {
  final int from;
  final int to;
  final String id;
  const LevelUpEvent({required this.from, required this.to, required this.id});
}

final levelUpToastProvider =
    NotifierProvider<LevelUpToastController, LevelUpEvent?>(
      LevelUpToastController.new,
    );

class LevelUpToastController extends Notifier<LevelUpEvent?> {
  int? _lastLevel;
  String? _userUid;

  @override
  LevelUpEvent? build() {
    _userUid = ref.read(authServiceProvider).currentUser?.uid;
    _initLastLevel();

    // Always listen for leveling changes
    ref.listen<AsyncValue<LevelingModel?>>(levelingProvider, (prev, next) {
      if (next.isLoading || next.hasError) return;
      final current = next.value?.level;
      if (current == null) return;

      final previous = _lastLevel ?? prev?.value?.level ?? current;

      if (current > previous) {
        _lastLevel = current;
        _saveLastLevel(current);
        final ev = LevelUpEvent(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          from: previous,
          to: current,
        );
        _show(ev);
      } else {
        _lastLevel = current;
      }
    });

    return null;
  }

  //  User unique ID for prefs key
  String get _prefsKey =>
      _userUid != null ? 'user_${_userUid}_last_level' : 'last_known_level';

  // Initialize last known level from SharedPreferences
  Future<void> _initLastLevel() async {
    final prefs = await SharedPreferences.getInstance();
    _lastLevel =
        prefs.getInt(_prefsKey) ?? ref.read(levelingProvider).value?.level ?? 1;
  }

  // Save last known level to SharedPreferences
  Future<void> _saveLastLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKey, level);
  }

  // Show toast for a defined duration
  void _show(LevelUpEvent ev) {
    state = ev;
    Future.delayed(const Duration(seconds: 4), () {
      if (ref.mounted) state = null;
    });
  }
}
