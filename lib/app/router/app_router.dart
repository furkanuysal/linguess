import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/features/achievements/presentation/pages/achievements_page.dart';
import 'package:linguess/features/admin/presentation/pages/admin_add_word_page.dart';
import 'package:linguess/features/admin/presentation/pages/admin_categories_page.dart';
import 'package:linguess/features/admin/presentation/pages/admin_daily_list_page.dart';
import 'package:linguess/features/admin/presentation/pages/admin_panel_page.dart';
import 'package:linguess/features/admin/presentation/pages/admin_word_list_page.dart';
import 'package:linguess/features/admin/presentation/widgets/admin_guard.dart';
import 'package:linguess/features/auth/presentation/pages/sign_in_page.dart';
import 'package:linguess/features/auth/presentation/pages/sign_up_page.dart';
import 'package:linguess/features/game/presentation/controllers/word_game_state.dart';
import 'package:linguess/features/game/presentation/pages/category_page.dart';
import 'package:linguess/features/game/presentation/pages/combined_mode_setup_page.dart';
import 'package:linguess/features/game/presentation/pages/level_page.dart';
import 'package:linguess/features/game/presentation/pages/word_game_page.dart';
import 'package:linguess/features/home/presentation/widgets/home_selector.dart';
import 'package:linguess/features/profile/presentation/pages/learned_words_page.dart';
import 'package:linguess/features/profile/presentation/pages/profile_page.dart';

// GoRouter için refresh helper
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListener = () => notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListener());
  }
  late final void Function() notifyListener;
  late final StreamSubscription<dynamic> _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// Global navigator key provider
final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final navigatorKey = ref.watch(navigatorKeyProvider);

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeSelector()),
      GoRoute(path: '/signIn', builder: (context, state) => const SignInPage()),
      GoRoute(path: '/signUp', builder: (context, state) => const SignUpPage()),
      GoRoute(
        path: '/category',
        builder: (context, state) => const CategoryPage(),
      ),
      GoRoute(path: '/level', builder: (context, state) => const LevelPage()),
      GoRoute(
        path: '/combined-mode-setup',
        builder: (context, state) => const CombinedModeSetupPage(),
      ),
      GoRoute(
        path: '/game/:mode/:value',
        builder: (context, state) {
          final mode = state.pathParameters['mode']!;
          final value = state.pathParameters['value']!;
          final query =
              state.uri.queryParameters; // örn. ?category=food&level=A1

          final modes = <GameModeType>{};
          final filters = <String, String>{};

          switch (mode) {
            case 'daily':
              modes.add(GameModeType.daily);
              break;

            case 'category':
              modes.add(GameModeType.category);
              filters['category'] = value;
              break;

            case 'level':
              modes.add(GameModeType.level);
              filters['level'] = value;
              break;

            case 'combined':
              // 🔹 combined modda query param'lardan al
              if (query.containsKey('category')) {
                modes.add(GameModeType.category);
                filters['category'] = query['category']!;
              }
              if (query.containsKey('level')) {
                modes.add(GameModeType.level);
                filters['level'] = query['level']!;
              }
              if (modes.isEmpty) modes.add(GameModeType.category);
              break;

            default:
              modes.add(GameModeType.category);
              filters['category'] = value;
          }

          return WordGamePage(modes: modes, filters: filters);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/achievements',
        builder: (context, state) => const AchievementsPage(),
      ),
      GoRoute(
        path: '/learned-words',
        builder: (context, state) => const LearnedWordsPage(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminGuard(child: AdminPanelPage()),
      ),
      GoRoute(
        path: '/admin/words',
        builder: (context, state) =>
            const AdminGuard(child: AdminWordsListPage()),
      ),
      GoRoute(
        path: '/admin/words/add',
        builder: (context, state) {
          final editId = (state.extra as Map?)?['editId'] as String?;
          return AdminGuard(child: AdminAddWordPage(editId: editId));
        },
      ),
      GoRoute(
        path: '/admin/daily',
        builder: (context, state) =>
            const AdminGuard(child: AdminDailyListPage()),
      ),
      GoRoute(
        path: '/admin/categories',
        builder: (context, state) =>
            const AdminGuard(child: AdminCategoriesPage()),
      ),
    ],
  );
});
