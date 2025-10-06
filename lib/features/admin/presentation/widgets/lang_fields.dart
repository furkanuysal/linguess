import 'package:flutter/material.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class LangFields extends StatelessWidget {
  const LangFields({
    super.key,
    required this.lang,
    required this.langLabel,
    required this.termCtrl,
    required this.meaningCtrl,
    required this.exampleSentenceCtrl,
    required this.requiredText,
    this.requiredField = false,
    this.readOnly = false,
  });

  final String lang;
  final String langLabel;
  final TextEditingController termCtrl;
  final TextEditingController meaningCtrl;
  final TextEditingController exampleSentenceCtrl;
  final String requiredText;
  final bool requiredField;
  final bool readOnly;

  InputDecoration _dec(
    BuildContext context,
    String label, {
    IconData? icon,
    bool required = false,
    bool readOnly = false,
  }) {
    final t = Theme.of(context);
    return InputDecoration(
      labelText: required ? '$label *' : label,
      prefixIcon: icon == null ? null : Icon(icon),
      filled: true,
      fillColor: readOnly
          ? t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45)
          : t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.30),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: t.dividerColor.withValues(alpha: 0.5)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final baseReadOnlyStyle = readOnly
        ? TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Term
        TextFormField(
          controller: termCtrl,
          decoration: _dec(
            context,
            '$langLabel ($lang)',
            icon: Icons.translate,
            required: requiredField,
            readOnly: readOnly,
          ),
          validator: requiredField
              ? (v) => (v == null || v.trim().isEmpty) ? requiredText : null
              : null,
          readOnly: readOnly,
          style: baseReadOnlyStyle,
        ),
        const SizedBox(height: 4),

        // Meaning
        TextFormField(
          controller: meaningCtrl,
          decoration: _dec(
            context,
            '${l10n.wordMeaningText} ($lang)',
            icon: Icons.menu_book_outlined,
            readOnly: readOnly,
          ),
          readOnly: readOnly,
          style: baseReadOnlyStyle,
        ),
        const SizedBox(height: 4),

        // Example sentence
        TextFormField(
          controller: exampleSentenceCtrl,
          decoration: _dec(
            context,
            '${l10n.exampleSentenceText} ($lang)',
            icon: Icons.chat_bubble_outline,
            readOnly: readOnly,
          ),
          readOnly: readOnly,
          style: baseReadOnlyStyle,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class LangCard extends StatelessWidget {
  const LangCard({
    super.key,
    required this.langCode,
    required this.langLabel,
    required this.child,
    this.required = false,
    this.initiallyExpanded = false,
  });

  final String langCode;
  final String langLabel;
  final Widget child;
  final bool required;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Theme(
        data: t.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          backgroundColor: t.colorScheme.surfaceContainerHigh,
          collapsedBackgroundColor: t.colorScheme.surface,
          shape: const RoundedRectangleBorder(),
          collapsedShape: const RoundedRectangleBorder(),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: t.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.translate,
              size: 18,
              color: t.colorScheme.primary,
            ),
          ),
          title: Text(
            '$langLabel (${langCode.toLowerCase()})${required ? " *" : ""}',
            style: t.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          children: [child],
        ),
      ),
    );
  }
}
