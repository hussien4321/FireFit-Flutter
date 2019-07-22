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
  outfitViewed(Outfit outfit) => _analytics.logEvent(
    name:'outfit_viewed',
    parameters: {
      'itemId': outfit.outfitId.toString(), 
      'itemName': outfit.title
    },
  );
  profileViewed(User user) => _analytics.logEvent(
    name: 'profile_viewed',
    parameters: {
      'itemId': user.userId, 
      'itemName': user.username
    },
  );

  //Outfit
  outfitUploaded() => _analytics.logEvent(name: "outfit_uploaded");


  //Exception
  catchException({
    String code,
    String message,
    dynamic details
  }) => _analytics.logEvent(
    name: "app_exception",
    parameters: {
      "code" : code,
      "message":message,
      "details":details
    }
  );
}