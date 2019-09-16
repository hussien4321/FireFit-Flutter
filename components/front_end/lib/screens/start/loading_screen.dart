import 'package:flutter/material.dart';
import 'package:front_end/providers.dart';
import 'package:blocs/blocs.dart';
import 'dart:async';
import 'package:front_end/helper_widgets.dart';
import 'package:middleware/middleware.dart';

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
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            AppTitle(),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                  Text(
                    'Warming up...',
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
      AnalyticsEvents(context).logCustomScreen('loading');
      _userBloc = UserBlocProvider.of(context);
      _subscriptions = <StreamSubscription<dynamic>>[
        _navigationListener(),
      ];
    }
  }

  StreamSubscription _navigationListener(){
    return _userBloc.accountStatus.listen((accountStatus) async {
      if(accountStatus!=null){
        final events = AnalyticsEvents(context);
        if(accountStatus == UserAccountStatus.LOGGED_OUT){
          events.reset();
        }else{
          String userId = await _userBloc.existingAuthId.first;
          events.setUserId(userId);
        }
        CustomNavigator.goToPageAtRoot(context, RouteConverters.getFromAccountStatus(accountStatus));
      }
    });
  }

}