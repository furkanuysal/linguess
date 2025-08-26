// ads_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/services/ads_service.dart';

final adsServiceProvider = Provider<AdsService>((ref) {
  final svc = AdsService();
  ref.onDispose(() => svc.dispose());
  // Preload one as soon as the app opens
  svc.loadRewarded();
  return svc;
});
