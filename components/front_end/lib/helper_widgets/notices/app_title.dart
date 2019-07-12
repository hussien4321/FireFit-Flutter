import 'package:flutter/material.dart';

class AppTitle extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white54
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'FireFit',
                  style: Theme.of(context).textTheme.display3.copyWith(
                    color: Colors.black,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
                Image.asset(
                  'assets/firefit_logo.png',
                  width: 48,
                  height: 48,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}