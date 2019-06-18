import 'package:middleware/middleware.dart';
import 'package:front_end/screens.dart';
import 'package:flutter/material.dart';

class RouteConverters {

  static Widget getFromAccountStatus(UserAccountStatus accountStatus) {
    switch (accountStatus) {
      case UserAccountStatus.LOGGED_OUT:
        return IntroScreen();
      case UserAccountStatus.LOGGED_IN:
        return MainAppBar();
      case UserAccountStatus.PENDING_ONBOARDING:
        return OnboardScreen();
      default:
        return null;
    }
  }

  static RouteSettings getSettingsFromAccountStatus(UserAccountStatus accountStatus){
    String name;
    switch (accountStatus) {
      case UserAccountStatus.LOGGED_OUT:
        name = '/start';
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