import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:linguess/features/settings/settings_sheet.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/providers/daily_puzzle_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeMobile extends ConsumerStatefulWidget {
  const HomeMobile({super.key});

  @override
  ConsumerState<HomeMobile> createState() => _HomeMobileState();
}

class _HomeMobileState extends ConsumerState<HomeMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context)!.mainMenuPlayModeSelection,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to the category screen
                context.push('/category');
              },
              child: Text(AppLocalizations.of(context)!.selectCategory),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                context.push('/level');
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
                  child: ElevatedButton(
                    onPressed: () {
                      if (user == null) {
                        context.push('/login');
                      } else {
                        context.push('/profile');
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
