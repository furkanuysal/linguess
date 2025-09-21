import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/features/auth/presentation/helpers/auth_error_mappers.dart';
import 'package:linguess/features/auth/presentation/helpers/auth_snack.dart';
import 'package:linguess/features/auth/presentation/providers/auth_provider.dart';
import 'package:linguess/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/features/auth/presentation/providers/user_data_provider.dart';
import 'package:linguess/features/auth/presentation/widgets/auth_header_gradient.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final l10n = AppLocalizations.of(context)!;

    try {
      await ref.read(userSignUpProvider.notifier).signUp(email, password);

      if (!mounted) return;
      showSnack(context, l10n.successSignUp, bg: Colors.green);
      context.go('/');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message = AuthErrorMapper.signUp(e, l10n);
      showSnack(context, message, bg: Colors.red);
    } catch (_) {
      if (!mounted) return;
      showSnack(context, l10n.errorSignUpFailed, bg: Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    if (_isLoading) return;

    final l10n = AppLocalizations.of(context)!;
    final auth = ref.read(authServiceProvider);

    setState(() => _isLoading = true);
    try {
      final user = await auth.signInWithGoogle();

      if (!mounted) return;
      showSnack(context, l10n.signedUpAs(user?.email ?? ''));
      context.go('/');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'canceled' || e.code == 'popup-closed-by-user') {
        showSnack(context, l10n.signUpCanceled, bg: Colors.red);
      } else {
        showSnack(context, l10n.errorSignUpFailed, bg: Colors.red);
      }
    } catch (_) {
      if (!mounted) return;
      showSnack(context, l10n.errorSignUpFailed, bg: Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const AuthHeaderGradient(height: 300),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => context.canPop() ? context.pop() : null,
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      l10n.signUp,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            decoration: InputDecoration(
                              labelText: l10n.email,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
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
                            decoration: InputDecoration(
                              labelText: l10n.password,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
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
                            validator: (val) => val != null && val.length >= 6
                                ? null
                                : l10n.passwordTooShort,
                          ),

                          const SizedBox(height: 16),

                          // Primary Sign Up button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _signUp,
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
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(l10n.signUp),
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

                          const SizedBox(height: 14),

                          // Google signup button
                          SizedBox(
                            height: 48,
                            width: double.infinity,
                            child: GoogleSignInButton(
                              text: l10n.signUpWithGoogle,
                              onPressed: _isLoading ? null : _signUpWithGoogle,
                              isLoading: _isLoading,
                            ),
                          ),
                        ],
                      ),
                    ),
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
