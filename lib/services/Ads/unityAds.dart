import 'package:adkach/controllers/reward_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

import '../../controllers/wallet_controller.dart';

class AdManager {
  static Future<void> loadUnityIntAd() async {
    await UnityAds.load(
      placementId: AdHelper.interstitialId,
      onComplete: (placementId) => print('Load Complete $placementId'),
      onFailed: (placementId, error, message) =>
          print('Load Failed $placementId: $error $message'),
    );
  }

  static Future<void> showIntAd() async {
    UnityAds.showVideoAd(
        placementId: AdHelper.interstitialId,
        onStart: (placementId) => print('Video Ad $placementId started'),
        onClick: (placementId) => print('Video Ad $placementId click'),
        onSkipped: (placementId) => print('Video Ad $placementId skipped'),
        onComplete: (placementId) async {
          await loadUnityIntAd();

          final rewardController = Get.put(RewardController());
          await rewardController.rewardsMainController();
        },
        onFailed: (placementId, error, message) async {
          Get.snackbar('Failed to load ad', 'Please try again later');
        });
  }

  static Future<void> loadUnityRewardedAd() async {
    await UnityAds.load(
      placementId: AdHelper.rewardedId,
      onComplete: (placementId) => print('Load Complete $placementId'),
      onFailed: (placementId, error, message) =>
          print('Load Failed $placementId: $error $message'),
    );
  }

  static Future<void> showRewardedAd() async {
    UnityAds.showVideoAd(
        placementId: AdHelper.rewardedId,
        onStart: (placementId) => print('Video Ad $placementId started'),
        onClick: (placementId) => print('Video Ad $placementId click'),
        onSkipped: (placementId) => print('Video Ad $placementId skipped'),
        onComplete: (placementId) async {
          await fetchMainBalance();
          await loadUnityRewardedAd();
          print('Video Ad $placementId completed');
        },
        onFailed: (placementId, error, message) async {
          Get.snackbar('Failed to load ad', 'Please try again later');
          print('Video Ad $placementId failed: $error $message');
        });
  }

  static Future<bool> verifiadShowRewardedAd() async {
    bool isVerified = false;
    try {
      await AdManager.loadUnityRewardedAd();
      await AdManager.showRewardedAd();
      isVerified = true;
    } catch (e) {
      print(e);
      isVerified = false;
    }
    return isVerified;
  }
}

class AdHelper {
  static String get addUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return '5523155';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return '5523154';
    }
    return '';
  }

  static String get interstitialId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'Interstitial_Android';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'Interstitial_iOS';
    }
    return '';
  }

  static String get rewardedId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'Rewarded_Android';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'Rewarded_iOS';
    }
    return '';
  }
}
