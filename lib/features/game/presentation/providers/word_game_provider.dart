import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/game/presentation/controllers/word_game_state.dart';
import 'package:linguess/features/game/presentation/controllers/word_game_notifier.dart';

final wordGameProvider = NotifierProvider.family
    .autoDispose<WordGameNotifier, WordGameState, WordGameParams>(
      WordGameNotifier.new,
    );
