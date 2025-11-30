import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/features/auth/presentation/helpers/auth_error_mappers.dart';
import 'package:linguess/features/auth/presentation/helpers/auth_snack.dart';
import 'package:linguess/features/auth/presentation/providers/auth_provider.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class ResetPasswordSheet extends ConsumerStatefulWidget {
  const ResetPasswordSheet({super.key, this.initialEmail = ''});
  final String initialEmail;

  static Future<void> show(BuildContext context, {String? initialEmail}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => ResetPasswordSheet(initialEmail: initialEmail ?? ''),
    );
  }

  @override
  ConsumerState<ResetPasswordSheet> createState() => _ResetPasswordSheetState();
}

class _ResetPasswordSheetState extends ConsumerState<ResetPasswordSheet> {
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
    _emailCtrl.dispose();
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
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.resetPassword,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: theme.colorScheme.onSurface,
            ),
          ).animate().fade(duration: 400.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 16),

          TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: theme.textTheme.bodyLarge,
                decoration: authInputDecoration(context).copyWith(
                  labelText: l10n.email,
                  errorText: _errorText,
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: theme.colorScheme.primary,
                  ),
                ),
                onFieldSubmitted: (_) => _sendReset(),
                onChanged: (_) {
                  if (_errorText != null) setState(() => _errorText = null);
                },
              )
              .animate()
              .fade(duration: 400.ms, delay: 200.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 24),

          SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _sending ? null : _sendReset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    elevation: 4,
                    shadowColor: theme.colorScheme.primary.withValues(
                      alpha: 0.4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _sending
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : Text(
                          l10n.sendResetLink,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              )
              .animate()
              .fade(duration: 400.ms, delay: 300.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
