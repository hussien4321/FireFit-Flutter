import 'package:flutter/material.dart';
import 'dart:async';

class CustomDialog extends StatelessWidget {

  static Future<void> launch(BuildContext context, {String title, Widget content}) {
    return showDialog(
      context: context,
      builder: (ctx) => CustomDialog(
        title: title,
        content: content,
      ),
    );
  }

  final String title;
  final Widget content;

  CustomDialog({this.title, this.content});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.title.copyWith(
              fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: content,
      ),
      // contentPadding: EdgeInsets.only(left: 24, right: 24, top: 12),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'Dismiss',
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
}