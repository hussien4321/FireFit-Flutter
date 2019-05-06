import 'package:flutter/material.dart';

class NotificationIcon extends StatelessWidget {

  final IconData iconData;
  final int messages;
  final bool displayNum;

  NotificationIcon({this.iconData, this.displayNum = true, this.messages = 0});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Center(child: Icon(iconData)),
          shouldShowBubble ? Positioned(
            top: 0,
            right: 0,
            child: new Container(
              decoration: new BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(
                minWidth: 12,
                minHeight: 12,
              ),
              child: Center(
                child: displayNum ? Text(
                  "${messages > 9 ? 9 : messages}${messages>9?'+':''}",
                  style: new TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                  ),
                  textAlign: TextAlign.center,
                ) :
                Container(),
              ),
            ),
          ) : Container()
        ],
      ),
    );
  }

  bool get shouldShowBubble => messages > 0 || !displayNum;
}