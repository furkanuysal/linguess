import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/core/theme/gradient_background.dart';
import 'package:linguess/core/utils/auth_utils.dart';
import 'package:linguess/core/utils/date_utils.dart';
import 'package:linguess/core/presentation/widgets/gradient_card.dart';
import 'package:linguess/features/auth/presentation/helpers/auth_error_mappers.dart';
import 'package:linguess/features/auth/presentation/helpers/auth_snack.dart';
import 'package:linguess/features/auth/presentation/providers/user_data_provider.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class AccountSettingsPage extends ConsumerStatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  ConsumerState<AccountSettingsPage> createState() =>
      _AccountSettingsPageState();
}

class _AccountSettingsPageState extends ConsumerState<AccountSettingsPage> {
  final _displayNameCtrl = TextEditingController();
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _isSaving = false;
  bool _isChangingPass = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _showSnack(BuildContext context, String msg, {Color? color}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  Future<void> _updateShowInLeaderboard(String uid, bool value) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(userServiceProvider).updateShowInLeaderboard(uid, value);
    } catch (e) {
      if (!mounted) return;
      _showSnack(context, l10n.errorOccurred, color: Colors.red);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveProfile(String uid) async {
    final l10n = AppLocalizations.of(context)!;
    final name = _displayNameCtrl.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(userServiceProvider).updateUserDocument(uid, {
        'displayName': name,
      });
      if (mounted) {
        _showSnack(context, l10n.profileUpdateSuccessful, color: Colors.green);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message = AuthErrorMapper.updateProfile(e, l10n);
      showSnack(context, message, bg: Colors.red);
    } catch (_) {
      if (!mounted) return;
      showSnack(context, l10n.errorProfileUpdateFailed, bg: Colors.red);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    final l10n = AppLocalizations.of(context)!;

    if (user == null) return;

    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      showSnack(context, l10n.errorPasswordsDoNotMatch, bg: Colors.red);
      return;
    }

    setState(() => _isChangingPass = true);

    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPassCtrl.text.trim(),
      );

      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(_newPassCtrl.text.trim());

      if (!mounted) return;

      _currentPassCtrl.clear();
      _newPassCtrl.clear();
      _confirmPassCtrl.clear();

      showSnack(context, l10n.passwordChangeSuccessful, bg: Colors.green);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message = AuthErrorMapper.changePassword(e, l10n);
      showSnack(context, message, bg: Colors.red);
    } catch (_) {
      if (!mounted) return;
      showSnack(context, l10n.errorChangePasswordFailed, bg: Colors.red);
    } finally {
      if (mounted) setState(() => _isChangingPass = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    final isPwordUser = isPasswordUser(user);

    final userDataAsync = ref.watch(userDataProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: l10n.accountSettingsTitle,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new, color: scheme.primary),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const GradientBackground(),
          SafeArea(
            child: userDataAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('${l10n.errorOccurred}: $e')),
              data: (snap) {
                if (snap == null || !snap.exists) {
                  return Center(child: Text(l10n.noDataToShow));
                }

                final data = snap.data() as Map<String, dynamic>;
                final uid = data['uid'] as String;
                final email = data['email'] ?? '—';
                final displayName = (data['displayName'] ?? '') as String;
                final createdAtValue = timestampToDate(data['createdAt']);
                final createdAt = createdAtValue != null
                    ? formatDateTime(createdAtValue)
                    : '—';
                final showInLeaderboard =
                    (data['showInLeaderboard'] as bool?) ?? true;

                _displayNameCtrl.text = displayName;
                final emailCtrl = TextEditingController(text: email);
                final createdAtCtrl = TextEditingController(text: createdAt);

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    _sectionTitle(l10n.personalInfoTitle),
                    const SizedBox(height: 6),

                    GradientCard(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            TextField(
                              controller: _displayNameCtrl,
                              decoration:
                                  accountSettingsInputDecoration(
                                    context,
                                  ).copyWith(
                                    labelText: l10n.displayNameLabel,
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
                                    ),
                                  ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: emailCtrl,
                              readOnly: true,
                              enabled: false,
                              decoration:
                                  accountSettingsInputDecoration(
                                    context,
                                  ).copyWith(
                                    labelText: l10n.email,
                                    prefixIcon: const Icon(
                                      Icons.email_outlined,
                                    ),
                                    filled: true,
                                    fillColor: scheme.surfaceContainerHighest
                                        .withValues(alpha: 0.18),
                                  ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: createdAtCtrl,
                              readOnly: true,
                              enabled: false,
                              decoration:
                                  accountSettingsInputDecoration(
                                    context,
                                  ).copyWith(
                                    labelText: l10n.createdAtLabel,
                                    prefixIcon: const Icon(
                                      Icons.calendar_today_outlined,
                                    ),
                                    filled: true,
                                    fillColor: scheme.surfaceContainerHighest
                                        .withValues(alpha: 0.18),
                                  ),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              height: 48,
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _isSaving
                                    ? null
                                    : () => _saveProfile(uid),
                                icon: _isSaving
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.save),
                                label: Text(l10n.saveText),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    GradientCard(
                      child: SwitchListTile(
                        title: Text(
                          l10n.settingsShowInLeaderboard,
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          l10n.settingsShowInLeaderboardDesc,
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        value: showInLeaderboard,
                        onChanged: _isSaving
                            ? null
                            : (val) => _updateShowInLeaderboard(uid, val),
                        activeThumbColor: scheme.primary,
                      ),
                    ),

                    const SizedBox(height: 20),
                    _sectionTitle(l10n.passwordUpdateTitle),
                    const SizedBox(height: 6),
                    if (isPwordUser) ...[
                      GradientCard(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            children: [
                              TextField(
                                controller: _currentPassCtrl,
                                obscureText: _obscureCurrent,
                                decoration:
                                    accountSettingsInputDecoration(
                                      context,
                                    ).copyWith(
                                      labelText: l10n.currentPasswordLabel,
                                      prefixIcon: const Icon(
                                        Icons.lock_outline,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureCurrent
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscureCurrent =
                                              !_obscureCurrent,
                                        ),
                                      ),
                                    ),
                              ),

                              const SizedBox(height: 12),
                              TextField(
                                controller: _newPassCtrl,
                                obscureText: _obscureNew,
                                decoration:
                                    accountSettingsInputDecoration(
                                      context,
                                    ).copyWith(
                                      labelText: l10n.newPasswordLabel,
                                      prefixIcon: const Icon(
                                        Icons.lock_open_rounded,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureNew
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscureNew = !_obscureNew,
                                        ),
                                      ),
                                    ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _confirmPassCtrl,
                                obscureText: _obscureConfirm,
                                decoration:
                                    accountSettingsInputDecoration(
                                      context,
                                    ).copyWith(
                                      labelText: l10n.confirmNewPasswordLabel,
                                      prefixIcon: const Icon(
                                        Icons.lock_reset_outlined,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirm
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscureConfirm =
                                              !_obscureConfirm,
                                        ),
                                      ),
                                    ),
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                height: 48,
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: _isChangingPass
                                      ? null
                                      : _changePassword,
                                  icon: _isChangingPass
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.password),
                                  label: Text(l10n.updatePasswordLabel),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      GradientCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.lock_person_outlined, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.externalProviderPasswordChangeDisabled,
                                  style: TextStyle(
                                    color: scheme.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        style: TextStyle(
          color: scheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
