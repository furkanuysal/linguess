// ads_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class AdsService {
  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  // Platform support check
  bool get _isAdsSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  //Build time injection of AdMob Unit ID
  static const String _rewardedUnitId = String.fromEnvironment(
    'ADMOB_REWARDED_UNIT_ID',
    defaultValue: 'ca-app-pub-3940256099942544/5224354917',
  );

  // 50 gold reward unit ID from AdMob
  String get goldRewardedUnitId {
    if (!_isAdsSupported) return '';

    if (Platform.isAndroid) {
      return _rewardedUnitId;
    } else {
      return '';
    }
  }

  final adRequest = AdRequest(
    nonPersonalizedAds: true, // Non-personalized ads
  );

  Future<void> loadRewarded() async {
    if (!_isAdsSupported) return;
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

  bool get isReady => _isAdsSupported && _rewardedAd != null;

  // Shows the ad. If the user earns a reward, onReward is called.
  Future<void> showRewarded(
    BuildContext context, {
    required Future<void> Function(RewardItem reward) onReward,
  }) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;

    // If ads aren't supported, directly give the reward
    if (!_isAdsSupported) {
      await onReward(RewardItem(50, 'gold')); // Mock reward
      return;
    }

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
    if (_isAdsSupported) {
      _rewardedAd?.dispose();
      _rewardedAd = null;
    }
  }
}
