import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/admin/presentation/providers/is_admin_provider.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class AdminGuard extends ConsumerWidget {
  const AdminGuard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdminAsync = ref.watch(isAdminProvider);
    final l10n = AppLocalizations.of(context)!;
    return isAdminAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text(l10n.errorOccurred))),
      data: (isAdmin) => isAdmin
          ? child
          : Scaffold(body: Center(child: Text(l10n.errorOnlyAdminsCanAccess))),
    );
  }
}
