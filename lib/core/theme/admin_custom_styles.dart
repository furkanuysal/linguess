import 'package:flutter/material.dart';

Widget dropdownContainer({
  required BuildContext context,
  required String label,
  required IconData icon,
  required Widget child,
}) {
  final t = Theme.of(context);
  final scheme = t.colorScheme;

  return Container(
    decoration: BoxDecoration(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: t.dividerColor.withValues(alpha: 0.4)),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: scheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: t.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              child,
            ],
          ),
        ),
      ],
    ),
  );
}

InputDecoration appDropdownDecoration(BuildContext context, {String? hint}) {
  return const InputDecoration(
    border: InputBorder.none,
    isDense: true,
    contentPadding: EdgeInsets.zero,
  ).copyWith(hintText: hint);
}

Widget appDropdownFormField<T>({
  required BuildContext context,
  required T? value,
  required String hint,
  required List<DropdownMenuItem<T>> items,
  required ValueChanged<T?> onChanged,
  FormFieldValidator<T?>? validator,
}) {
  final t = Theme.of(context);
  return DropdownButtonFormField<T>(
    value: value,
    isExpanded: true,
    items: items,
    onChanged: onChanged,
    validator: validator,
    icon: const Icon(Icons.keyboard_arrow_down_rounded),
    borderRadius: BorderRadius.circular(12),
    menuMaxHeight: 320,
    style: t.textTheme.bodyMedium,
    decoration: appDropdownDecoration(context, hint: hint),
  );
}
