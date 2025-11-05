import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/features/stats/presentation/providers/hint_stats_provider.dart';

class HintUsageCard extends ConsumerWidget {
  const HintUsageCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final hintStatsAsync = ref.watch(hintStatsProvider);

    return Material(
      color: Colors.transparent,
      elevation: 1.5,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.surface, scheme.surfaceContainerHigh],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
          child: hintStatsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('${l10n.errorLoadingStats}: $e'),
            data: (stats) {
              if (stats == null || stats.isEmpty) {
                return Center(child: Text(l10n.noHintStatsAvailable));
              }

              final labels = {
                'revealLetter': l10n.revealLetterHint,
                'showDefinition': l10n.definitionHintTitle,
                'showExampleSentence': l10n.exampleSentenceText,
                'showExampleSentenceTarget': l10n.exampleSentenceTargetTitle,
                'skipWord': l10n.skipWordTitle,
              };

              final entries = stats.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));
              final maxValue = entries
                  .map((e) => e.value.toDouble())
                  .reduce((a, b) => a > b ? a : b);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        color: scheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.hintUsageTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: entries.map((entry) {
                      final label = labels[entry.key] ?? entry.key;
                      final value = entry.value.toDouble();
                      final barFraction = maxValue == 0
                          ? 0.0
                          : value / maxValue;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 120,
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: scheme.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Stack(
                                children: [
                                  Container(
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: scheme.surfaceContainerHighest
                                          .withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: barFraction
                                        .clamp(0.0, 1.0)
                                        .toDouble(),
                                    child: Container(
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: scheme.primary,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                fontSize: 13,
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
