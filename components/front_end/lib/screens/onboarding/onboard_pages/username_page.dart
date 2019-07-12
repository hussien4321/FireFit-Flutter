import 'package:flutter/material.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:middleware/middleware.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'onboard_details.dart';
import 'package:overlay_support/overlay_support.dart';

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
          return SingleChildScrollView(
            child: OnboardDetails(
              icon: FontAwesomeIcons.user,
              title: "What shall we call you?",
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: CustomTextField(
                          controller: displayNameController,
                          onChanged: (newString) {
                            widget.onboardUser.name = newString;
                            widget.onSave(widget.onboardUser);
                          },
                          textColor: Colors.blue,
                          onSubmitted: (t) => FocusScope.of(context).requestFocus(usernameFocus),
                          title: 'Display Name',
                          titleStyle: Theme.of(context).textTheme.subtitle,
                          hintText: 'Dave Jefferson',
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ],
                  )
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: CustomTextField(
                          focusNode: usernameFocus,
                          controller: usernameController,
                          onChanged: _parseNewUsername,
                          textCapitalization: TextCapitalization.none,
                          textColor: widget.onboardUser.isUsernameTaken == null ? Colors.black : (widget.onboardUser.isUsernameTaken ? Colors.red : Colors.blue),
                          title: 'Username',
                          hintText: 'unique_name',
                          titleStyle: Theme.of(context).textTheme.subtitle,
                          textInputAction: TextInputAction.next,
                          prefix: Text(
                            ' @',
                            style: Theme.of(context).textTheme.title.copyWith(fontSize: 32),
                          ),
                        ),
                      ),
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
            ),
          );
        }
      )
    );
  }

  _parseNewUsername(String newUsername) {
    String formattedUsername =_getFormattedUsername(newUsername);
    if(formattedUsername != newUsername){
      toast('Username can only contain letters & numbers');
      usernameController.text = formattedUsername;
      usernameFocus.unfocus();
    }
    widget.onboardUser.username = usernameController.text;
    widget.onboardUser.isUsernameTaken = null;
    widget.checkUsername(usernameController.text);
    widget.onSave(widget.onboardUser);
  }

  String _getFormattedUsername(String text) {
    text = text.replaceAll(RegExp("[^A-Za-z0-9_]"), "");
    return text;
  }
}