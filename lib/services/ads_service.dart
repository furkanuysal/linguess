// ads_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class AdsService {
  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  // 50 gold reward unit ID from AdMob
  String get goldRewardedUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2509557385777243/9489758380';
    } else {
      return '';
    }
  }

  final adRequest = AdRequest(
    nonPersonalizedAds: true, // Non-personalized ads
  );

  Future<void> loadRewarded() async {
    if (_isLoading || _rewardedAd != null) return;
    _isLoading = true;

    await RewardedAd.load(
      adUnitId: goldRewardedUnitId,
      request: adRequest,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isLoading = false;
        },
      ),
    );
  }

  bool get isReady => _rewardedAd != null;

  // Shows the ad. If the user earns a reward, onReward is called.
  Future<void> showRewarded(
    BuildContext context, {
    required Future<void> Function(RewardItem reward) onReward,
  }) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (_rewardedAd == null) {
      await loadRewarded();
    }
    final ad = _rewardedAd;
    if (ad == null) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(l10n.adNotReady)));
      return;
    }

    _rewardedAd = null; // single-use

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        // Reload for next use
        loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadRewarded();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.adNotLoaded)));
      },
    );

    await ad.show(
      onUserEarnedReward: (ad, reward) async {
        await onReward(reward); // handle giving gold, etc. here
      },
    );
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
