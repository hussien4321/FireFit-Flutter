import 'package:flutter/material.dart';
import 'package:mira_mira/screens.dart';

class MainAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.menu),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.chat)
          )
        ],
        title: Text('MIRA MIRA'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      backgroundColor: Colors.orangeAccent[100],
      body: MagicMirrorScreen()
    );
  }
}