import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class MenuScreenNavigation extends StatelessWidget {
  
  final VoidCallback onLogOut;

  MenuScreenNavigation({
    @required this.onLogOut,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      body: SafeArea(
        child: Container(
          child: Center(
            child: RaisedButton(
              child: Text('Log out'),
              onPressed: onLogOut,
            ),
          ),
        ),
      ),
    );
  }
}