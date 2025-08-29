import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/game/word_game_state.dart';
import 'package:linguess/features/game/word_game_notifier.dart';

final wordGameProvider = StateNotifierProvider.family
    .autoDispose<WordGameNotifier, WordGameState, WordGameParams>(
      (ref, params) => WordGameNotifier(ref, params),
    );
