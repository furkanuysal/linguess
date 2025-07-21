import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'home_mobile.dart';
import 'home_web.dart';

class HomeSelector extends StatelessWidget {
  const HomeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const HomeWeb();
    } else {
      return const HomeMobile();
    }
  }
}
