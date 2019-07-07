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

void main({
  @required OutfitRepository outfitRepository,
  @required UserRepository userRepository,
  @required FirebaseMessaging messaging,
}) {
  runApp(
    UserBlocProvider(
      bloc:  UserBloc(userRepository),
      child: OutfitBlocProvider(
        bloc:  OutfitBloc(outfitRepository),
        child: CommentBlocProvider(
          bloc: CommentBloc(outfitRepository),
          child: NotificationBlocProvider(
            bloc: NotificationBloc(userRepository),
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
                  '/login': (ctx) => IntroScreen(),
                  '/onboard': (ctx) => OnboardScreen(),
                },
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
    )
  );
}
