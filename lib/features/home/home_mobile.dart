import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:linguess/features/auth/view/login_page.dart';
import 'package:linguess/features/settings/settings_sheet.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/pages/category_page.dart';
import 'package:linguess/pages/level_page.dart';
import 'package:linguess/pages/profile_page.dart';
import 'package:linguess/providers/daily_puzzle_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeMobile extends ConsumerStatefulWidget {
  const HomeMobile({super.key});

  @override
  ConsumerState<HomeMobile> createState() => _HomeMobileState();
}

class _HomeMobileState extends ConsumerState<HomeMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Linguess'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose a play mode',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to the category screen
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const CategoryPage()));
              },
              child: Text(AppLocalizations.of(context)!.selectCategory),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const LevelPage()));
              },
              child: Text(AppLocalizations.of(context)!.selectLevel),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => handleDailyButton(context, ref),
              child: Text(AppLocalizations.of(context)!.dailyWord),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => showSettingsSheet(context),
              child: Text(AppLocalizations.of(context)!.settings),
            ),
            const Spacer(),
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                final user = snapshot.data;

                return Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () {
                      if (user == null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ProfilePage(),
                          ),
                        );
                      }
                    },
                    child: Text(
                      user == null
                          ? AppLocalizations.of(context)!.login
                          : AppLocalizations.of(context)!.profile,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
