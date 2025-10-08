import 'package:flutter/material.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class AdLoadingDialog extends StatelessWidget {
  const AdLoadingDialog({required this.duration, super.key});
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                l10n.preparingAd,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
