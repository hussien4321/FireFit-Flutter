import 'package:flutter/material.dart';

class MirrorFrame extends StatelessWidget {

  final double thickness;
  final Widget child;

  MirrorFrame({this.child, this.thickness = 10});


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: BorderDirectional(
          bottom: BorderSide(width: thickness, color: Colors.grey[600]),
          start: BorderSide(width: thickness, color: Colors.grey[500]),
          top: BorderSide(width: thickness, color: Colors.grey[350]),
          end: BorderSide(width: thickness, color: Colors.grey[300]),
        ),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, thickness),
            color: Colors.black.withOpacity(0.6),
            blurRadius: thickness,
            spreadRadius: -thickness/2
          )
        ],
        color: Color.fromRGBO(204, 187, 187,1.0),
      ),
      child: AspectRatio(
        aspectRatio: 0.6,
        child: child
      ),
    );
  }
}