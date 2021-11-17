import 'package:flutter/material.dart';
import '../../../../front_end/helper_widgets.dart';
import '../../../../helpers/helpers.dart';
import '../../../../middleware/middleware.dart';
import 'dart:async';

class SubscriptionDialog extends StatefulWidget {

  static Future<void> launch(BuildContext context, {
    String title,
    String benefit,
    int initialPage = 0,
    ValueChanged<bool> onUpdateSubscriptionStatus,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => SubscriptionDialog(
        title: title,
        benefit: benefit,
        initialPage: initialPage,
        onUpdateSubscriptionStatus: onUpdateSubscriptionStatus,
      )
    );
  }

  final String title, benefit; 
  final int initialPage;
  final ValueChanged<bool> onUpdateSubscriptionStatus;

  SubscriptionDialog({
    this.title,
    this.benefit,
    this.initialPage = 0,
    this.onUpdateSubscriptionStatus,
  });

  @override
  _SubscriptionDialogState createState() => _SubscriptionDialogState();
}

class _SubscriptionDialogState extends State<SubscriptionDialog> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0,
      title: Text(
        widget.title,
        style: Theme.of(context).textTheme.overline.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold
        ),
      ),
      content: SingleChildScrollView(
        child: Text(
          'Hi there 👋\n\nWould you like to ${widget.benefit}?\n\nYou can enjoy that and much more in FireFit+ 🙌\n\nIt also helps our team make FireFit even better ❤️'
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'No thanks',
            style: Theme.of(context).textTheme.subtitle1.copyWith(
              color: Colors.grey,
              fontWeight: FontWeight.normal
            ),
          ),
          onPressed: Navigator.of(context).pop,
        ),
        FlatButton(
          child: Text(
            'Get FireFit+',
            style: Theme.of(context).textTheme.subtitle1.copyWith(
              color: Color.fromRGBO(225, 173, 0, 1.0),
              fontWeight: FontWeight.bold
            ),
          ),
          onPressed: () async {
            await CustomNavigator.goToSubscriptionDetailsScreen(context,
              initialPage: widget.initialPage,
              hasSubscription: false,
              onUpdateSubscriptionStatus: widget.onUpdateSubscriptionStatus,
            );
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}