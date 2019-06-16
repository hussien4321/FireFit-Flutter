import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:middleware/middleware.dart';
import 'package:blocs/blocs.dart';
import 'package:front_end/providers.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:front_end/screens.dart';

class MenuScreenNavigation extends StatefulWidget {
  
  final int index;
  final ValueChanged<int> onPageSelected;

  MenuScreenNavigation({this.index, this.onPageSelected});

  @override
  _MenuScreenNavigationState createState() => _MenuScreenNavigationState();
}

class _MenuScreenNavigationState extends State<MenuScreenNavigation> {

  UserBloc _userBloc;

  List<String> pages = [
      "INPSPIRATION",
      "FASHION CIRCLE",
      "WARDROBE",
      "PROFILE",
      "SETTINGS",
  ];
  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: StreamBuilder<User>(
        stream:_userBloc.currentUser,
        builder: (ctx, snap) {
          return SafeArea(
            child: Container(
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
                  _menuOption(
                    title: 'FASHION CIRCLE',
                    iconData: Icons.people,
                    selected: widget.index == 1,
                    onPressed: () => widget.onPageSelected(1)
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
                      child: Text(
                        'Version: 1.0.0',
                        style: Theme.of(context).textTheme.subtitle,
                      ),
                    ),
                  )
                ],
              ),
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
              ProfilePicWithShadow(
                url: user.profilePicUrl,
                userId: user.userId,
                size: 64,
                margin: EdgeInsets.all(8.0),
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
  }){
    Color selectedColor = Colors.blue;
    Color unselectedColor = Colors.grey[700];
    Color color =selected ? selectedColor :unselectedColor;
    Widget icon = Icon(
      iconData,
      color: color,
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
                    fontWeight: FontWeight.w500,
                    fontSize: 22.0,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 1.5,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Opacity(
                opacity: 0.0,
                child: icon
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
}