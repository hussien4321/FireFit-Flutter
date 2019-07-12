import 'package:middleware/middleware.dart';
import 'package:flutter/material.dart';

class RouteConverters {

  static String getFromAccountStatus(UserAccountStatus accountStatus) {
    switch (accountStatus) {
      case UserAccountStatus.LOGGED_OUT:
        return '/intro';
      case UserAccountStatus.LOGGED_IN:
        return '/home';
      case UserAccountStatus.PENDING_ONBOARDING:
        return '/onboard';
      default:
        return null;
    }
  }

  static RouteSettings getSettingsFromAccountStatus(UserAccountStatus accountStatus){
    String name;
    switch (accountStatus) {
      case UserAccountStatus.LOGGED_OUT:
        name = '/intro';
        break;
      case UserAccountStatus.LOGGED_IN:
        name = '/home';
        break;
      case UserAccountStatus.PENDING_ONBOARDING:
        name = '/onboard';
        break;
      default:
        break;
    }
    return RouteSettings(
      name: name
    );
  }
}