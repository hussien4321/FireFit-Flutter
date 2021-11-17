import 'package:flutter/material.dart';

class YesNoDialog extends StatelessWidget {
  

  final String title, description, yesText, noText, icon;
  final VoidCallback onYes, onNo, onDone;
  final Color yesColor, noColor;

  YesNoDialog({this.title, this.description, this.yesText, this.noText, this.onYes, this.onNo, this.onDone, this.icon, this.yesColor = Colors.blue, this.noColor});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.overline),
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
              style: Theme.of(context).textTheme.bodyText1,
            ),
            Container(
              padding: EdgeInsets.only(left: 5.0, right:5.0, bottom: 5.0, top: 10.0),
              child : Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  _customFlatButton(context,
                    color: noColor != null ? noColor : Theme.of(context).errorColor,
                    text: noText,
                    onTap: () {
                      if(onNo != null){
                        onNo();
                      }
                      if(onDone != null){
                        onDone();
                      }
                    }
                  ),
                  Padding( padding: EdgeInsets.all(8.0)),
                  _customFlatButton(context,
                    color: yesColor,
                    text: yesText,
                    onTap: () {
                      onYes();
                      if(onDone != null){
                        onDone();
                      }
                    }
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

  Widget _customFlatButton(BuildContext context, {String text, Color color, VoidCallback onTap}){
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Text(
          text,
          style: Theme.of(context).textTheme.button.apply(color: color), 
        ),
      ),
      onTap: onTap
    );
  }
}