import 'package:flutter/material.dart';
import 'package:front_end/screens.dart';
import 'package:flutter/services.dart';
import 'package:front_end/providers.dart';
import 'package:blocs/blocs.dart';
import 'dart:async';
import 'package:middleware/middleware.dart';

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
      body: Stack(
        children: <Widget>[
          _splashImage(),
          _introWidgets(context),
        ],
      ),
    );
  }

  

  _initBlocs() {
    if(_userBloc == null){
      _userBloc = UserBlocProvider.of(context);
      _subscriptions = <StreamSubscription<dynamic>>[
        _logInStatusListener()
      ];
    }
  }
  
  StreamSubscription _logInStatusListener(){
    return _userBloc.accountStatus.listen((accountStatus) {
      print('ACCOUNT STATUS: $accountStatus');
      if(accountStatus == UserAccountStatus.LOGGED_IN){
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (ctx) => MainAppBar()
        ));
      }
      if(accountStatus == UserAccountStatus.PENDING_ONBOARDING){
        print('onboarding');
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (ctx) => MainAppBar()
        ));
      }
    });
  }


  _brightenStatusBar(){
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
    ));
  }

  Widget _splashImage() {
    return SizedBox.expand(
      child: Container(
        foregroundDecoration: BoxDecoration(
          color: Colors.black38
        ),
        child: FadeInImage(
          image: NetworkImage(
            'https://firebasestorage.googleapis.com/v0/b/skilful-tape-240120.appspot.com/o/public_resources%2Fsplash%20screen%2Ffashion_walk.gif?alt=media&token=f9adb6a0-9324-4113-8e91-ab0952a8aa06',
          ),
          placeholder: AssetImage(
            'assets/splash.jpg',
          ),
          fit: BoxFit.cover,
          fadeOutDuration: Duration(),
          fadeInDuration: Duration(),
        ),
      ),
    );
  }

  Widget _introWidgets(BuildContext context){
    return SafeArea(
      child: Column(
        children: <Widget>[
          Text(
            'MIRA MIRA',
            style: Theme.of(context).textTheme.display1.apply(color: Colors.white),
          ),
          Expanded(child: Container(),),
          Text(
            '"Discover, share & upgrade your fashion style"',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, ),
          ),
          Expanded(child: Container(),),
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
                style: Theme.of(context).textTheme.button.apply(color: Colors.white),
              ),  
              onPressed: () => _logInUser(context),
            ),
          )
        ],
      ),
    );
  }
  _registerUser(BuildContext context) async {
    await Navigator.push(context, MaterialPageRoute(
      builder: (ctx) => LogInScreen(
        isRegistering: true,
      )
    ));
    _brightenStatusBar();
  }

  _logInUser(BuildContext context) async {
    await Navigator.push(context, MaterialPageRoute(
      builder: (ctx) => LogInScreen()
    ));
    _brightenStatusBar();
  }
}