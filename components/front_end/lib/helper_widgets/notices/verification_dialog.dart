import 'package:flutter/material.dart';
import 'package:front_end/helper_widgets.dart';
import 'dart:async';
import 'package:blocs/blocs.dart';
import 'package:front_end/providers.dart';
import 'package:overlay_support/overlay_support.dart';

class VerificationDialog extends StatefulWidget {

  static Future<void> launch(BuildContext context, {String actionName, String emailAddress}) {
    return showGeneralDialog(
      barrierColor: Colors.
      black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {  
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Opacity(
            opacity: a1.value,
            child: VerificationDialog(
              actionName: actionName,
              emailAddress: emailAddress,
            )
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 200),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {}
    );
  }

  final String actionName;
  final String emailAddress;

  VerificationDialog({this.actionName, this.emailAddress});

  @override
  _VerificationDialogState createState() => _VerificationDialogState();
}

class _VerificationDialogState extends State<VerificationDialog> {

  bool isVerified = false;

  bool isSendingEmail = false;
  bool emailCooldown = false;
  
  UserBloc _userBloc;

  @override
  void initState() {
    super.initState();
    _refresh();
  }


  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return AlertDialog(
      elevation: 0,
      title: Text(
        'Just one thing... 👋',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.title.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold
        ),
      ),
     content: _content(),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'Close',
            style: Theme.of(context).textTheme.subtitle.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold
            ),
          ),
          onPressed: Navigator.of(context).pop,
        ),
      ],
    );
  }

  _initBlocs() {
    if(_userBloc==null){
      _userBloc = UserBlocProvider.of(context);
    }
  }

  Widget _content() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.subhead.copyWith(
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: "Before you can "
                  ),
                  TextSpan(
                    text: widget.actionName,
                    style: TextStyle(
                      inherit: true,
                      fontWeight: FontWeight.bold,
                      color: Colors.black
                    )
                  ),
                  TextSpan(
                    text: ", we need you to verify your email "
                  ),
                  TextSpan(
                    text: "${widget.emailAddress}\n\n",
                    style: TextStyle(
                      inherit: true,
                      fontWeight: FontWeight.bold
                    )
                  ),
                  TextSpan(
                    text: "To do this:\n",
                    style: TextStyle(
                      inherit: true,
                      fontWeight: FontWeight.bold
                    )
                  ),
                  TextSpan(
                    text: "1) Send a verification email using the button below ",
                  ),
                  TextSpan(
                    text: "(might be in spam)\n",
                    style: TextStyle(
                      inherit: true,
                      color: Colors.black54,
                    )
                  ),
                  TextSpan(
                    text: "2) Click the link in the email to verify\n3) Press the refresh status button to complete the process!",
                  ),
                ]
              ),
            )
          ),
          _button(
            text: emailCooldown ? 'Email sent!' : isSendingEmail ? 'Sending...' : 'Send verification email',
            onPressed: isSendingEmail || emailCooldown ? null : _sendVerificatonEmail
          ),
          _verificationStatus(),
          isVerified ? Container() : _backgroundLoading(),
        ],
      ),
    );
  }

  Widget _button({String text, VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8)
        ),
        color: Colors.black87,
        child: Text(
          text,
          style: TextStyle(
            inherit: true,
            color: Colors.white
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _verificationStatus() {
    Color verificationColor = isVerified ? Colors.blue : Colors.red; 
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              'Current Status',
              style: Theme.of(context).textTheme.subtitle,
            ),
          ),
          Text(
            isVerified ? 'Verified' : 'Unverified',
            style: Theme.of(context).textTheme.button.copyWith(
              color: verificationColor,
            )
          ),
          Icon(
            isVerified ? Icons.check : Icons.close,
            color: verificationColor,
          )
        ],
      ),
    );
  }

  Widget _backgroundLoading() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Text(
                'Checking for updates...',
                style: Theme.of(context).textTheme.button.copyWith(
                  color: Colors.black54,
                )
              ),
            ),
            Theme(
              data: ThemeData(
                accentColor: Colors.black54
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 4),
                child: Container(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'Could take ~30 Seconds',
            style: Theme.of(context).textTheme.caption.copyWith(color: Colors.black38),
          ),
        ),
      ],
    );
  }

  _sendVerificatonEmail() async {
    setState(() {
     isSendingEmail=true; 
    });
    await Future.delayed(Duration(seconds: 1));
    _userBloc.resendVerificationEmail.add(null);
    toast("Email Sent!");
    setState(() {
     emailCooldown = true;
     isSendingEmail = false; 
    });
    Future.delayed(Duration(seconds: 60), () => setState(() => emailCooldown=false));
  }

  _refresh() async {
    bool newIsVerified = false;
    while(!newIsVerified){
      if(!mounted){
        print('closign');
        return;
      }
      print('refreshing');
      await Future.delayed(Duration(seconds: 3));
      _userBloc.refreshVerificationEmail.add(null);
      newIsVerified = await _userBloc.isEmailVerified.first;
    }
    if(newIsVerified){
      setState(() {
        isVerified = newIsVerified; 
      });
    }
  }
}