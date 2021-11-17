import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class OnboardDetails extends StatelessWidget {
  
  final IconData icon;
  final String title;
  final List<Widget> children;

  OnboardDetails({
    @required this.icon,
    @required this.title,
    @required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(20.0),
                margin: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black
                ),
                child: Icon(
                  icon,
                  size: 50.0,
                  color: Colors.white,
                ),
              ),
            ]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.overline,
                ),
              ),
            ]
          ),
        ]..addAll(
          children
        ),
      ),
    );
  }
}