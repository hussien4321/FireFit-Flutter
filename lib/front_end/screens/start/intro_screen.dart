import 'package:flutter/material.dart';
import '../../../../front_end/screens.dart';
import 'package:flutter/services.dart';
import '../../../../front_end/providers.dart';
import '../../../../blocs/blocs.dart';
import 'dart:async';
import '../../../../middleware/middleware.dart';
import 'package:overlay_support/overlay_support.dart';
import '../../../../front_end/helper_widgets.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  UserBloc _userBloc;
  List<StreamSubscription<dynamic>> _subscriptions;

  @override
  void dispose() {
    super.dispose();
    _subscriptions?.forEach((subscription) => subscription.cancel());
  }

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    _brightenStatusBar();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          _splashImage(),
          _introWidgets(context),
        ],
      ),
    );
  }

  _initBlocs() {
    if (_userBloc == null) {
      _userBloc = UserBlocProvider.of(context);
      _subscriptions = <StreamSubscription<dynamic>>[
        _userBloc.successMessage.listen((message) => toast(message)),
      ];
    }
  }

  _brightenStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
    ));
  }

  Widget _splashImage() {
    return SizedBox.expand(
      child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.orange, Colors.redAccent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
          foregroundDecoration: BoxDecoration(color: Colors.black38),
          child: AnimatedPictureFrame(
            images: [
              'assets/splash/splash_screen1.jpg',
              'assets/splash/splash_screen2.jpg',
              'assets/splash/splash_screen3.jpg',
              'assets/splash/splash_screen4.jpg',
              'assets/splash/splash_screen5.jpg',
              'assets/splash/splash_screen6.jpg',
              'assets/splash/splash_screen7.jpg',
              'assets/splash/splash_screen8.jpg',
              'assets/splash/splash_screen9.jpg',
              'assets/splash/splash_screen10.jpg',
              'assets/splash/splash_screen11.jpg',
            ],
            fit: BoxFit.cover,
          )),
    );
  }

  Widget _introWidgets(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          AppTitle(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  'Feel more confident in your own style',
                  style: Theme.of(context).textTheme.headline5.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.italic,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            child: RaisedButton(
              child: Text('CREATE ACCOUNT'),
              onPressed: () => _registerUser(context),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 16.0),
            width: double.infinity,
            child: FlatButton(
              child: Text(
                'Already have an account? Log in',
                style: Theme.of(context)
                    .textTheme
                    .button
                    .apply(color: Colors.white),
              ),
              onPressed: () => _logInUser(context),
            ),
          )
        ],
      ),
    );
  }

  _registerUser(BuildContext context) async {
    await CustomNavigator.goToLogInScreen(context, isRegistering: true);
    _brightenStatusBar();
  }

  _logInUser(BuildContext context) async {
    await CustomNavigator.goToLogInScreen(context);
    _brightenStatusBar();
  }
}
