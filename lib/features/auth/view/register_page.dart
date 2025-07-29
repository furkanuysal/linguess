import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    await ref
        .read(userRegisterProvider.notifier)
        .register(_emailController.text, _passwordController.text);

    final state = ref.read(userRegisterProvider);
    if (state is! AsyncError) {
      if (!mounted) return;
      Navigator.pop(context); // Başarılıysa login'e dön
    }
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(userRegisterProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.register)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (registerState.hasError)
                Text(
                  registerState.error.toString(),
                  style: const TextStyle(color: Colors.red),
                ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.email,
                ),
                validator: (val) => val != null && val.contains('@')
                    ? null
                    : AppLocalizations.of(context)!.invalidEmail,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.password,
                ),
                obscureText: true,
                validator: (val) => val != null && val.length >= 6
                    ? null
                    : AppLocalizations.of(context)!.passwordTooShort,
              ),
              const SizedBox(height: 24),
              registerState.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      child: Text(AppLocalizations.of(context)!.register),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
