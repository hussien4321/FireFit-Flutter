import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:blocs/blocs.dart';
import 'package:middleware/middleware.dart';
import 'package:front_end/providers.dart';
import 'package:front_end/screens.dart';
import 'package:front_end/localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:overlay_support/src/theme.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

void main({
  @required OutfitRepository outfitRepository,
  @required UserRepository userRepository,
  @required FirebaseMessaging messaging,
  @required FirebaseAnalytics analytics,
  @required Preferences preferences,
}) {
  final outfitBloc = OutfitBloc(outfitRepository, userRepository, preferences);
  runApp(
    UserBlocProvider(
      bloc:  UserBloc(userRepository, outfitRepository, preferences, outfitBloc),
      child: OutfitBlocProvider(
        bloc:  outfitBloc,
        child: CommentBlocProvider(
          bloc: CommentBloc(outfitRepository),
          child: NotificationBlocProvider(
            bloc: NotificationBloc(userRepository),
            child: AnalyticsProvider(
              analytics: analytics,
              child: OverlaySupport(
                toastTheme: ToastThemeData(
                  alignment: Alignment(0, 0.75),
                  background: Colors.deepOrange[800].withOpacity(0.8),
                  textColor: Colors.white
                ),
                child: MaterialApp(
                  title: BlocLocalizations().appTitle,
                  debugShowCheckedModeBanner: false,
                  routes: {
                    '/home' : (ctx) => MainAppBar(
                      messaging: messaging
                    ),
                    '/intro': (ctx) => IntroScreen(),
                    '/onboard': (ctx) => OnboardScreen(),
                  },
                  navigatorObservers: [
                    FirebaseAnalyticsObserver(analytics: analytics),
                  ],
                  theme: ThemeData(
                    primaryColorBrightness: Brightness.light,
                    primarySwatch: Colors.grey,
                  ),
                  home: LoadingScreen(),
                ),
              ),
            ),
          ),
        ),
      ),
    )
  );
}
