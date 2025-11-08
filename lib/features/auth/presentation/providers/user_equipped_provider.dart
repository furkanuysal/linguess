import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:linguess/core/utils/auth_utils.dart';
import 'package:linguess/features/settings/presentation/controllers/settings_controller.dart';
import 'package:linguess/features/shop/data/providers/inventory_provider.dart';

// Returns the best avatar image URL or asset path to display for the user.
//
// Logic:
// - Email/password users → always use game avatar (if equipped)
// - External users (Google/Apple) → use game avatar only if the setting is enabled
// - Otherwise → fallback to FirebaseAuth.photoURL
final avatarImageProvider = FutureProvider<String?>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

  final settings = await ref.watch(settingsControllerProvider.future);
  final useGameAvatar = settings.useGameAvatar;
  final isPwordUser = isPasswordUser(user);

  final shouldUseGameAvatar = isPwordUser || useGameAvatar;

  if (shouldUseGameAvatar) {
    final repo = ref.read(inventoryRepositoryProvider);
    final avatarUrl = await repo.fetchEquippedItemUrl('avatar');
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return avatarUrl;
    }
  }

  // Fallback: FirebaseAuth profile photo
  if (user.photoURL != null && user.photoURL!.isNotEmpty) {
    return user.photoURL!;
  }

  // Fallback: null → default icon used in UI
  return null;
});

final avatarFrameProvider = FutureProvider<String?>((ref) async {
  final repo = ref.read(inventoryRepositoryProvider);
  return await repo.fetchEquippedItemUrl('frame');
});
