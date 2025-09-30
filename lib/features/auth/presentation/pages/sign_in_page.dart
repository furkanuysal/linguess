import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/features/auth/presentation/helpers/auth_error_mappers.dart';
import 'package:linguess/features/auth/presentation/helpers/auth_snack.dart';
import 'package:linguess/features/auth/presentation/widgets/auth_header_gradient.dart';
import 'package:linguess/features/auth/presentation/widgets/github_sign_in_button.dart';
import 'package:linguess/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
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

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final l10n = AppLocalizations.of(context)!;
    final authService = ref.read(authServiceProvider);

    try {
      await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      showSnack(context, l10n.successSignIn);
      context.go('/');
    } on FirebaseAuthException catch (e) {
      final msg = AuthErrorMapper.signIn(e, l10n);
      showSnack(context, msg, bg: Colors.red);
    } catch (_) {
      showSnack(context, l10n.errorSignInFailed, bg: Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleOAuthSignIn(Future<User?> Function() signInMethod) async {
    if (_isLoading) return;

    final l10n = AppLocalizations.of(context)!;

    setState(() => _isLoading = true);
    try {
      final user = await signInMethod();

      if (!mounted) return;
      showSnack(context, l10n.signedInAs(user?.email ?? ''));
      context.go('/');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'canceled' || e.code == 'popup-closed-by-user') {
        showSnack(context, l10n.signInCanceled, bg: Colors.red);
      } else {
        final msg = AuthErrorMapper.signIn(e, l10n);
        showSnack(context, msg, bg: Colors.red);
      }
    } catch (_) {
      if (!mounted) return;
      showSnack(context, l10n.errorSignInFailed, bg: Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    final auth = ref.read(authServiceProvider);
    return _handleOAuthSignIn(auth.signInWithGoogle);
  }

  Future<void> _signInWithGitHub() async {
    final auth = ref.read(authServiceProvider);
    return _handleOAuthSignIn(auth.signInWithGitHub);
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
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            AuthHeaderGradient(height: 300),
            // Content
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  IconButton(
                    onPressed: () => context.canPop() ? context.pop() : null,
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                  const SizedBox(height: 8),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      l10n.signIn,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      l10n.signInSubtitle,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Form
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email
                          TextFormField(
                            controller: _emailController,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            decoration: authInputDecoration(context).copyWith(
                              labelText: l10n.email,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
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

                          const SizedBox(height: 12),

                          // Password
                          TextFormField(
                            controller: _passwordController,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            decoration: authInputDecoration(context).copyWith(
                              labelText: l10n.password,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                                tooltip: _obscure
                                    ? l10n.showText
                                    : l10n.hideText,
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

                          const SizedBox(height: 8),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : _showResetPasswordSheet,
                              child: Text(l10n.forgotPassword),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Primary sign in
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _signIn,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                backgroundColor: Colors.black87,
                                foregroundColor: Colors.white,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(l10n.signIn),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Divider
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  l10n.orText,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Social sign in buttons
                          SizedBox(
                            height: 48,
                            width: double.infinity,
                            child: GoogleSignInButton(
                              text: l10n.signInWithGoogle,
                              onPressed: _isLoading ? null : _signInWithGoogle,
                              isLoading: _isLoading,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 48,
                            width: double.infinity,
                            child: GitHubSignInButton(
                              text: l10n.signInWithGitHub,
                              onPressed: _isLoading ? null : _signInWithGitHub,
                              isLoading: _isLoading,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => context.push('/signUp'),
                        child: Text(l10n.signUpButtonText),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
  String? _errorText;

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

  Future<void> _sendReset() async {
    if (_sending) return;

    final l10n = AppLocalizations.of(context)!;
    final email = _emailCtrl.text.trim();

    if (email.isEmpty) {
      setState(() => _errorText = l10n.emailRequired);
      return;
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      setState(() => _errorText = l10n.invalidEmail);
      return;
    }

    setState(() => _sending = true);
    final authService = ref.read(authServiceProvider);

    try {
      await authService.resetPassword(email);
      if (!mounted) return;
      context.pop();
      showSnack(context, l10n.successResetPasswordEmailSent);
    } on FirebaseAuthException catch (e) {
      final msg = AuthErrorMapper.resetPassword(e, l10n);
      context.pop();
      showSnack(context, msg, bg: Colors.red);
    } catch (_) {
      context.pop();
      showSnack(context, l10n.errorResetPasswordFailed, bg: Colors.red);
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
            decoration: authInputDecoration(context).copyWith(
              errorText: _errorText,
              labelText: l10n.email,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              filled: true,
            ),
            onSubmitted: (_) => _sendReset(),
            onChanged: (_) {
              if (_errorText != null) setState(() => _errorText = null);
            },
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
