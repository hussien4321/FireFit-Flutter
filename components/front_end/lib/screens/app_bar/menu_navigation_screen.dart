import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:middleware/middleware.dart';
import 'package:blocs/blocs.dart';
import 'package:front_end/providers.dart';
import 'package:front_end/helper_widgets.dart';
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

  List<String> pages = [
      "INSPIRATION",
      "FASHION CIRCLE",
      "WARDROBE",
      "PROFILE",
      "SETTINGS",
  ];
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
                _menuOption(
                  title: 'INSPIRATION',
                  iconData: Icons.search,
                  selected: widget.index == 0,
                  onPressed: () => widget.onPageSelected(0)
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
                  title: 'SETTINGS',
                  iconData: Icons.settings,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (ctx) => SettingsScreen()
                    ));
                  }
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _logOutButton(),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Version: 1.0.0',
                            style: Theme.of(context).textTheme.subtitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
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
    bool selected = false,
    VoidCallback onPressed,
    bool showNotificationBubble = false,
  }){
    Color selectedColor = Colors.blue;
    Color unselectedColor = Colors.grey[700];
    Color color =selected ? selectedColor :unselectedColor;
    Widget icon = SizedBox(
      width: 32.0,
      height: 32.0,
      child: NotificationIcon(
        iconData: iconData,
        showBubble: showNotificationBubble,
        color: color,
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
                    color: color,
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
    CustomNavigator.goToProfileScreen(context, true,
      userId: userId,
    );
  }

  Widget _logOutButton() {
    return Container(
      width: double.infinity,
      child: FlatButton(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Sign out',
          style:TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 22.0,
            color: Colors.redAccent[700],
          ),
          textAlign: TextAlign.center,
        ),
        onPressed: _confirmLogOut,
      ),
    );
  }

  _confirmLogOut() {
    return showDialog(
      context: context,
      builder: (secondContext) {
        return YesNoDialog(
          title: 'Sign out',
          description: 'Are you sure you want to sign out?',
          yesText: 'Yes',
          noText: 'No',
          onYes: () {
            _userBloc.logOut.add(null);
            Navigator.pop(context);
          },
          onDone: () {
            Navigator.pop(context);
          },
        );
      }
    ) ?? false;
  }
}