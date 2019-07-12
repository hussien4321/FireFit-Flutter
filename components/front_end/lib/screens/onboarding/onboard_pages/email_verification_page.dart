import 'package:flutter/material.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:middleware/middleware.dart';
import 'package:rxdart/rxdart.dart';
import 'onboard_details.dart';

class EmailVerificationPage extends StatefulWidget {
  
  OnboardUser onboardUser;
  Observable<bool> currentEmailVerificationStatus;
  VoidCallback refreshVerificationEmail;
  VoidCallback resendVerificationEmail;
  ValueChanged<OnboardUser> onSave;


  EmailVerificationPage({
    @required this.onboardUser,
    @required this.currentEmailVerificationStatus,
    @required this.refreshVerificationEmail,
    @required this.resendVerificationEmail,
    @required this.onSave,
  });

  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> with SnackbarMessages, SingleTickerProviderStateMixin {
  
  bool isEmailVerified = false;

  static final int DURATION = 10;
  AnimationController resendController;
  Animation<int> resendAnimation;
  bool resendCoolingDown = false;

  bool isRefreshing = false;

  @override
  initState(){
    resendController = new AnimationController(
      vsync: this,
      duration: Duration(seconds: DURATION)
    );
    resendController.addStatusListener((status) {
      if(status == AnimationStatus.completed){
        resendCoolingDown = false;
        resendController.reset();
      }
    });
    resendAnimation = IntTween(begin: DURATION, end: 0).animate(resendController);
    resendController.addListener(() {
      setState((){});
    });
    super.initState();
  }

  @override
  void dispose() {
    resendController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: OnboardDetails(
        icon: Icons.email,
        title: "Verify your email",
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10.0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'A verification email has been sent to ',
                    style: Theme.of(context).textTheme.subhead
                  ),
                  TextSpan(
                    text: widget.onboardUser.email,
                    style: Theme.of(context).textTheme.subhead.apply(fontWeightDelta: 5),
                  ),
                ]
              )
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Status: ',
                      style: Theme.of(context).textTheme.subhead,
                    ),
                    TextSpan(
                      text: isEmailVerified ? 'Verified' : 'Pending',
                      style: Theme.of(context).textTheme.subhead.apply(color: isEmailVerified ? Colors.blue : Colors.grey ),
                    ),
                  ],
                ),
              ),
              RaisedButton(
                child: Text(
                  isRefreshing ? 'Refreshing' : 'Refresh',
                ),
                onPressed: isEmailVerified || isRefreshing ? null : _refresh,
              )
            ],
          ),
          Container(
            padding: EdgeInsets.all(15.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    child: Text(
                      resendCoolingDown ? 'Email sent (wait ${resendAnimation.value}s to resend)' : 'Resend email'
                    ),
                    onPressed: isEmailVerified || resendCoolingDown ? null : _resend
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _refresh() async {
    setState(() {
      isRefreshing = true;
    });
    widget.refreshVerificationEmail();
    displayNoticeSnackBar(context, 'Refreshing verification status');
    bool newVerificationStatus = await widget.currentEmailVerificationStatus.first;
    if(newVerificationStatus){
      isEmailVerified = true;
      widget.onSave(widget.onboardUser);
    }
    setState(() {
      isRefreshing = false;
    });
  }

  _resend() {
    widget.resendVerificationEmail();
    displayNoticeSnackBar(context, 'Email sent');
    setState(() {
      resendCoolingDown = true; 
    });
    resendController.forward();
  }
}