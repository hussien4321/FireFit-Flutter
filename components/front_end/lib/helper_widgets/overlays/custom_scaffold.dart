import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class CustomScaffold extends StatelessWidget {
  
  final Widget body;
  final String title;
  final Widget leading;
  final List<Widget> actions;
  final double elevation;
  final Color backgroundColor, appbarColor;
  final bool allCaps;
  final bool resizeToAvoidBottomPadding;
  
  CustomScaffold({
    @required this.body,
    @required this.title,
    this.elevation = 1,
    this.leading,
    this.actions,
    this.appbarColor= Colors.white,
    this.backgroundColor,
    this.allCaps = false,
    this.resizeToAvoidBottomPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: resizeToAvoidBottomPadding,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: elevation,
        leading: leading,
        title: Text(
          allCaps ? title.toUpperCase() : title,
          style: TextStyle(
            inherit: true,
            fontWeight: FontWeight.w300,
            fontStyle: FontStyle.italic,
            letterSpacing: 1.2,
          ),
        ),
        actions: actions,
        centerTitle: true,
        backgroundColor: appbarColor,
      ),
      body: body
    );
  }
}