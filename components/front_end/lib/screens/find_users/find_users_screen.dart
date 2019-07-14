import 'package:flutter/material.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:blocs/blocs.dart';
import 'package:front_end/providers.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:middleware/middleware.dart';

class FindUsersScreen extends StatefulWidget {
  @override
  _FindUsersScreenState createState() => _FindUsersScreenState();
}

class _FindUsersScreenState extends State<FindUsersScreen> {
  
  UserBloc _userBloc;
  TextEditingController usernameController = new TextEditingController();
  FocusNode usernameFocus = FocusNode();

  bool hasSearched = false;

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return CustomScaffold(
      title:'Find User',
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
      padding: EdgeInsets.only(left: 8, right: 8),
      child: StreamBuilder<bool>(
        stream: _userBloc.isLoading,
        initialData: false,
        builder: (context, isLoadingSnap) {
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _introText(),
                _usernameField(),
                _searchButton(isLoadingSnap.data),
                _searchResult(isLoadingSnap.data),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _introText() {
    return Padding(
      padding: EdgeInsets.only(top: 16, bottom: 8),
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
      onSubmitted: (s) => _search(),
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
    setState(() {});
  }
  String _getFormattedUsername(String text) {
    text = text.replaceAll(RegExp("[^A-Za-z0-9_]"), "");
    return text;
  }

  Widget _searchButton(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8)
        ),
        color: Colors.black87,
        child: Text(
          isLoading ? 'Searching...' : 'Search',
          style: Theme.of(context).textTheme.subhead.copyWith(
            inherit: true,
            color: Colors.white
          ),
        ),
        onPressed: !isLoading && usernameController.text?.isNotEmpty == true ? _search : null,
      ),
    );
  }

  _search() {
    _userBloc.searchUser.add(usernameController.text);
    usernameFocus.unfocus();
    hasSearched = true;
  }

  Widget _searchResult(bool isLoading) {
    return isLoading || !hasSearched ?
      Container() :
      StreamBuilder<User>(
        stream: _userBloc.selectedUser,
        initialData: null,
        builder: (ctx, snap) {
          return snap.data == null ? _notFoundMessage() : _foundUser(snap.data);
        },
      );
  }

  Widget _notFoundMessage() {
    return Text(
      'No user found 😢',
      style: Theme.of(context).textTheme.subhead,
    );
  }

  Widget _foundUser(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 2),
          child: Text(
            'Found User!',
            style: Theme.of(context).textTheme.subhead,
          ),
        ),
        UserPreviewCard(user),
      ],
    );
  }
}