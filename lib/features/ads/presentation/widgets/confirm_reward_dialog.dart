import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future<bool> confirmRewardAd(
  BuildContext context, {
  required String title,
  required String message,
  required String cancelText,
  required String confirmText,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (_) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.ondemand_video, size: 20),
          const SizedBox(width: 8),
          Text(title),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Ad',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => context.pop(false),
          child: Text(cancelText),
        ),
        FilledButton.icon(
          onPressed: () => context.pop(true),
          icon: const Icon(Icons.play_arrow),
          label: Text('$confirmText (Ad)'),
        ),
      ],
    ),
  );
  return result == true;
}
