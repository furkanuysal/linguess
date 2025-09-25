import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

enum UpdateMode { flexible, immediate }

bool get _isAndroidNative =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

class AndroidUpdateGate extends StatefulWidget {
  final Widget child;
  final UpdateMode mode;

  const AndroidUpdateGate({
    super.key,
    required this.child,
    this.mode = UpdateMode.flexible, // default: flexible
  });

  @override
  State<AndroidUpdateGate> createState() => _AndroidUpdateGateState();
}

class _AndroidUpdateGateState extends State<AndroidUpdateGate> {
  bool _checkedOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_checkedOnce) {
      _checkedOnce = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _run());
    }
  }

  Future<void> _run() async {
    if (!mounted || !_isAndroidNative) return;

    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability != UpdateAvailability.updateAvailable) return;

      if (widget.mode == UpdateMode.immediate && info.immediateUpdateAllowed) {
        // Full-screen, non-cancelable flow (for critical updates)
        await InAppUpdate.performImmediateUpdate();
      } else if (info.flexibleUpdateAllowed) {
        // Download in the background, finish when done, and restart the app
        await InAppUpdate.startFlexibleUpdate();
        await InAppUpdate.completeFlexibleUpdate();

        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Update installed.')));
      }
    } catch (e) {
      // Silent failure
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
