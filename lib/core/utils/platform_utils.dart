import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
