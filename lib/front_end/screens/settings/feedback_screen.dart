import 'package:flutter/material.dart';
import '../../../../front_end/helper_widgets.dart';
import '../../../../middleware/middleware.dart';
import '../../../../blocs/blocs.dart';
import '../../../../front_end/providers.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter/gestures.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with LoadingAndErrorDialogs {
  TextEditingController _messageController = TextEditingController();

  FeedbackRequest _feedbackRequest = FeedbackRequest();

  UserBloc _userBloc;
  List<StreamSubscription<dynamic>> _subscriptions;
  bool isOverlayShowing = false;

  final String _emailLink =
      'mailto:progrs.software@gmail.com?subject=User%20Feedback&body=Hi%20there,%0D%0A%0D%0AI wanted to give some feedback for FireFit:%0D%0A%0D%0A';

  @override
  void dispose() {
    _subscriptions?.forEach((subscription) => subscription.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return CustomScaffold(
      title: "Feedback",
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: <Widget>[
              _feedbackPrompt(),
              _typeSelection(),
              _messageInput(),
              _receiveResponseCheck(),
              _sendButton(),
              _emailContactTag(),
            ],
          ),
        ),
      ),
    );
  }

  _initBlocs() async {
    if (_userBloc == null) {
      _userBloc = UserBlocProvider.of(context);
      String userId = await _userBloc.existingAuthId.first;
      setState(() => _feedbackRequest.userId = userId);
      _subscriptions = <StreamSubscription<dynamic>>[
        _loadingListener(),
        _successListener(),
      ];
    }
  }

  StreamSubscription _loadingListener() {
    return _userBloc.isLoading.listen((loadingStatus) {
      if (loadingStatus && !isOverlayShowing) {
        startLoading("Sending feedback", context);
        isOverlayShowing = true;
      }
    });
  }

  StreamSubscription _successListener() {
    return _userBloc.isSuccessful.listen((isSuccessful) {
      if (isOverlayShowing) {
        stopLoading(context);
        isOverlayShowing = false;
        _messageController.clear();
        setState(() => _feedbackRequest.message = null);
      }
      if (isSuccessful) {
        _thankYouDialog();
      } else {
        displayError('Failed to send', context);
      }
    });
  }

  _thankYouDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Thank you!!! ❤️',
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          "Thanks for helping make FireFit even better!\n\nWe are always working on new features but we will get to your request as soon as possible!",
          style: Theme.of(context).textTheme.subtitle1,
        ),
        contentPadding: EdgeInsets.only(left: 24, right: 24, top: 12),
        actions: <Widget>[
          FlatButton(
              child: Text(
                'Close',
                style: Theme.of(context)
                    .textTheme
                    .subtitle2
                    .copyWith(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              }),
        ],
      ),
    );
  }

  Widget _feedbackPrompt() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        'We would love to hear your thoughts!',
        style: Theme.of(context).textTheme.subtitle1,
      ),
    );
  }

  Widget _typeSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('Type of message'),
        DropdownButton(
          value: _feedbackRequest.type,
          items: FeedbackType.values.map((type) {
            return DropdownMenuItem(
              child: Text(
                feedbackTypeToString(type),
                style: TextStyle(
                    inherit: true,
                    color: type == _feedbackRequest.type
                        ? Colors.blue
                        : Colors.grey),
              ),
              value: type,
            );
          }).toList(),
          onChanged: (newType) {
            setState(() {
              _feedbackRequest.type = newType;
            });
          },
        ),
      ],
    );
  }

  Widget _messageInput() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0), color: Colors.grey[350]),
      margin: EdgeInsets.only(bottom: 16.0),
      padding: EdgeInsets.all(8.0),
      width: double.infinity,
      child: TextField(
        controller: _messageController,
        onChanged: (newMessage) {
          if (newMessage.isEmpty) {
            newMessage = null;
          }
          setState(() {
            _feedbackRequest.message = newMessage;
          });
        },
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.newline,
        maxLines: 5,
        maxLength: 500,
        maxLengthEnforced: true,
        style: Theme.of(context).textTheme.subtitle1,
        decoration: new InputDecoration.collapsed(
          hintText: "Leave your message here",
        ),
      ),
    );
  }

  Widget _receiveResponseCheck() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('Receive an email back from our team?'),
        Checkbox(
          value: _feedbackRequest.isRequestingResponse,
          onChanged: (newVal) =>
              setState(() => _feedbackRequest.isRequestingResponse = newVal),
          activeColor: Colors.blue,
        )
      ],
    );
  }

  Widget _sendButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: RaisedButton(
        color: Colors.blue,
        child: Text(
          'Send Feedback',
          style: Theme.of(context)
              .textTheme
              .subtitle1
              .copyWith(color: Colors.white),
        ),
        onPressed: _feedbackRequest.canBeSent ? _sendFeedback : null,
      ),
    );
  }

  _sendFeedback() {
    _userBloc.sendFeedback.add(_feedbackRequest);
  }

  Widget _emailContactTag() {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .copyWith(color: Colors.grey),
              children: [
                TextSpan(
                  text: 'Alternatively, you can email us directly at ',
                ),
                TextSpan(
                  text: 'progrs.software@gmail.com',
                  style: TextStyle(
                      inherit: true,
                      color: Colors.blue,
                      decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = _createEmailTemplate,
                ),
              ]),
        ));
  }

  _createEmailTemplate() async {
    if (await canLaunch(_emailLink)) {
      await launch(_emailLink);
    } else {
      toast("Failed to open mail app");
    }
  }
}
