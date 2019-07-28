import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {

  final TextEditingController controller;
  final ValueChanged<String> onChanged, onSubmitted;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final String title, hintText;
  final TextStyle titleStyle;
  final Widget prefix;
  final FocusNode focusNode;
  final Color textColor;
  final int maxLength;
  final bool autofocus;

  CustomTextField({
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.textCapitalization,
    this.textInputAction,
    this.title,
    this.titleStyle,
    this.textColor,
    this.hintText,
    this.maxLength,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          margin: EdgeInsets.only(left: 8.0),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                title,
                style: titleStyle!=null ? titleStyle : Theme.of(context).textTheme.headline,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Container()
              ) 
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(8.0),
          margin: EdgeInsets.only(bottom: 8.0),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Colors.grey[350]
          ),
          child: TextField(
            autofocus: autofocus,
            focusNode: focusNode,
            controller: controller,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            textCapitalization: textCapitalization,
            textInputAction: textInputAction,
            maxLength: maxLength,
            maxLengthEnforced: true,
            style: Theme.of(context).textTheme.headline.apply(color: textColor != null ? textColor : Colors.black),
            decoration: new InputDecoration.collapsed(
              hintText: hintText,
              hintStyle: Theme.of(context).textTheme.headline.apply(color: Colors.black.withOpacity(0.5)),
            ).copyWith(
              prefixIcon: prefix
            ),
          ),
        ),
      ],
    );
  }
}