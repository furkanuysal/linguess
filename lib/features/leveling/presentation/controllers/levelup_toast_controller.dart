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

    // Listen to levelingProvider changes
    ref.listen<AsyncValue<LevelingModel?>>(levelingProvider, (
      prev,
      next,
    ) async {
      if (next.isLoading || next.hasError) return;

      final current = next.value?.level;
      if (current == null) return;

      // Read last saved level from SharedPreferences based on UID
      final prefs = await SharedPreferences.getInstance();
      final uid = ref.read(authServiceProvider).currentUser?.uid;
      final prefsKey = uid != null
          ? 'user_${uid}_last_level'
          : 'last_known_level';
      final savedLevel = prefs.getInt(prefsKey);

      // Calculate the actual previous level
      final previous =
          savedLevel ?? _lastLevel ?? prev?.value?.level ?? current;

      // Detect level-up
      if (current > previous) {
        _lastLevel = current;
        await prefs.setInt(prefsKey, current);

        final ev = LevelUpEvent(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          from: previous,
          to: current,
        );
        _show(ev);
      } else {
        _lastLevel = current;
        await prefs.setInt(prefsKey, current);
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
    final fromPrefs = prefs.getInt(_prefsKey);
    final fromProvider = ref.read(levelingProvider).value?.level;
    _lastLevel = fromPrefs ?? fromProvider ?? 1;
  }

  void _show(LevelUpEvent ev) {
    state = ev;
    Future.delayed(const Duration(seconds: 4), () {
      if (ref.mounted) state = null;
    });
  }
}
