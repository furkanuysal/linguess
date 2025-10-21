import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/features/auth/presentation/helpers/auth_error_mappers.dart';
import 'package:linguess/features/auth/presentation/helpers/auth_snack.dart';
import 'package:linguess/features/auth/presentation/providers/auth_provider.dart';
import 'package:linguess/features/auth/presentation/providers/user_data_provider.dart';
import 'package:linguess/features/auth/presentation/widgets/github_sign_in_button.dart';
import 'package:linguess/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:linguess/features/auth/presentation/widgets/reset_password_sheet.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class AuthOverlay extends ConsumerStatefulWidget {
  const AuthOverlay({super.key});

  // Shows the Auth Overlay dialog
  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) => const Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: AuthOverlay(),
      ),
    );
  }

  @override
  ConsumerState<AuthOverlay> createState() => _AuthOverlayState();
}

class _AuthOverlayState extends ConsumerState<AuthOverlay> {
  bool _isSignIn = true;
  bool _isLoading = false;

  void _toggleForm() => setState(() => _isSignIn = !_isSignIn);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: scheme.surfaceContainerHigh.withValues(alpha: 0.95),
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: CurvedAnimation(
                      parent: anim,
                      curve: Curves.easeInOut,
                    ),
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: anim,
                              curve: Curves.easeInOut,
                            ),
                          ),
                      child: child,
                    ),
                  ),
                  child: _isSignIn
                      ? SingleChildScrollView(
                          key: const ValueKey('signInScroll'),
                          child: _SignInForm(
                            key: const ValueKey('signIn'),
                            isLoading: _isLoading,
                            setLoading: (v) => setState(() => _isLoading = v),
                            onSwitch: _toggleForm,
                          ),
                        )
                      : SingleChildScrollView(
                          key: const ValueKey('signUpScroll'),
                          child: _SignUpForm(
                            key: const ValueKey('signUp'),
                            isLoading: _isLoading,
                            setLoading: (v) => setState(() => _isLoading = v),
                            onSwitch: _toggleForm,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Sign In Form
class _SignInForm extends ConsumerStatefulWidget {
  const _SignInForm({
    super.key,
    required this.isLoading,
    required this.setLoading,
    required this.onSwitch,
  });

  final bool isLoading;
  final ValueChanged<bool> setLoading;
  final VoidCallback onSwitch;

  @override
  ConsumerState<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends ConsumerState<_SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    widget.setLoading(true);

    final l10n = AppLocalizations.of(context)!;
    final auth = ref.read(authServiceProvider);

    try {
      await auth.signInWithEmailAndPassword(
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      showSnack(context, l10n.successSignIn);
    } on FirebaseAuthException catch (e) {
      showSnack(context, AuthErrorMapper.signIn(e, l10n), bg: Colors.red);
    } catch (_) {
      showSnack(context, l10n.errorSignInFailed, bg: Colors.red);
    } finally {
      widget.setLoading(false);
    }
  }

  Future<void> _handleOAuth(Future<User?> Function() method) async {
    widget.setLoading(true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final user = await method();
      if (!mounted) return;
      Navigator.of(context).pop();
      showSnack(context, l10n.signedInAs(user?.email ?? ''));
    } on FirebaseAuthException catch (e) {
      showSnack(context, AuthErrorMapper.signIn(e, l10n), bg: Colors.red);
    } finally {
      widget.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final headerColor =
        theme.textTheme.headlineSmall?.color ?? scheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.signIn,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: headerColor,
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: headerColor),
              onPressed: () => context.pop(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.signInSubtitle,
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Form
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailCtrl,
                autofillHints: const [AutofillHints.email],
                decoration: authInputDecoration(
                  context,
                ).copyWith(labelText: l10n.email),
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.emailRequired;
                  final re = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!re.hasMatch(v)) return l10n.invalidEmail;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: authInputDecoration(context).copyWith(
                  labelText: l10n.password,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                      color: scheme.primary,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.passwordRequired;
                  if (v.length < 6) return l10n.passwordTooShort;
                  return null;
                },
              ),
            ],
          ),
        ),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: widget.isLoading
                ? null
                : () => ResetPasswordSheet.show(
                    context,
                    initialEmail: _emailCtrl.text.trim(),
                  ),
            child: Text(l10n.forgotPassword),
          ),
        ),

        const SizedBox(height: 8),

        // Primary button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : _signIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.signIn),
          ),
        ),
        const SizedBox(height: 18),

        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(l10n.orText, style: theme.textTheme.bodySmall),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 48,
          width: double.infinity,
          child: GoogleSignInButton(
            text: l10n.signInWithGoogle,
            onPressed: widget.isLoading
                ? null
                : () => _handleOAuth(
                    ref.read(authServiceProvider).signInWithGoogle,
                  ),
            isLoading: widget.isLoading,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          width: double.infinity,
          child: GitHubSignInButton(
            text: l10n.signInWithGitHub,
            onPressed: widget.isLoading
                ? null
                : () => _handleOAuth(
                    ref.read(authServiceProvider).signInWithGitHub,
                  ),
            isLoading: widget.isLoading,
          ),
        ),
        const SizedBox(height: 16),

        TextButton(
          onPressed: widget.isLoading ? null : widget.onSwitch,
          child: Text(l10n.signUpButtonText),
        ),
      ],
    );
  }
}

// Sign Up Form
class _SignUpForm extends ConsumerStatefulWidget {
  const _SignUpForm({
    super.key,
    required this.isLoading,
    required this.setLoading,
    required this.onSwitch,
  });

  final bool isLoading;
  final ValueChanged<bool> setLoading;
  final VoidCallback onSwitch;

  @override
  ConsumerState<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends ConsumerState<_SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    widget.setLoading(true);

    final l10n = AppLocalizations.of(context)!;
    try {
      await ref
          .read(userSignUpProvider.notifier)
          .signUp(_emailCtrl.text.trim(), _passCtrl.text.trim());
      if (!mounted) return;
      Navigator.of(context).pop();
      showSnack(context, l10n.successSignUp, bg: Colors.green);
    } on FirebaseAuthException catch (e) {
      showSnack(context, AuthErrorMapper.signUp(e, l10n), bg: Colors.red);
    } catch (_) {
      showSnack(context, l10n.errorSignUpFailed, bg: Colors.red);
    } finally {
      widget.setLoading(false);
    }
  }

  Future<void> _handleOAuth(Future<User?> Function() method) async {
    widget.setLoading(true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final user = await method();
      if (!mounted) return;
      Navigator.of(context).pop();
      showSnack(context, l10n.signedUpAs(user?.email ?? ''));
    } on FirebaseAuthException catch (e) {
      showSnack(context, AuthErrorMapper.signUp(e, l10n), bg: Colors.red);
    } finally {
      widget.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final headerColor =
        theme.textTheme.headlineSmall?.color ?? scheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.signUp,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: headerColor,
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: headerColor),
              onPressed: () => context.pop(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.signUpSubtitle,
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailCtrl,
                autofillHints: const [AutofillHints.email],
                decoration: authInputDecoration(
                  context,
                ).copyWith(labelText: l10n.email),
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.emailRequired;
                  final re = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!re.hasMatch(v)) return l10n.invalidEmail;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: authInputDecoration(context).copyWith(
                  labelText: l10n.password,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                      color: scheme.primary,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.passwordRequired;
                  if (v.length < 6) return l10n.passwordTooShort;
                  return null;
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Primary button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : _signUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.signUp),
          ),
        ),
        const SizedBox(height: 18),

        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(l10n.orText, style: theme.textTheme.bodySmall),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 48,
          width: double.infinity,
          child: GoogleSignInButton(
            text: l10n.signInWithGoogle,
            onPressed: widget.isLoading
                ? null
                : () => _handleOAuth(
                    ref.read(authServiceProvider).signInWithGoogle,
                  ),
            isLoading: widget.isLoading,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          width: double.infinity,
          child: GitHubSignInButton(
            text: l10n.signInWithGitHub,
            onPressed: widget.isLoading
                ? null
                : () => _handleOAuth(
                    ref.read(authServiceProvider).signInWithGitHub,
                  ),
            isLoading: widget.isLoading,
          ),
        ),
        const SizedBox(height: 16),

        TextButton(
          onPressed: widget.isLoading ? null : widget.onSwitch,
          child: Text(l10n.signIn),
        ),
      ],
    );
  }
}
