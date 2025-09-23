import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  /// Initialize Ads
  static void initializeAds() {
    MobileAds.instance.initialize();
  }

  /// --- 🔥 Custom Loading Dialog with Lottie ---
  static void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6), // dim background
      builder: (_) => Center(
        child: Lottie.asset(
          "assets/animations/AnimationSFX/HezzFinal.json", // put your animation path
          width: 300,
          height: 300,
          repeat: true,
        ),
      ),
    );
  }

  static void _hideLoadingDialog(BuildContext context) {
    if (Navigator.canPop(context)) Navigator.of(context).pop();
  }

  /// Banner Ad
  static BannerAd getBannerAd(Function onAdLoaded) {
    final BannerAd banner = BannerAd(
      adUnitId: 'ca-app-pub-9936922975297046/9578151004', // ✅ real ID
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) => onAdLoaded(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('❌ BannerAd failed: ${error.message}');
        },
      ),
    )..load();

    return banner;
  }

  /// Interstitial Ad with Lottie loading
  static Future<void> showInterstitialAd({
    required BuildContext context,
    Function? onDismissed,
  }) async {
    _showLoadingDialog(context);

    await InterstitialAd.load(
      adUnitId: 'ca-app-pub-9936922975297046/3703347104',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _hideLoadingDialog(context);

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              onDismissed?.call();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              debugPrint('❌ Interstitial failed to show: ${error.message}');
              onDismissed?.call();
            },
          );

          ad.show();
        },
        onAdFailedToLoad: (error) {
          _hideLoadingDialog(context);
          debugPrint('❌ Interstitial failed to load: ${error.message}');
          onDismissed?.call();
        },
      ),
    );
  }

  /// Rewarded Ad with Lottie loading
  static Future<void> showRewardedAdWithLoading(
      BuildContext context,
      VoidCallback onRewardEarned,
      ) async {
    _showLoadingDialog(context);

    await RewardedAd.load(
      adUnitId: 'ca-app-pub-9936922975297046/7890552865',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _hideLoadingDialog(context);

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) => ad.dispose(),
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              debugPrint('❌ RewardedAd failed to show: ${error.message}');
            },
          );

          ad.show(
            onUserEarnedReward: (ad, reward) => onRewardEarned(),
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          _hideLoadingDialog(context);
          debugPrint('❌ Rewarded failed: ${error.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ad failed to load. Try again later.')),
          );
        },
      ),
    );
  }

  /// Rewarded Ad returning Future<bool>
  static Future<bool> showRewardedAd(BuildContext context) {
    Completer<bool> completer = Completer<bool>();
    _showLoadingDialog(context);

    RewardedAd.load(
      adUnitId: 'ca-app-pub-9936922975297046/7890552865',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _hideLoadingDialog(context);

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              if (!completer.isCompleted) completer.complete(false);
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              if (!completer.isCompleted) completer.complete(false);
              ad.dispose();
              debugPrint('❌ Rewarded failed to show: ${error.message}');
            },
          );

          ad.show(
            onUserEarnedReward: (ad, reward) {
              if (!completer.isCompleted) completer.complete(true);
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          _hideLoadingDialog(context);
          if (!completer.isCompleted) completer.complete(false);
          debugPrint('❌ Rewarded failed to load: ${error.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ad failed to load. Try again later.')),
          );
        },
      ),
    );

    return completer.future;
  }
}
