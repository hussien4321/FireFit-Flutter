import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../middleware/middleware.dart';
import '../../../../blocs/blocs.dart';
import '../../../../front_end/providers.dart';
import '../../../../front_end/helper_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../front_end/screens.dart';

class MenuNavigationScreen extends StatefulWidget {
  final int index;
  final bool hasSubscription;
  final ValueChanged<bool> onUpdateSubscriptionStatus;
  final ValueChanged<int> onPageSelected;

  MenuNavigationScreen({
    this.index,
    this.onPageSelected,
    this.onUpdateSubscriptionStatus,
    this.hasSubscription = true,
  });

  @override
  _MenuNavigationScreenState createState() => _MenuNavigationScreenState();
}

class _MenuNavigationScreenState extends State<MenuNavigationScreen> {
  UserBloc _userBloc;

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: StreamBuilder<User>(
            stream: _userBloc.currentUser,
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
                            // _menuOption(
                            //   title: 'INSPIRATION',
                            //   iconData: FontAwesomeIcons.globeAmericas,
                            //   selected: widget.index == 0,
                            //   onPressed: () => widget.onPageSelected(0)
                            // ),
                            _menuOption(
                                title: 'FIND USER',
                                iconData: FontAwesomeIcons.search,
                                onPressed: () =>
                                    CustomNavigator.goToFindUsersScreen(
                                        context)),
                            // StreamBuilder<bool>(
                            //   stream: _userBloc.currentUser.map((user) => user.hasNewFeedOutfits),
                            //   initialData: false,
                            //   builder: (context, hasFeedSnap) {
                            //     return _menuOption(
                            //       title: 'FASHION CIRCLE',
                            //       iconData: Icons.people,
                            //       selected: widget.index == 1,
                            //       onPressed: () => widget.onPageSelected(1),
                            //       showNotificationBubble: hasFeedSnap.data == true
                            //     );
                            //   }
                            // ),
                            // StreamBuilder<bool>(
                            //   stream: _userBloc.currentUser.map((user) => user.hasNewUpload),
                            //   initialData: false,
                            //   builder: (context, hasNewUploadSnap) {
                            //     return _menuOption(
                            //       title: 'WARDROBE',
                            //       iconData: FontAwesomeIcons.tshirt,
                            //       selected: widget.index == 2,
                            //       onPressed: () => widget.onPageSelected(2),
                            //       showNotificationBubble: hasNewUploadSnap.data == true
                            //     );
                            //   }
                            // ),
                            // _menuOption(
                            //   title: 'LOOKBOOKS',
                            //   iconData: FontAwesomeIcons.bookReader,
                            //   selected: widget.index == 3,
                            //   onPressed: () => widget.onPageSelected(3)
                            // ),
                            _menuOption(
                                title: 'FIREFIT+',
                                backgroundColor: widget.hasSubscription
                                    ? Colors.white
                                    : Color.fromRGBO(225, 173, 0, 1.0),
                                customIcon:
                                    Image.asset('assets/flame_gold_plus_4.png'),
                                iconData: FontAwesomeIcons.fireAlt,
                                onPressed: () => CustomNavigator
                                        .goToSubscriptionDetailsScreen(
                                      context,
                                      hasSubscription: widget.hasSubscription,
                                      onUpdateSubscriptionStatus:
                                          widget.onUpdateSubscriptionStatus,
                                    )),
                            _menuOption(
                                title: 'SETTINGS',
                                iconData: Icons.settings,
                                onPressed: () =>
                                    CustomNavigator.goToSettingsScreen(
                                      context,
                                      hasSubscription: widget.hasSubscription,
                                      onUpdateSubscriptionStatus:
                                          widget.onUpdateSubscriptionStatus,
                                    )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }

  _initBlocs() {
    if (_userBloc == null) {
      _userBloc = UserBlocProvider.of(context);
    }
  }

  Widget _profileOverview(User user) {
    Widget loadingIndicator = Center(child: CircularProgressIndicator());
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
          color: widget.hasSubscription ? null : Colors.grey[300],
          gradient: !widget.hasSubscription
              ? null
              : LinearGradient(
                  colors: [
                    Colors.yellow[800],
                    Colors.yellow,
                  ],
                  begin: Alignment(-0.7, -1.0),
                  end: Alignment(0.7, 1.0),
                )),
      child: user == null
          ? loadingIndicator
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openUserProfile(user.userId),
                child: Stack(
                  children: <Widget>[
                    Row(
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
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                user.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.headline5,
                              ),
                              Text(
                                '@${user.username}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    widget.hasSubscription
                        ? _subscriptionSticker()
                        : Container()
                  ],
                ),
              ),
            ),
    );
  }

  Widget _subscriptionSticker() {
    return Positioned(
      left: 80,
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 4),
            child: Image.asset(
              'assets/flame_gold_plus_4.png',
              width: 16,
              height: 16,
            ),
          ),
          Text(
            'FireFit+ active',
            style: Theme.of(context)
                .textTheme
                .subtitle1
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _menuOption({
    String title,
    IconData iconData,
    Widget customIcon,
    Color color,
    bool selected = false,
    VoidCallback onPressed,
    Color backgroundColor = Colors.white,
    bool showNotificationBubble = false,
  }) {
    Color selectedColor = Colors.blue;
    Color unselectedColor = Colors.black; //grey[700];
    Color displayedColor =
        color != null ? color : (selected ? selectedColor : unselectedColor);
    Widget icon = SizedBox(
      width: 32.0,
      height: 32.0,
      child: customIcon == null
          ? NotificationIcon(
              iconData: iconData,
              showBubble: showNotificationBubble,
              color: displayedColor,
            )
          : customIcon,
    );
    return Material(
      color: backgroundColor,
      child: InkWell(
        onTap: () {
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
                  style: TextStyle(
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

  _openUserProfile(String userId) {
    CustomNavigator.goToProfileScreen(
      context,
      userId: userId,
    );
  }
}
