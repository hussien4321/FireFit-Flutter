import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class CustomBanner extends StatelessWidget {
  
  final IconData icon;
  final String text;
  
  CustomBanner({
    @required this.text,
    @required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Icon(
                      icon,
                      size: 48,
                    ),
                  ),
                  Text(
                    text,
                    style: Theme.of(context).textTheme.bodyText2,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      )
    );
  }
}