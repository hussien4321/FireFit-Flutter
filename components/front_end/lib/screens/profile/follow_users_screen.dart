import 'package:flutter/material.dart';
import 'package:blocs/blocs.dart';
import 'package:front_end/providers.dart';
import 'package:middleware/middleware.dart';
import 'package:meta/meta.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:front_end/screens.dart';

class FollowUsersScreen extends StatefulWidget {

  final bool isFollowers;
  final String selectedUserId;
  
  FollowUsersScreen({
    @required this.isFollowers,
    @required this.selectedUserId,
  });

  @override
  _FollowUsersScreenState createState() => _FollowUsersScreenState();
}

class _FollowUsersScreenState extends State<FollowUsersScreen> {
  
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
      (widget.isFollowers ? _userBloc.loadFollowers : _userBloc.loadFollowing).add(
        LoadUsers(
          userId: widget.selectedUserId,
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
      title: widget.isFollowers ? 'Followers' : 'Following',
      body: Container(
        child: StreamBuilder<bool>(
          stream: _userBloc.isLoadingFollows,
          initialData: true,
          builder: (ctx, loadingSnap) {
            return StreamBuilder<List<User>>(
              stream: widget.isFollowers? _userBloc.followers : _userBloc.following,
              initialData: [],
              builder: (ctx, snap){
                List<User> users = snap.data;
                if(users.length > 0){
                  lastUser = users.last;
                }
                return ListView(
                  controller: _controller,
                  children: users.map((user) => _followUserTab(user)).toList()..add(_userLoadTab(loadingSnap.data, users.isEmpty)),
                );
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
      LoadUsers loadUsers =LoadUsers(
        userId: widget.selectedUserId,
      );
      if(widget.isFollowers){
        _userBloc.loadFollowers.add(loadUsers);
      }else{
        _userBloc.loadFollowing.add(loadUsers);
      }
      currentUserId =await _userBloc.existingAuthId.first;
    }
  }

  Widget _userLoadTab(bool isLoading, bool isEmptyList){
    String followName = widget.isFollowers ? 'followers' : 'following';
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
            'Loading ${isEmptyList?'':'more '}$followName',
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      )
    );
  }

  Widget _followUserTab(User user){
    FollowUser followUser =FollowUser(
      followed: user,
      followerUserId: currentUserId,
    );
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
              currentUserId == user.userId ? Container() :
              RaisedButton(
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Text(
                        user.isFollowing ? 'Following' : 'Follow',
                        style: Theme.of(context).textTheme.button.apply(color: Colors.white),
                      ),
                    ),
                    Icon(
                      user.isFollowing ? Icons.check : Icons.person_add,
                      color: Colors.white,
                    ),
                  ],
                ),
                color: user.isFollowing ? Colors.purple : Colors.grey,
                onPressed: () => _userBloc.followUser.add(followUser),
              )
            ],
          ),
        ),
      ),
    );
  }


  _openProfile(User user){
    CustomNavigator.goToProfileScreen(context, true, userId: user.userId);
  }
}