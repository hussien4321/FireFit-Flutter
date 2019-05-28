import 'package:flutter/material.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:middleware/middleware.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'onboard_details.dart';

class UsernamePage extends StatefulWidget {

  OnboardUser onboardUser;
  Observable<bool> isUsernameTaken;
  ValueChanged<String> checkUsername;
  ValueChanged<OnboardUser> onSave;

  UsernamePage({
    @required this.onboardUser,
    @required this.isUsernameTaken,
    @required this.checkUsername,
    @required this.onSave,
  });

  @override
  _UsernamePageState createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernamePage> with SnackbarMessages {
  
  TextEditingController displayNameController = new TextEditingController();
  TextEditingController usernameController = new TextEditingController();
  
  FocusNode usernameFocus =FocusNode();
  
  @override
  void initState() {
    displayNameController.text = widget.onboardUser.name;
    usernameController.text = widget.onboardUser.username;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomPadding: false,
      body: StreamBuilder<bool>(
        stream: widget.isUsernameTaken,
        builder: (context, isUsernameTakenSnapshot){
          if(isUsernameTakenSnapshot.hasData){
            widget.onboardUser.isUsernameTaken = isUsernameTakenSnapshot.data;
            widget.onSave(widget.onboardUser);
          }
          return OnboardDetails(
            icon: FontAwesomeIcons.user,
            title: "What shall we call you?",
            children: <Widget>[
              Container(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        controller: displayNameController,
                        onChanged: (newString) {
                          widget.onboardUser.name = newString;
                          widget.onSave(widget.onboardUser);
                        },
                        onSubmitted: (t) => FocusScope.of(context).requestFocus(usernameFocus),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Display name',
                          labelStyle: Theme.of(context).textTheme.subtitle.apply(color: Colors.blue),
                          hintText: 'Jennifer David',
                        ),
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        style: Theme.of(context).textTheme.title,
                      )
                    )
                  ],
                )
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        focusNode: usernameFocus,
                        controller: usernameController,
                        onChanged: _parseNewUsername,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Username',
                          labelStyle: Theme.of(context).textTheme.subtitle.apply(color: Colors.blue),
                          prefix: Text('@')
                        ),
                        style: Theme.of(context).textTheme.title,
                      )
                    )
                  ],
                )
              ),
              Container(
                padding: EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      usernameController.value.text.isEmpty ? '' : (widget.onboardUser.isUsernameTaken == null  ? 'Checking username...' : widget.onboardUser.isUsernameTaken ? 'Username exists' : 'Available!'),
                      style: Theme.of(context).textTheme.caption.apply(color: widget.onboardUser.isUsernameTaken == null ? Theme.of(context).disabledColor : widget.onboardUser.isUsernameTaken ? Theme.of(context).errorColor : Colors.blue),
                    )
                  ],
                ),
              )
            ],
          );
        }
      )
    );
  }

  _parseNewUsername(String newUsername) {
    String formattedUsername =_getFormattedUsername(newUsername);
    if(formattedUsername != newUsername){
      displayErrorSnackBar(context, 'Username can only contain letters & numbers');
      usernameController.text = formattedUsername;
    }
    widget.onboardUser.username = usernameController.text;
    widget.onboardUser.isUsernameTaken = null;
    widget.checkUsername(usernameController.text);
    widget.onSave(widget.onboardUser);
  }

  String _getFormattedUsername(String text) {
    text = text.replaceAll(RegExp("[^A-Za-z0-9]"), "");
    return text;
  }
}