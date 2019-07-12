import 'package:flutter/material.dart';
import 'package:front_end/helper_widgets.dart';

class SubscriptionDetailsScreen extends StatefulWidget {
  @override
  _SubscriptionDetailsScreenState createState() => _SubscriptionDetailsScreenState();
}

class _SubscriptionDetailsScreenState extends State<SubscriptionDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'FireFit+',
          style: TextStyle(
            inherit: true,
            fontWeight: FontWeight.w300,
            fontStyle: FontStyle.italic,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.restore),
            onPressed: null,
          )
        ],
      ),
      body: UnderConstructionNotice(),
    );
  }
}