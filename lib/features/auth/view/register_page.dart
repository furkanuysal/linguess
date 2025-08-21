import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/providers/user_data_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Close keyboard
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // Try to register
      await ref.read(userRegisterProvider.notifier).register(email, password);

      if (!mounted) return;

      // Success -> green snackbar + redirect
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.successRegister),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;

      // Handle error code and provide localized message
      final String message = switch (e.code) {
        'email-already-in-use' => l10n.errorEmailAlreadyInUse,
        'invalid-email' => l10n.errorInvalidEmail,
        'weak-password' => l10n.errorWeakPassword,
        'too-many-requests' => l10n.errorTooManyRequests,
        'network-request-failed' => l10n.errorNetwork,
        _ => l10n.errorSignUpFailed, // genel fallback
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (_) {
      if (!mounted) return;
      // Unexpected error -> general message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorSignUpFailed),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.register)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: l10n.email),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.emailRequired;
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value)) {
                    return l10n.invalidEmail;
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: l10n.password),
                obscureText: true,
                validator: (val) => val != null && val.length >= 6
                    ? null
                    : l10n.passwordTooShort,
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _submit, child: Text(l10n.register)),
            ],
          ),
        ),
      ),
    );
  }
}
