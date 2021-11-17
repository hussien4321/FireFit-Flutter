import 'package:flutter/material.dart';
import '../../../../helpers/helpers.dart';

class StyleSticker extends StatelessWidget {
  final Style style;
  final VoidCallback onTap;
  final int size;
  
  StyleSticker({this.style, this.onTap, this.size = 30});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: style.backgroundColor
      ),
      padding: EdgeInsets.all(4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              style.name,
              style: Theme.of(context).textTheme.caption.apply(
                color: style.textColor
              ),
            ),
          ),
          Image.asset(
            style.asset,
            width: 16.0,
            height: 16.0,
          )
        ],
      ),
    );
  }
}