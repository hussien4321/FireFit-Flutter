import 'package:flutter/material.dart';

class YesNoDialog extends StatelessWidget {
  

  final String title, description, yesText, noText, icon;
  final VoidCallback onYes, onNo;

  YesNoDialog({this.title, this.description, this.yesText, this.noText, this.onYes, this.onNo, this.icon});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.title),
          icon==null ? Container() : Padding(
            padding: EdgeInsets.only(left:5.0),
            child: Image.asset(
              icon,
              width: 20.0,
              height: 20.0,
            ),
          ),
        ],
      ),
      content: new SingleChildScrollView(
        child: new ListBody(
          children: <Widget>[
            new Text(
              description,
              style: Theme.of(context).textTheme.body2,
            ),
            Container(
              padding: EdgeInsets.only(left: 5.0, right:5.0, bottom: 5.0, top: 10.0),
              child : Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      color: Theme.of(context).errorColor,
                      elevation: 2.0,
                      child: Text(
                        noText,
                        style: Theme.of(context).textTheme.button.apply(color: Colors.white), 
                      ),
                      onPressed: onNo
                    ),
                  ),
                  Padding( padding: EdgeInsets.all(5.0)),
                  Expanded(
                    child: RaisedButton(
                      color: Colors.blue,
                      elevation: 2.0,
                      child: Text(
                        yesText,
                        style: Theme.of(context).textTheme.button.apply(color: Colors.white), 
                      ),
                      onPressed: onYes
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: null,
    );
  }
}