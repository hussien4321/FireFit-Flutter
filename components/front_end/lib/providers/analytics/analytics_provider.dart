import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsProvider extends InheritedWidget {

  final FirebaseAnalytics analytics;
  
  AnalyticsProvider({this.analytics, Widget child})
    : super(child: child);

  static FirebaseAnalytics of(BuildContext context) =>
    (context.inheritFromWidgetOfExactType(AnalyticsProvider) as AnalyticsProvider).analytics;

  @override
  bool updateShouldNotify(AnalyticsProvider old) =>
    analytics != old.analytics;
}