import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/economy/data/services/economy_service.dart';

final economyServiceProvider = Provider<EconomyService>((ref) {
  return EconomyService();
});
