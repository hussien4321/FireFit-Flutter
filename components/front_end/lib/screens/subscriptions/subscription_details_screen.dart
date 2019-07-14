import 'package:flutter/material.dart';
import 'package:front_end/helper_widgets.dart';

class SubscriptionDetailsScreen extends StatefulWidget {
  @override
  _SubscriptionDetailsScreenState createState() => _SubscriptionDetailsScreenState();
}

class _SubscriptionDetailsScreenState extends State<SubscriptionDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'FireFit+',
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.restore),
          onPressed: null,
        )
      ],
      body: UnderConstructionNotice(),
    );
  }
}