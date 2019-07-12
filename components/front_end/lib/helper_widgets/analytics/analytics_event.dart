import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:front_end/providers.dart';
import 'package:middleware/middleware.dart';

class AnalyticsEvents {

  FirebaseAnalytics _analytics;
  
  AnalyticsEvents(BuildContext context){
    _analytics = _getAnalytics(context);
  }
  FirebaseAnalytics _getAnalytics(BuildContext context) => AnalyticsProvider.of(context);


  //User management
  signUp() => _analytics.logSignUp(signUpMethod: "email");
  logIn() => _analytics.logLogin(loginMethod: "email");
  setUserId(String id) => _analytics.setUserId(id);
  reset() => _analytics.resetAnalyticsData();
  logOut() {
    reset();
    _analytics.logEvent(name: "log_out");
  }
  onboardingCompleted() => _analytics.logEvent(name: "onboard_complete");
  emailVerified() => _analytics.logEvent(name: "email_verified");

  //Navigation
  logCustomScreen(String path) => _analytics.setCurrentScreen(screenName: path);
  outfitViewed(Outfit outfit) => _analytics.logViewItem(
    itemId: outfit.outfitId.toString(), 
    itemCategory: 'outfit', 
    itemName: outfit.title
  );
  profileViewed(User user) => _analytics.logViewItem(
    itemId: user.userId, 
    itemCategory: 'user',
    itemName: user.username
  );

  //Outfit
  outfitUploaded() => _analytics.logEvent(name: "outfit_uploaded");
}