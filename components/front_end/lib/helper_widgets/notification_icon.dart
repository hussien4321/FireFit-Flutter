import 'package:flutter/material.dart';

class NotificationIcon extends StatelessWidget {

  final Widget child;
  final IconData iconData;
  final int messages;
  final Color color;
  final Color iconColor;
  final bool showBubble;

  NotificationIcon({this.child, this.iconData, this.showBubble = false, this.color, this.iconColor, this.messages = 0});

  @override
  Widget build(BuildContext context) {
    
    return Container(
      child: Stack(
        children: <Widget>[
           Center(child: child != null? child: Icon(
            iconData,
            color: color,
          )),
          showBubble || messages > 0 ? Positioned(
            top: 0,
            right: 0,
            child: new Container(
              decoration: new BoxDecoration(
                color: iconColor == null ? Colors.red : iconColor,
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(
                minWidth: 12,
                minHeight: 12,
              ),
              child: Center(
                child: messages > 0 ? Text(
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
}