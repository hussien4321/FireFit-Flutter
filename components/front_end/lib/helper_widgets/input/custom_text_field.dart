import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {

  final TextEditingController controller;
  final ValueChanged<String> onChanged, onSubmitted;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final String title, hintText;

  CustomTextField({
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.textCapitalization,
    this.textInputAction,
    this.title,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(context).textTheme.headline,
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
            controller: controller,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            textCapitalization: textCapitalization,
            textInputAction: textInputAction,
            style: Theme.of(context).textTheme.display1.apply(color: Colors.black),
            decoration: new InputDecoration.collapsed(
              hintText: hintText,
              hintStyle: Theme.of(context).textTheme.headline.apply(color: Colors.black.withOpacity(0.5))
            ),
          ),
        ),
      ],
    );
  }
}