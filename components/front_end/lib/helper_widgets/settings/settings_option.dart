import 'package:flutter/material.dart';

class SettingsOption extends StatelessWidget {

  final IconData icon;
  final Color iconColor; 
  final String name;
  final Color textColor; 
  final Widget action;
  final bool centerText;
  final VoidCallback onTap;

  SettingsOption({
    this.icon, 
    this.iconColor = Colors.blue, 
    this.name, 
    this.textColor = Colors.black, 
    this.action,
    this.centerText = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget leading = Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Icon(
        icon,
        color: iconColor,
        size: 16,
      ),
    );
    Widget endContent = Opacity(
      opacity: 0.0,
      child: leading,
    );
    if(!centerText){
      endContent = action != null ? action :
      Icon(
        Icons.navigate_next,
        color: Colors.grey,
      );
    }
    Widget body = Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: 8, top: 16, left: 8, right: 8),
      child: Row(
        children: <Widget>[
          leading,
          Expanded(
            child: Text(
              name,
              style: Theme.of(context).textTheme.subhead.copyWith(
                color: textColor,
              ),
              textAlign: centerText ? TextAlign.center :TextAlign.start,
            ),
          ),
          endContent,
        ],
      ),
    );
    if(action==null){
      body = InkWell(
        onTap: onTap,
        child: body,
      );
    }
    return body; 
  }
}