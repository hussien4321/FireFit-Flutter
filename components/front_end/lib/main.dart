import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:blocs/blocs.dart';
import 'package:middleware/middleware.dart';
import 'package:front_end/providers.dart';
import 'package:front_end/screens.dart';
import 'package:front_end/localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
            child: MaterialApp(
              title: BlocLocalizations().appTitle,
              debugShowCheckedModeBanner: false,
              home: NewNotificationsOverlayScreen(
                messaging: messaging,
                body: MaterialApp(
                  title: BlocLocalizations().appTitle,
                  debugShowCheckedModeBanner: false,
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
