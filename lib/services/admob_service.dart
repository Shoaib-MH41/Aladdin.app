import 'package:url_launcher/url_launcher.dart';

class AdMobService {
  // AdMob ID patterns
  static const String _appIdPattern = r'^ca-app-pub-\d{16}~\d{10}$';
  static const String _adUnitIdPattern = r'^ca-app-pub-\d{16}/\d{10}$';
  static const String _testAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedId = 'ca-app-pub-3940256099942544/5224354917';

  /// Check if ID is test ID
  bool isTestId(String id) {
    return id.contains('3940256099942544');
  }

  /// Validate App ID format
  bool validateAppId(String appId) {
    if (appId.isEmpty) return false;
    if (isTestId(appId)) return true; // Test IDs are valid
    
    final regex = RegExp(_appIdPattern);
    return regex.hasMatch(appId);
  }

  /// Validate Ad Unit ID format
  bool validateAdUnitId(String adUnitId) {
    if (adUnitId.isEmpty) return true; // Optional fields can be empty
    if (isTestId(adUnitId)) return true; // Test IDs are valid
    
    final regex = RegExp(_adUnitIdPattern);
    return regex.hasMatch(adUnitId);
  }

  /// Validate all IDs
  Future<bool> validateAllIds({
    required String appId,
    required String bannerId,
    String? interstitialId,
    String? rewardedId,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    bool isValid = validateAppId(appId) && validateAdUnitId(bannerId);
    
    if (interstitialId != null && interstitialId.isNotEmpty) {
      isValid = isValid && validateAdUnitId(interstitialId);
    }
    
    if (rewardedId != null && rewardedId.isNotEmpty) {
      isValid = isValid && validateAdUnitId(rewardedId);
    }
    
    return isValid;
  }

  /// Prepare ad unit IDs map
  Map<String, String> prepareAdUnitIds({
    required String bannerId,
    String? interstitialId,
    String? rewardedId,
  }) {
    final Map<String, String> ids = {
      'banner': bannerId,
    };
    
    if (interstitialId != null && interstitialId.isNotEmpty) {
      ids['interstitial'] = interstitialId;
    }
    
    if (rewardedId != null && rewardedId.isNotEmpty) {
      ids['rewarded'] = rewardedId;
    }
    
    return ids;
  }

  /// Open AdMob Console
  Future<void> openAdMobConsole() async {
    final url = Uri.parse('https://apps.admob.com/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  /// Get test IDs for development
  Map<String, String> getTestIds() {
    return {
      'appId': _testAppId,
      'banner': _testBannerId,
      'interstitial': _testInterstitialId,
      'rewarded': _testRewardedId,
    };
  }

  /// Format ID for display (mask sensitive parts)
  String maskId(String id) {
    if (id.length < 20) return id;
    return '${id.substring(0, 10)}...${id.substring(id.length - 5)}';
  }
}
