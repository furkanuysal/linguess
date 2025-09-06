import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/admin/presentation/controllers/add_word_controller.dart';

final addWordControllerProvider =
    AsyncNotifierProvider<AddWordController, void>(AddWordController.new);
