import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
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
