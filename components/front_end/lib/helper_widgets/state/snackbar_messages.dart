import 'package:flutter/material.dart';

abstract class SnackbarMessages {

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void displayNoticeSnackBar(BuildContext context, String message,[GlobalKey<ScaffoldState> key]) {
    _displaySnackBar(
      context,
      Text(message, style: Theme.of(context).textTheme.button.apply(color: Colors.white, fontSizeDelta: 5)),
      2,
      key
    );
  }

  void displayErrorSnackBar(BuildContext context, String message,[GlobalKey<ScaffoldState> key]) {
    _displaySnackBar(
      context,
      Text(message, style: Theme.of(context).textTheme.button.apply(color: Colors.redAccent, fontSizeDelta: 5),),
      4,
      key
    );
  }

  void _displaySnackBar(BuildContext context, Widget widget, int seconds, [GlobalKey<ScaffoldState> key]) {
    GlobalKey<ScaffoldState> stateKey = (key == null ? scaffoldKey : key);
    stateKey.currentState.removeCurrentSnackBar();
    stateKey.currentState.showSnackBar(SnackBar(
      duration: Duration(seconds: seconds),
      content: widget,
    ));
  }


  void closeSnackBar(BuildContext context, [GlobalKey<ScaffoldState> key]) {
    GlobalKey<ScaffoldState> stateKey = (key == null ? scaffoldKey : key);
    stateKey.currentState.removeCurrentSnackBar();
  }


}