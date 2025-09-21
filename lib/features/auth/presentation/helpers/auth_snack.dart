import 'package:flutter/material.dart';

void showSnack(BuildContext context, String text, {Color bg = Colors.green}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text), backgroundColor: bg));
}
