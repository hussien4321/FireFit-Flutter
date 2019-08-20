import 'package:flutter/material.dart';
import 'dart:async';
import 'package:front_end/helper_widgets.dart';

class ErrorDialog extends StatefulWidget {

  static Future<void> launch(BuildContext context, {String message}) {
    return showDialog(
      context: context,
      builder: (ctx) => ErrorDialog(
        message: message,
      )
    );
  }

  final String message;

  ErrorDialog({this.message});

  @override
  _ErrorDialogState createState() => _ErrorDialogState();
}

class _ErrorDialogState extends State<ErrorDialog> {

  bool isConnected = true;
  
  @override
  Widget build(BuildContext context) {
    _loadConnectionStatus();
    return AlertDialog(
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Error',
            style: Theme.of(context).textTheme.title.copyWith(
              color: Colors.red[900],
              fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            width: double.infinity,
            child: Text(
              widget.message,
              style: Theme.of(context).textTheme.subhead,
            ),
          ),
          !isConnected ? _noConnectionNotice() : Container(),
        ],
      ),
      contentPadding: EdgeInsets.only(left: 24, right: 24, top: 12),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'Close',
            style: Theme.of(context).textTheme.subtitle.copyWith(
              color: Colors.grey,
              fontWeight: FontWeight.bold
            ),
          ),
          onPressed: Navigator.of(context).pop,
        ),
      ],
    );
  }
  
  _loadConnectionStatus() async {
    bool isConnectedNow = await ConnectivityHelper.hasConnection();
    setState(() => isConnected = isConnectedNow);
  }

  Widget _noConnectionNotice(){
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              'No connection found',
              style: Theme.of(context).textTheme.subtitle.copyWith(
                color: Colors.grey,
              )
            ),
          ),
          Icon(
            Icons.signal_wifi_off,
            color: Colors.red,
          )
        ],
      ),
    );
  }
}