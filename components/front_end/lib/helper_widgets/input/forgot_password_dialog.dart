import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:overlay_support/overlay_support.dart';
import 'package:validate/validate.dart';

class ForgotPasswordDialog extends StatefulWidget {

  static Future<void> launch(BuildContext context, {ValueChanged<String> onSubmitEmail, String email}) {
    return showDialog(
      context: context,
      builder: (ctx) => ForgotPasswordDialog(
        onSubmitEmail: onSubmitEmail,
        email: email,
      ),
    );
  }

  final ValueChanged<String> onSubmitEmail;
  final String email;

  ForgotPasswordDialog({this.onSubmitEmail, this.email});

  @override
  _ForgotPasswordDialogState createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {

  bool isConnected = true;

  TextEditingController _emailController = new TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Reset Password',
            style: Theme.of(context).textTheme.title.copyWith(
              fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Please input your email below to reset your password',
              style: Theme.of(context).textTheme.body1,
            ),
          ),
          _emailField(),
        ],
      ),
      contentPadding: EdgeInsets.only(left: 24, right: 24, top: 12),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'Cancel',
            style: Theme.of(context).textTheme.subtitle.copyWith(
              color: Colors.grey,
              fontWeight: FontWeight.bold
            ),
          ),
          onPressed: Navigator.of(context).pop,
        ),
        FlatButton(
          child: Text(
            'Submit',
            style: Theme.of(context).textTheme.subtitle.copyWith(
              color: hasEmail ? Colors.blue : Colors.grey,
              fontWeight: FontWeight.bold
            ),
          ),
          onPressed: hasEmail ? _submitEmail : null,
        ),
      ],
    );
  }

  bool get hasEmail {
    bool hasText = _emailController.text != null && _emailController.text.isNotEmpty;
    if(!hasText) return false;
    try {
      Validate.isEmail(_emailController.text);
      return true;
    } catch (e) {
      return false;
    }
  }

  Widget _emailField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: <Widget>[
          TextField(
            autofocus: true,
            controller: _emailController,
            onChanged: (s) => setState(() {}),
            onSubmitted: (s) => _submitEmail(),
            decoration: InputDecoration.collapsed(
              hintText: 'Email',
            ),
            style: TextStyle(
              inherit: true,
              color: Colors.blue
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.black54,
          )
        ],
      ),
    );
  }

  _submitEmail() {
    String email =_emailController.text;
    widget.onSubmitEmail(email);
    toast("Sending request...");
    Navigator.pop(context);
  }

}