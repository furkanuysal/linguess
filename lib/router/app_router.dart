import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Pages
import 'package:linguess/features/home/home_selector.dart';
import 'package:linguess/features/auth/view/login_page.dart';
import 'package:linguess/features/auth/view/register_page.dart';
import 'package:linguess/pages/achievements_page.dart';
import 'package:linguess/pages/category_page.dart';
import 'package:linguess/pages/learned_words_page.dart';
import 'package:linguess/pages/level_page.dart';
import 'package:linguess/pages/profile_page.dart';
import 'package:linguess/pages/word_game_page.dart';

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

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeSelector()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/category',
        builder: (context, state) => const CategoryPage(),
      ),
      GoRoute(path: '/level', builder: (context, state) => const LevelPage()),
      GoRoute(
        path: '/game/:mode/:value',
        builder: (context, state) {
          final mode = state.pathParameters['mode']!;
          final value = state.pathParameters['value']!;
          return WordGamePage(mode: mode, selectedValue: value);
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
    ],
  );
});
