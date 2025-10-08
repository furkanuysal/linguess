import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:linguess/features/ads/presentation/widgets/ad_loading_dialog.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class AdsService {
  RewardedInterstitialAd? _ad;
  bool _isLoading = false;
  bool _isShowing = false;
  int _retry = 0;

  // To notify waiters when the ad is ready
  final List<Completer<void>> _waiters = [];

  AdsService() {
    // Preload as soon as the app/page opens
    preload();
  }

  Future<void> preload() => loadRewardedInterstitialAd();

  static const _androidTest = 'ca-app-pub-3940256099942544/5354046379';
  static const _iosTest = 'ca-app-pub-3940256099942544/6978759866';

  static const _unitIdEnv = String.fromEnvironment(
    'ADMOB_REWARD_INTERSTITIAL_UNIT_ID',
    defaultValue: '',
  );

  String get unitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return _unitIdEnv.isNotEmpty ? _unitIdEnv : _androidTest;
    }
    if (Platform.isIOS) {
      return _unitIdEnv.isNotEmpty ? _unitIdEnv : _iosTest;
    }
    return '';
  }

  final adRequest = const AdRequest(nonPersonalizedAds: true);

  bool get isReady => _ad != null;

  Future<void> loadRewardedInterstitialAd() async {
    if (kIsWeb || unitId.isEmpty) return;
    if (_isLoading || _ad != null) return;

    _isLoading = true;
    await RewardedInterstitialAd.load(
      adUnitId: unitId,
      request: adRequest,
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _retry = 0;
          _isLoading = false;
          _notifyReady();
        },
        onAdFailedToLoad: (e) async {
          _ad = null;
          _isLoading = false;
          // Retry with backoff (max ~16 sec)
          _retry = (_retry + 1).clamp(1, 5);
          await Future.delayed(Duration(seconds: 1 << (_retry - 1)));
          if (_ad == null) {
            // retry again if not loaded elsewhere
            unawaited(loadRewardedInterstitialAd());
          }
        },
      ),
    );
  }

  // Wait until the ad is ready (with timeout)
  Future<bool> ensureLoaded({
    Duration timeout = const Duration(seconds: 6),
  }) async {
    if (isReady) return true;
    // Trigger loading
    unawaited(loadRewardedInterstitialAd());

    final completer = Completer<void>();
    _waiters.add(completer);
    try {
      await completer.future.timeout(timeout);
      return isReady;
    } on TimeoutException {
      _waiters.remove(completer);
      return isReady; // even on timeout, check again
    }
  }

  void _notifyReady() {
    for (final c in _waiters) {
      if (!c.isCompleted) c.complete();
    }
    _waiters.clear();
  }

  Future<void> showRewardedInterstitialAd(
    BuildContext context, {
    required Future<void> Function(int amount, String type) onReward,
    Duration waitTimeout = const Duration(seconds: 6),
  }) async {
    final s = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (_isShowing) return;

    final GoRouter router = GoRouter.of(context);
    final GlobalKey<NavigatorState> rootNavKey =
        router.routerDelegate.navigatorKey;

    bool showedDialog = false;

    if (_ad == null) {
      showedDialog = true;
      unawaited(
        showDialog(
          context: context,
          barrierDismissible: false,
          useRootNavigator: true,
          builder: (_) => PopScope(
            canPop: false,
            child: AdLoadingDialog(duration: waitTimeout),
          ),
        ),
      );
    }

    // Wait for loading
    final ok = _ad != null ? true : await ensureLoaded(timeout: waitTimeout);

    if (showedDialog) {
      if (router.canPop()) {
        router.pop();
      } else {
        rootNavKey.currentState?.maybePop();
      }
    }

    if (!ok || _ad == null) {
      if (context.mounted) {
        s.showSnackBar(SnackBar(content: Text(l10n.adNotReady)));
      }
      return;
    }

    final ad = _ad!;
    _isShowing = true;
    _ad = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isShowing = false;
        preload();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isShowing = false;
        preload();
        if (context.mounted) {
          s.showSnackBar(SnackBar(content: Text(l10n.adNotLoaded)));
        }
      },
    );

    await ad.show(
      onUserEarnedReward: (ad, reward) async {
        try {
          await onReward(reward.amount.toInt(), reward.type);
        } catch (_) {}
      },
    );
  }

  void dispose() {
    _ad?.dispose();
    _ad = null;
    for (final c in _waiters) {
      if (!c.isCompleted) c.complete(); // release waiting completers
    }
    _waiters.clear();
  }
}
