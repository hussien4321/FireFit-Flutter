import 'package:flutter/material.dart';
import 'package:blocs/blocs.dart';
import 'package:front_end/providers.dart';
import 'package:middleware/middleware.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:front_end/helper_widgets.dart';

class BlockedUsersScreen extends StatefulWidget {

  @override
  _BlockedUsersScreenState createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  
  UserBloc _userBloc;
  String currentUserId;

  User lastUser;

  ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
  }
  _scrollListener() {
    if (_controller.offset >= (_controller.position.maxScrollExtent - 100) && !_controller.position.outOfRange) {
      _userBloc.loadBlockedUsers.add(
        LoadUsers(
          userId: currentUserId,
          startAfterUser: lastUser,
        )
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return CustomScaffold(
      title: 'Blocked Users',
      body: Container(
        child: StreamBuilder<bool>(
          stream: _userBloc.isLoadingFollows,
          initialData: true,
          builder: (ctx, loadingSnap) {
            return StreamBuilder<List<User>>(
              stream: _userBloc.blockedUsers,
              initialData: [],
              builder: (ctx, snap){
                List<User> users = snap.data;
                if(users.length > 0){
                  lastUser = users.last;
                  return ListView(
                    controller: _controller,
                    children: users.map((user) => _blockedUserTab(user)).toList()..add(_userLoadTab(loadingSnap.data, users.isEmpty)),
                  );
                }else{
                  return Center(
                    child: Text(
                      'No blocked users found',
                      style: Theme.of(context).textTheme.caption,
                    )
                  );
                }
              },
            );
          }
        ) 
      ),
    );
  }

  _initBlocs() async {
    if(_userBloc == null){
      _userBloc = UserBlocProvider.of(context);
      currentUserId =await _userBloc.existingAuthId.first;
      LoadUsers loadUsers =LoadUsers(
        userId: currentUserId,
      );
      _userBloc.loadBlockedUsers.add(loadUsers);
    }
  }

  Widget _userLoadTab(bool isLoading, bool isEmptyList){
    return !isLoading ? Container() : Container(
      padding: EdgeInsets.all(8),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircularProgressIndicator(),
          ),
          Text(
            'Loading ${isEmptyList?'':'more '} users',
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      )
    );
  }

  Widget _blockedUserTab(User user){
    return Material(
      child: InkWell(
        onTap: () => _openProfile(user),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            border: BorderDirectional(
              bottom: BorderSide(
                color: Colors.grey[300],
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              ProfilePicWithShadow(
                hasOnClick: false,
                url: user.profilePicUrl,
                size: 64,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.subhead
                    ),
                    Text(
                      '@'+user.username,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ],
                )
              ),
              RaisedButton(
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Text(
                        'Unblock',
                        style: Theme.of(context).textTheme.button.apply(color: Colors.white),
                      ),
                    ),
                    Icon(
                      FontAwesomeIcons.minusCircle,
                      color: Colors.white,
                      size: 12,
                    ),
                  ],
                ),
                color: Colors.red,
                onPressed: () => _unblockUser(user),
              )
            ],
          ),
        ),
      ),
    );
  }

  _openProfile(User user){
    CustomNavigator.goToProfileScreen(context, 
      userId: user.userId,
    );
  }

  _unblockUser(User user){
    UserBlock userBlock = UserBlock(
      blockingUserId: currentUserId,
      blockedUserId: user.userId,
    );
    return showDialog(
      context: context,
      builder: (secondContext) {
        return YesNoDialog(
          title: 'Unblock user',
          description: 'Are you sure you want to unblock ${user.name}?',
          yesText: 'Yes',
          noText: 'Cancel',
          onYes: () {
            _userBloc.unblockUser.add(userBlock);
            Navigator.pop(context);
          },
          onDone: () {
            Navigator.pop(context);
          },
        );
      }
    );    
  }
}