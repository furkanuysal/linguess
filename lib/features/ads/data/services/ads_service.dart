import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class AdsService {
  RewardedInterstitialAd? _ad;
  bool _isLoading = false;

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
    if (Platform.isIOS) return _unitIdEnv.isNotEmpty ? _unitIdEnv : _iosTest;
    return '';
  }

  final adRequest = const AdRequest(nonPersonalizedAds: true);

  Future<void> loadRewardedInterstitialAd() async {
    if (_isLoading || _ad != null) return;
    _isLoading = true;
    await RewardedInterstitialAd.load(
      adUnitId: unitId,
      request: adRequest,
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (e) {
          _ad = null;
          _isLoading = false;
        },
      ),
    );
  }

  bool get isReady => _ad != null;

  Future<void> showRewardedInterstitialAd(
    BuildContext context, {
    required Future<void> Function(int amount, String type) onReward,
  }) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    if (_ad == null) await loadRewardedInterstitialAd();
    final ad = _ad;

    if (ad == null) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(l10n.adNotReady)));
      return;
    }
    _ad = null; // single-use

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadRewardedInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadRewardedInterstitialAd();
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(l10n.adNotLoaded)),
        );
      },
    );

    await ad.show(
      onUserEarnedReward: (ad, reward) async {
        await onReward(reward.amount.toInt(), reward.type);
      },
    );
  }

  void dispose() {
    _ad?.dispose();
    _ad = null;
  }
}
