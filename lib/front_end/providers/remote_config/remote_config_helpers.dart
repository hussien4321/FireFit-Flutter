import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigHelpers {

  static final String USE_SECONDARY_ADMOB_ID_KEY = 'use_secondary_admob_id';
  static final String CAROUSEL_AD_FREQUENCY_KEY = 'carousel_ad_frequency';
  static final String UPLOAD_DAILY_LIMIT = 'upload_daily_limit';
  static final String LOOKBOOKS_OUTFITS_LIMIT = 'lookbooks_outfits_limit';
  static final String LOOKBOOKS_LIMIT = 'lookbooks_limit';

  static final defaults = <String, dynamic>{
    USE_SECONDARY_ADMOB_ID_KEY: true,
    CAROUSEL_AD_FREQUENCY_KEY: 30,
    UPLOAD_DAILY_LIMIT: 3,
    LOOKBOOKS_OUTFITS_LIMIT: 100,
    LOOKBOOKS_LIMIT: 100,
  };

  static loadDefaults() {
    RemoteConfig.instance.setDefaults(defaults);
  }

  static fetchValues() {
    RemoteConfig remoteConfig = RemoteConfig.instance;
    try{
       remoteConfig.fetchAndActivate();
    } catch (e) {}
  }
}