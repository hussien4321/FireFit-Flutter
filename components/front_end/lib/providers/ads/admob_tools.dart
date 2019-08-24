import 'package:firebase_admob/firebase_admob.dart';
import 'dart:io' show Platform;

class AdmobTools {

  static final List<String> subscriptionId = Platform.isAndroid
    ? ['firefit.plus.subscriptions.monthly']
    : ['firefit.plus.monthly.subscription'];

  static final MobileAdTargetingInfo targetingInfo = new MobileAdTargetingInfo(
    childDirected: false,
    testDevices: <String>['B2AA47A5B61A62208DFAF5C4CD83EB0A', '24CD58DF8BA0C7A9F379047A6BF0D17E', 'c775044d6b247fd9935c6544eee3edbc'],
    keywords: <String>['fashion', 'beauty', 'outfits', 'streetwear', 'clothing'],
  );

  static final String testAppId = FirebaseAdMob.testAppId;

  static String appId(bool useSecondaryAdmobId) => useSecondaryAdmobId
      ? secondaryAppId 
      : primaryAppId;
      
  static final String primaryAppId = Platform.isAndroid
      ? 'ca-app-pub-3787115292798141~8475161366'
      : 'ca-app-pub-3787115292798141~5206780440';
      
  static final String secondaryAppId = Platform.isAndroid
      ? 'ca-app-pub-3662734111862581~1764681691'
      : 'ca-app-pub-3662734111862581~3624558273';
      
  static final String testAdUnitId = InterstitialAd.testAdUnitId;

  static String adUnitId(bool useSecondaryAdmobId) => useSecondaryAdmobId
      ? secondaryAdUnitId
      : primaryAdUnitId;
      
  static final String primaryAdUnitId =
   Platform.isAndroid
      ? 'ca-app-pub-3787115292798141/4731357479'
      : 'ca-app-pub-3787115292798141/8416710790';

  static final String secondaryAdUnitId =
   Platform.isAndroid
      ? 'ca-app-pub-3662734111862581/4966873180'
      : 'ca-app-pub-3662734111862581/8302169883';
}