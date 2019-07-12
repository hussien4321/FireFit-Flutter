import 'package:flutter/material.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:blocs/blocs.dart';
import 'package:front_end/providers.dart';
import 'package:overlay_support/overlay_support.dart';

class FindUsersScreen extends StatefulWidget {
  @override
  _FindUsersScreenState createState() => _FindUsersScreenState();
}

class _FindUsersScreenState extends State<FindUsersScreen> {
  
  UserBloc _userBloc;
  TextEditingController usernameController = new TextEditingController();
  FocusNode usernameFocus = FocusNode();

  bool isSearching = false;

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Find Users',
          style: TextStyle(
            inherit: true,
            fontWeight: FontWeight.w300,
            fontStyle: FontStyle.italic,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: _content(),
    );
  }

  _initBlocs(){
    if(_userBloc==null){
      _userBloc = UserBlocProvider.of(context);
    }
  }

  Widget _content() {
    return Container(
      padding: EdgeInsets.only(left: 8, right: 8, top: 16),
      child: Column(
        children: <Widget>[
          _introText(),
          _usernameField(),
          _searchButton(),
          // _results(),
        ],
      ),
    );
  }

  Widget _introText() {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        'To search for a user, type in their unique username below',
        style: Theme.of(context).textTheme.title,
      ),
    );
  }

  Widget _usernameField() {
    return CustomTextField(
      autofocus: true,
      focusNode: usernameFocus,
      controller: usernameController,
      onChanged: _parseUsername,
      textCapitalization: TextCapitalization.none,
      textColor: Colors.black,
      title: 'Username',
      hintText: 'unique_name',
      titleStyle: Theme.of(context).textTheme.subtitle,
      textInputAction: TextInputAction.next,
      prefix: Text(
        ' @',
        style: Theme.of(context).textTheme.title.copyWith(fontSize: 32),
      ),
    );
  }

  _parseUsername(String newUsername) {
    String formattedUsername =_getFormattedUsername(newUsername);
    if(formattedUsername != newUsername){
      toast('Username can only contain letters, numbers & underscores');
      usernameController.text = formattedUsername;
      usernameFocus.unfocus();
    }
  }
  String _getFormattedUsername(String text) {
    text = text.replaceAll(RegExp("[^A-Za-z0-9_]"), "");
    return text;
  }

  Widget _searchButton() {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8)
      ),
      color: Colors.black87,
      child: Text(
        'Search',
        style: Theme.of(context).textTheme.subhead.copyWith(
          inherit: true,
          color: Colors.white
        ),
      ),
      onPressed: _search,
    );
  }

  _search() {
    // _userBloc.selectUser
  }
}