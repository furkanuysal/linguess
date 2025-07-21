import 'package:flutter/material.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class HomeWeb extends StatelessWidget {
  const HomeWeb({super.key});

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
                // Navigate to the game screen
              },
              child: Text(AppLocalizations.of(context)!.selectCategory),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // Navigate to the settings screen
              },
              child: const Text('Choose a level to play'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () {}, child: const Text('Daily word')),
          ],
        ),
      ),
    );
  }
}
