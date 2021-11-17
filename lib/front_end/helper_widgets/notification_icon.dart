import 'package:flutter/material.dart';

class NotificationIcon extends StatelessWidget {

  final Widget child;
  final IconData iconData;
  final int messages;
  final double size;
  final Color color;
  final Color iconColor;
  final bool showBubble;

  NotificationIcon({this.child, this.iconData, this.size, this.showBubble = false, this.color, this.iconColor, this.messages = 0});

  @override
  Widget build(BuildContext context) {
    double padding = 8;
    double customDimensions;
    if(size!=null){
      customDimensions = size + padding;
    }
    return Container(
      width: customDimensions,
      height: size,
      child: Stack(
        children: <Widget>[
           Center(child: child != null? child : Icon(
            iconData,
            size: size,
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