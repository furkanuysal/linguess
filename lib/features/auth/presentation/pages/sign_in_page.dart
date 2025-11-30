import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/features/auth/presentation/helpers/auth_error_mappers.dart';
import 'package:linguess/features/auth/presentation/helpers/auth_snack.dart';
import 'package:linguess/features/auth/presentation/widgets/auth_gradient.dart';
import 'package:linguess/features/auth/presentation/widgets/github_sign_in_button.dart';
import 'package:linguess/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:linguess/features/auth/presentation/widgets/reset_password_sheet.dart';
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
    _emailController.dispose();
    _passwordController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          const AuthGradient(height: 400),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  IconButton(
                    onPressed: () => context.canPop() ? context.pop() : null,
                    icon: const Icon(Icons.arrow_back_ios_new),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.surface.withValues(
                        alpha: 0.2,
                      ),
                      foregroundColor: theme.colorScheme.onSurface,
                    ),
                  ).animate().fade(duration: 400.ms).slideX(begin: -0.2),

                  SizedBox(height: size.height * 0.05),

                  Text(
                    l10n.signIn,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      color: theme.colorScheme.onSurface,
                    ),
                  ).animate().fade(duration: 600.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 8),

                  Text(
                        l10n.signInSubtitle,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      )
                      .animate()
                      .fade(duration: 600.ms, delay: 100.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 40),

                  Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.surface,
                              theme.colorScheme.surfaceContainerHigh,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _emailController,
                                label: l10n.email,
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: [AutofillHints.email],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return l10n.emailRequired;
                                  }
                                  final emailRegex = RegExp(
                                    r'^[^@]+@[^@]+\.[^@]+',
                                  );
                                  if (!emailRegex.hasMatch(value)) {
                                    return l10n.invalidEmail;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                controller: _passwordController,
                                label: l10n.password,
                                icon: Icons.lock_outline,
                                isPassword: true,
                                obscureText: _obscure,
                                onToggleObscure: () =>
                                    setState(() => _obscure = !_obscure),
                                autofillHints: [AutofillHints.password],
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
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () => ResetPasswordSheet.show(
                                          context,
                                          initialEmail: _emailController.text
                                              .trim(),
                                        ),
                                  child: Text(l10n.forgotPassword),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _signIn,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor:
                                        theme.colorScheme.onPrimary,
                                    elevation: 4,
                                    shadowColor: theme.colorScheme.primary
                                        .withValues(alpha: 0.4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: theme.colorScheme.onPrimary,
                                          ),
                                        )
                                      : Text(
                                          l10n.signIn,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .animate()
                      .fade(duration: 600.ms, delay: 200.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(child: Divider(color: theme.dividerColor)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          l10n.orText,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: theme.dividerColor)),
                    ],
                  ).animate().fade(duration: 600.ms, delay: 300.ms),

                  const SizedBox(height: 32),

                  Row(
                        children: [
                          Expanded(
                            child: GoogleSignInButton(
                              text: l10n.signIn,
                              onPressed: _isLoading ? null : _signInWithGoogle,
                              isLoading: _isLoading,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GitHubSignInButton(
                              text: l10n.signIn,
                              onPressed: _isLoading ? null : _signInWithGitHub,
                              isLoading: _isLoading,
                            ),
                          ),
                        ],
                      )
                      .animate()
                      .fade(duration: 600.ms, delay: 400.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 32),

                  Center(
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => context.pushReplacement('/signUp'),
                      child: Text(
                        l10n.signUpButtonText,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ).animate().fade(duration: 600.ms, delay: 500.ms),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
    TextInputType? keyboardType,
    List<String>? autofillHints,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      style: theme.textTheme.bodyLarge,
      decoration: authInputDecoration(context).copyWith(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onPressed: onToggleObscure,
              )
            : null,
      ),
      validator: validator,
    );
  }
}
