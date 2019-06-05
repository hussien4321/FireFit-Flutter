import 'package:flutter/material.dart';
import 'package:middleware/middleware.dart';
import 'package:blocs/blocs.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:front_end/providers.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  final String heroTag;

  ProfileScreen({this.userId, this.heroTag});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  
  UserBloc _userBloc;

  final double splashSize = 200;
  final double profilePicSize = 80; 

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
      body: SafeArea(
        child: _closeButtonStack(
          child: Column(
            children: <Widget>[
              Expanded(
                              child: ListView(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(0, 2),
                            blurRadius: 2,
                            spreadRadius: -2
                          )
                        ]
                      ),
                      margin: EdgeInsets.only(bottom: profilePicSize/2 + 4),
                      child: Stack(
                        children: <Widget>[
                          _splashImage(),
                          _profilePic(user),
                        ],
                      ),
                    ),
                    _userInfo(user),
                    _spaceSeparator(),
                    _overallStatistics(user),
                    _spaceSeparator(),
                    _buildOutfitDescription(user),
                  ],
                ),
              ),
              _buildInteractButtons(user),
            ],
          ),
        ),
      ),
    );
  }

  Widget _spaceSeparator(){
    return Padding(
      padding: EdgeInsets.only(bottom: 16.0),
    );
  }

  Widget _closeButtonStack({Widget child}){
    return Stack(
      children: <Widget>[
        child,
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.white,
              ),
              onPressed: Navigator.of(context).pop,
            ),
          ),
        )
      ],
    );
  }

  Widget _splashImage(){
    return Container(
      height: splashSize,
      width: double.infinity,
      child: FitHeightBlurImage(
        url: 'https://images-na.ssl-images-amazon.com/images/I/61V5dWx7MRL._SX425_.jpg',
      ),
    );
  }
  Widget _profilePic(User user){
    return Positioned(
      bottom: 0,
      left: 0,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Transform.translate(
          offset: Offset(0, 4 + profilePicSize/2),
          child: ProfilePicWithShadow(
            hasOnClick: false,
            heroTag: widget.heroTag == null ? null : widget.heroTag,
            url: user.profilePicUrl,
            size: profilePicSize,
            margin: EdgeInsets.all(8.0),
          ),
        ),
      ),
    );
  }

  Widget _userInfo(User user){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                user.name,
                style: Theme.of(context).textTheme.title,
              ),
              Text(
                '@'+user.username,
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                user.genderIsMale ? FontAwesomeIcons.male : FontAwesomeIcons.female,
                color: Colors.black,
              ),
              Text(
                user.ageRange,
                style: Theme.of(context).textTheme.title.apply(color: Colors.black),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _overallStatistics(User user){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _buildStatisticTab(0, 'Followers'),
        _buildStatisticTab(0, 'Following'),
        _buildStatisticTab(0, 'Outfits'),
        _buildStatisticTab(0, 'Points', isEnd: true),
      ],
    );
  }
  Widget _buildStatisticTab(int count, String name, {bool isEnd = false}){
    return Expanded(
          child: Container(
        decoration: isEnd ? null :BoxDecoration(
          border: BorderDirectional(
            end: BorderSide(
              color: Colors.grey[300],
              width: 0.5
            )
          )
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('$count', style: Theme.of(context).textTheme.title),
            Text(name, style: Theme.of(context).textTheme.subhead),
          ],
        ),
      ),
    );
  }

  Widget _buildOutfitDescription(User user) {
    //TODO: ADD USER BIO FIELD!!!
    String bio = "Hi there, my name is hussien! I enjoy trying new clothes and discovering new types of fashion! Looking forward to seeing all the cool outfits people come up with on this app :D";
    if(bio == null){
      return Center(
        child: Text(
          "No bio has been added",
          style: TextStyle(
            color: Colors.grey,
            fontStyle: FontStyle.italic
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 4.0),
            child: Text(
              "Bio:",
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.grey[350]
            ),
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 16.0),
            padding: EdgeInsets.all(8.0),
            child: Text(
              bio,
              textScaleFactor: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractButtons(User user){
    return Container(
      color: Colors.grey[300],
      child: Row(
        children: <Widget>[
          Expanded(
            child: FlatButton(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.message,
                    color: Colors.green,
                  ),
                  Text(
                    'Message user',
                    style: TextStyle(color: Colors.green),
                  )
                ],
              ),
              onPressed: () {},
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: BorderDirectional(
                  start: BorderSide(
                    color: Colors.grey.withOpacity(0.5),
                    width: 0.5
                  )
                )
              ),
              child: FlatButton(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.person_add,
                      color: Colors.blue,
                    ),
                    Text(
                      'Follow user',
                      style: TextStyle(color: Colors.blue),
                    )
                  ],
                ),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}