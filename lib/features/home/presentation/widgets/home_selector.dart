import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:linguess/features/home/presentation/pages/home_mobile.dart';
import 'package:linguess/features/home/presentation/pages/home_web.dart';
import 'package:linguess/features/home/presentation/pages/home_windows.dart';

class HomeSelector extends StatelessWidget {
  const HomeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const HomeWeb();
    } else if (Platform.isWindows) {
      return const HomeWindows();
    } else {
      return const HomeMobile();
    }
  }
}
