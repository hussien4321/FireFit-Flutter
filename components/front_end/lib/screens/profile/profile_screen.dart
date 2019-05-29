import 'package:flutter/material.dart';
import 'package:middleware/middleware.dart';
import 'package:blocs/blocs.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:front_end/providers.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  ProfileScreen({this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  
  UserBloc _userBloc;


  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return Scaffold(
      body: StreamBuilder<bool>(
        stream: _userBloc.isLoading,
        initialData: true,
        builder: (ctx, loadingSnap){
          return StreamBuilder<User>(
            stream: _userBloc.selectedUser,
            builder: (ctx, snap) {
              if(loadingSnap.data || !snap.hasData){
                return Center(child: CircularProgressIndicator(),);
              }
              return _profileScaffold(snap.data);
            },
          );
        }
      ),
    );
  }
  
  _initBlocs(){
    if(_userBloc == null){
      _userBloc = UserBlocProvider.of(context);
      _userBloc.selectUser.add(widget.userId);
    }
  }

  Widget _profileScaffold(User user){
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          ProfilePicWithShadow(
            hasOnClick: false,
            url: user.profilePicUrl,
            size: 64,
            margin: EdgeInsets.all(8.0),
          )
        ],
      ),
    );
  }

}