import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:middleware/middleware.dart';
import 'package:blocs/blocs.dart';
import 'package:front_end/providers.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:front_end/screens.dart';

class MenuNavigationScreen extends StatefulWidget {
  
  final int index;
  final ValueChanged<int> onPageSelected;

  MenuNavigationScreen({this.index, this.onPageSelected});

  @override
  _MenuNavigationScreenState createState() => _MenuNavigationScreenState();
}

class _MenuNavigationScreenState extends State<MenuNavigationScreen> {

  UserBloc _userBloc;

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.grey[300],
      body: StreamBuilder<User>(
        stream:_userBloc.currentUser,
        builder: (ctx, snap) {
          return Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                _profileOverview(snap.data),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        _menuOption(
                          title: 'INSPIRATION',
                          iconData: FontAwesomeIcons.globeAmericas,
                          selected: widget.index == 0,
                          onPressed: () => widget.onPageSelected(0)
                        ),
                        _menuOption(
                          title: 'FIND USER',
                          iconData: FontAwesomeIcons.search,
                          onPressed: () => CustomNavigator.goToFindUsersScreen(context)
                        ),
                        StreamBuilder<bool>(
                          stream: _userBloc.currentUser.map((user) => user.hasNewFeedOutfits),
                          initialData: false,
                          builder: (context, hasFeedSnap) {
                            return _menuOption(
                              title: 'FASHION CIRCLE',
                              iconData: Icons.people,
                              selected: widget.index == 1,
                              onPressed: () => widget.onPageSelected(1),
                              showNotificationBubble: hasFeedSnap.data == true
                            );
                          }
                        ),
                        _menuOption(
                          title: 'WARDROBE',
                          iconData: FontAwesomeIcons.tshirt,
                          selected: widget.index == 2,
                          onPressed: () => widget.onPageSelected(2)
                        ),
                        _menuOption(
                          title: 'LOOKBOOKS',
                          iconData: FontAwesomeIcons.addressBook,
                          selected: widget.index == 3,
                          onPressed: () => widget.onPageSelected(3)
                        ),
                        _menuOption(
                          title: 'FIREFIT+',
                          iconData: FontAwesomeIcons.fireAlt,
                          color: Color.fromRGBO(255, 203, 20, 1.0),
                          onPressed: () => CustomNavigator.goToSubscriptionDetailsScreen(context)
                        ),
                        _menuOption(
                          title: 'SETTINGS',
                          iconData: Icons.settings,
                          onPressed: () => CustomNavigator.goToSettingsScreen(context)
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  _initBlocs(){
    if(_userBloc == null){
      _userBloc = UserBlocProvider.of(context);
    }
  }

  Widget _profileOverview(User user){
    Widget loadingIndicator = Center(child: CircularProgressIndicator());
    return Container(
      width: double.infinity,
      height: 100,
      child: user == null ? loadingIndicator : Material(
        color: Colors.grey[300],
        child:InkWell(
          onTap: () => _openUserProfile(user.userId),
          child: Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: ProfilePicWithShadow(
                  url: user.profilePicUrl,
                  userId: user.userId,
                  size: 64,
                  margin: EdgeInsets.all(8.0),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.headline,
                  ),
                  Text(
                    '@${user.username}',
                    style: Theme.of(context).textTheme.caption,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuOption({
    String title,
    IconData iconData,
    Color color,
    bool selected = false,
    VoidCallback onPressed,
    bool showNotificationBubble = false,
  }){
    Color selectedColor = Colors.blue;
    Color unselectedColor = Colors.grey[700];
    Color displayedColor = color != null ? color : (selected ? selectedColor :unselectedColor);
    Widget icon = SizedBox(
      width: 32.0,
      height: 32.0,
      child: NotificationIcon(
        iconData: iconData,
        showBubble: showNotificationBubble,
        color: displayedColor,
      )
    );
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: (){
          Navigator.pop(context);
          onPressed();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Row(
            children: <Widget>[
              icon,
              Expanded(
                child: Text(
                  title,
                  style:TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 22.0,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 1.5,
                    color: displayedColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    ); 
  }

  _openUserProfile(String userId){
    CustomNavigator.goToProfileScreen(context,
      userId: userId,
    );
  }
}