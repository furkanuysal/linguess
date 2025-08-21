import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailController
      ..clear()
      ..dispose();
    _passwordController
      ..clear()
      ..dispose();
    super.dispose();
  }

  String _mapSignInError(FirebaseAuthException e, AppLocalizations l10n) {
    switch (e.code) {
      case 'invalid-email':
        return l10n.errorInvalidEmail;
      case 'user-not-found':
        return l10n.errorUserNotFound;
      case 'wrong-password':
        return l10n.errorWrongPassword;
      case 'invalid-credential':
        return l10n.errorInvalidCredential;
      case 'too-many-requests':
        return l10n.errorTooManyRequests;
      case 'network-request-failed':
        return l10n.errorNetwork;
      default:
        return l10n.errorSignInFailed;
    }
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final l10n = AppLocalizations.of(context)!;
    final authService = ref.read(authServiceProvider);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      final c = messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.successSignIn),
          backgroundColor: Colors.green,
        ),
      );
      await c.closed;
      if (!mounted) return;
      context.go('/');
    } on FirebaseAuthException catch (e) {
      final msg = _mapSignInError(e, l10n);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.errorSignInFailed),
            backgroundColor: Colors.red,
          ),
        );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showResetPasswordSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) =>
          _ResetPasswordSheet(initialEmail: _emailController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.login)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: l10n.email,
                  suffixIcon: _emailController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _emailController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() {}),
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

              // Şifre
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: l10n.password,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                    tooltip: _obscure ? 'Show' : 'Hide',
                  ),
                ),
                obscureText: _obscure,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.passwordRequired;
                  }
                  if (value.length < 6) {
                    return l10n.passwordTooShort;
                  }
                  return null;
                },
              ),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isLoading ? null : _showResetPasswordSheet,
                  child: Text(l10n.forgotPassword),
                ),
              ),

              const SizedBox(height: 8),

              // Login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  child: _isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.login),
                ),
              ),

              const SizedBox(height: 20),

              // Register link
              TextButton(
                onPressed: _isLoading ? null : () => context.push('/register'),
                child: Text(l10n.registerButtonText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet: Reset password with Riverpod
class _ResetPasswordSheet extends ConsumerStatefulWidget {
  const _ResetPasswordSheet({required this.initialEmail});
  final String initialEmail;

  @override
  ConsumerState<_ResetPasswordSheet> createState() =>
      _ResetPasswordSheetState();
}

class _ResetPasswordSheetState extends ConsumerState<_ResetPasswordSheet> {
  late final TextEditingController _emailCtrl;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailCtrl
      ..clear()
      ..dispose();
    super.dispose();
  }

  String _mapResetError(FirebaseAuthException e, AppLocalizations l10n) {
    switch (e.code) {
      case 'invalid-email':
        return l10n.errorInvalidEmail;
      case 'user-not-found':
        return l10n.errorUserNotFound;
      case 'too-many-requests':
        return l10n.errorTooManyRequests;
      case 'network-request-failed':
        return l10n.errorNetwork;
      default:
        return l10n.errorSignInFailed;
    }
  }

  Future<void> _sendReset() async {
    if (_sending) return;

    final l10n = AppLocalizations.of(context)!;
    final email = _emailCtrl.text.trim();
    final messenger = ScaffoldMessenger.of(context);

    if (email.isEmpty) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.emailRequired),
            backgroundColor: Colors.red,
          ),
        );
      return;
    }

    setState(() => _sending = true);

    final authService = ref.read(authServiceProvider);

    try {
      await authService.resetPassword(email);

      if (!mounted) return;
      context.pop();
      final c = messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.successResetPasswordEmailSent),
          backgroundColor: Colors.green,
        ),
      );
      await c.closed;
    } on FirebaseAuthException catch (e) {
      final msg = _mapResetError(e, l10n);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.errorSignInFailed),
            backgroundColor: Colors.red,
          ),
        );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.resetPassword,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: l10n.email,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _sendReset(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _sending ? null : _sendReset,
              child: _sending
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.sendResetLink),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
