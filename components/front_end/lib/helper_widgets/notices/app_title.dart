import 'package:flutter/material.dart';

class AppTitle extends StatelessWidget {
  
  final Color color;

  AppTitle({this.color});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'FireFit',
          style: Theme.of(context).textTheme.display3.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        Image.asset(
          'assets/flame.png',
          width: 48,
          height: 48,
        ),
      ],
    );
  }
}