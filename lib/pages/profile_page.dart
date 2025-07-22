import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:linguess/features/auth/data/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _authService.getCurrentUser();
  }

  void _signOut() async {
    await _authService.signOut();
    // Çıkış yapınca ana sayfaya dön
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: const Center(child: Text('Kullanıcı bulunamadı.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email: ${_user!.email}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _signOut, child: const Text('Çıkış Yap')),
          ],
        ),
      ),
    );
  }
}
