
import 'package:flutter/material.dart';

class CustomFab extends StatelessWidget {

  final Color color;
  final IconData icon;
  final bool largeIcon;
  final VoidCallback onPressed;
  final bool selected;
  final bool disabled;

  CustomFab({
    this.color,
    this.icon,
    this.largeIcon = false,
    this.onPressed,
    this.selected= false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    double iconSize = largeIcon ? 30.0 : 24.0;
    double padding = largeIcon ? 8.0 : 6.0;
    return Container(
      width: iconSize + padding*2,
      height: iconSize + padding*2, 
      decoration: BoxDecoration(
        color: selected ? color : 
          disabled ? Colors.grey : Colors.white,
        shape: BoxShape.circle,
        boxShadow: selected ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 3.0,
            offset: Offset(0.0, 3)
          )
        ]
      ),
      child: IconButton(
        color: selected || disabled ? Colors.white : color,
        padding: EdgeInsets.all(padding),
        icon: Icon(icon),
        iconSize: iconSize,
        splashColor: Colors.grey.withOpacity(0.5),
        onPressed: onPressed,
      ),
    );
  }
}