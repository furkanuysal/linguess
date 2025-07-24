import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/providers/auth_provider.dart';
import 'package:linguess/providers/user_data_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsync = ref.watch(userDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: userDataAsync.when(
        data: (snapshot) {
          if (snapshot == null || !snapshot.exists) {
            return const Center(child: Text("Veri bulunamadı."));
          }

          final data = snapshot.data() as Map<String, dynamic>;

          final email = data['email'] ?? 'Yok';
          final gold = data['gold'] ?? 0;
          final totalLearnedWords = data['totalLearnedWords'] ?? 0;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: $email', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('Altın: $gold', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text(
                  'Toplam Öğrenilen Kelime: $totalLearnedWords',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await ref.read(authServiceProvider).signOut();
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                  child: const Text('Çıkış Yap'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
    );
  }
}
