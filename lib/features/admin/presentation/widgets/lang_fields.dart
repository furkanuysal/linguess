import 'package:flutter/material.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class LangFields extends StatelessWidget {
  const LangFields({
    super.key,
    required this.lang,
    required this.langLabel,
    required this.termCtrl,
    required this.meaningCtrl,
    required this.requiredText,
    this.requiredField = false,
    this.readOnly = false,
  });

  final String lang;
  final String langLabel;
  final TextEditingController termCtrl;
  final TextEditingController meaningCtrl;
  final String requiredText;
  final bool requiredField;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: termCtrl,
          decoration: InputDecoration(
            labelText: '$langLabel ($lang)${requiredField ? "*" : ""}',
            fillColor: readOnly ? Colors.grey.shade200 : null,
          ),
          validator: requiredField
              ? (v) => v == null || v.trim().isEmpty ? requiredText : null
              : null,
          readOnly: readOnly,
          style: readOnly
              ? TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                )
              : null,
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: meaningCtrl,
          decoration: InputDecoration(
            labelText: '${l10n!.wordMeaningText} ($lang)',
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
