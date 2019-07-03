import 'package:flutter/material.dart';
import 'package:front_end/providers.dart';
import 'package:blocs/blocs.dart';
import 'dart:async';
import 'package:front_end/helper_widgets.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  
  UserBloc _userBloc;
  List<StreamSubscription<dynamic>> _subscriptions;

  @override
  void dispose() {
    _subscriptions?.forEach((subscription) => subscription.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _initBlocs(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            AppTitle(
              color: Colors.deepOrange[800],
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                  Text(
                    'Setting up...',
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _initBlocs(BuildContext context){
    if(_userBloc == null){
      _userBloc = UserBlocProvider.of(context);
      _subscriptions = <StreamSubscription<dynamic>>[
        _navigationListener(),
      ];
    }
  }

  StreamSubscription _navigationListener(){
    return _userBloc.accountStatus.listen((accountStatus) {
      if(accountStatus!=null){
        Navigator.pushReplacementNamed(context, RouteConverters.getFromAccountStatus(accountStatus));
      }
    });
  }

}