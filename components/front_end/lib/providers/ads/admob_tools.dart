import 'package:firebase_admob/firebase_admob.dart';
import 'dart:io' show Platform;

class AdmobTools {

  static final List<String> subscriptionId = Platform.isAndroid
    ? ['firefit.plus.subscriptions.monthly', 'android.test.purchased']
    : ['firefit.plus.monthly.subscription'];

  static final MobileAdTargetingInfo targetingInfo = new MobileAdTargetingInfo(
    childDirected: false,
    testDevices: <String>['B2AA47A5B61A62208DFAF5C4CD83EB0A', '24CD58DF8BA0C7A9F379047A6BF0D17E'],
    keywords: <String>['fashion', 'beauty', 'outfits', 'streetwear', 'clothing'],
  );

  static final String testAppId = FirebaseAdMob.testAppId;

  static final String appId = Platform.isAndroid
      ? 'ca-app-pub-3787115292798141~8475161366'
      : 'ca-app-pub-3787115292798141~5206780440';

  static final String testAdUnitId = InterstitialAd.testAdUnitId;

  static final String exploreAdUnitId =
   Platform.isAndroid
      ? 'ca-app-pub-3787115292798141/4731357479'
      : 'ca-app-pub-3787115292798141/8416710790';

  static final String uploadAdUnitId =
   Platform.isAndroid
      ? 'ca-app-pub-3787115292798141/9133636915'
      : 'ca-app-pub-3787115292798141/7165949127';
}