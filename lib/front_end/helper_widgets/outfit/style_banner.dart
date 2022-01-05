import 'package:flutter/material.dart';
import '../../../../helpers/helpers.dart';

class StyleBanner extends StatelessWidget {
  final Style style;
  final VoidCallback onTap;

  StyleBanner({this.style, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "STYLE-TAB-${style.name}",
      child: Material(
          color: style.backgroundColor,
          borderRadius: BorderRadius.circular(20.0),
          child: InkWell(
              borderRadius: BorderRadius.circular(20.0),
              onTap: onTap,
              child: Container(
                width: double.infinity,
                height: 70.0,
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      style.name,
                      style: Theme.of(context).textTheme.headline4.apply(
                            color: style.textColor,
                          ),
                    ),
                    Image.asset(
                      style.asset,
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.contain,
                    )
                  ],
                ),
              ))),
    );
  }
}
