import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UnderConstructionNotice extends StatelessWidget {
  
  UnderConstructionNotice();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            _remainingSpaceOccupier(),
            Icon(FontAwesomeIcons.tools),
            Container(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "This page is unfortunately still under construction, expect cool things soon!",
                style: Theme.of(context).textTheme.body2,
                textAlign: TextAlign.center,
              ),
            ),
            _remainingSpaceOccupier(),
          ],
        ),
      )
    );
  }

  Widget _remainingSpaceOccupier(){
    return Expanded(
      child: Container(),
    );
  }
}