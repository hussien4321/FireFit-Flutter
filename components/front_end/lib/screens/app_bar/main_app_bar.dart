import 'package:flutter/material.dart';
import 'package:front_end/screens.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:helpers/helpers.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:front_end/providers.dart';
import 'package:blocs/blocs.dart';
import 'dart:async';
import 'package:middleware/middleware.dart';
import 'package:rxdart/rxdart.dart';

class MainAppBar extends StatefulWidget {
  MainAppBar({Key key}) : super(key: key);

  @override
  _MainAppBarState createState() => _MainAppBarState();
}

class _MainAppBarState extends State<MainAppBar> {
  final GlobalKey<InnerDrawerState> _dmDrawerKey = GlobalKey<InnerDrawerState>();
  final GlobalKey<InnerDrawerState> _menuDrawerKey = GlobalKey<InnerDrawerState>();

  UserBloc _userBloc;
  NotificationBloc _notificationBloc;
  List<StreamSubscription<dynamic>> _subscriptions;

  BehaviorSubject<bool> _isSliderOpenController =BehaviorSubject<bool>(seedValue: false);

  Widget currentPage = ExploreScreen();

  int currentIndex = 0;
  List<Widget> currentPages = [
    ExploreScreen(),
    UnderConstructionNotice(),
    WardrobeScreen(),
  ];

  List<String> pages = [
      "INPSPIRATION",
      "FASHION CIRCLE",
      "WARDROBE",
      "PROFILE",
      "SETTINGS",
  ];

  @override
  void dispose() {
    super.dispose();
    _subscriptions?.forEach((subscription) => subscription.cancel());
    _isSliderOpenController.close();
  }

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return _buildNotificationsScaffold(
      body: _buildMenuScaffold(
        body: currentPages[currentIndex]
      )
    );
  }

  _initBlocs() async {
    if(_userBloc == null){
      _userBloc = UserBlocProvider.of(context);
      _notificationBloc = NotificationBlocProvider.of(context);
      _subscriptions = <StreamSubscription<dynamic>>[
        _logInStatusListener()
      ];
      _userBloc.loadCurrentUser.add(null);
      String userId = await _userBloc.existingAuthId.first;
      _notificationBloc.registerNotificationToken.add(userId);
      _notificationBloc.loadNotifications.add(userId);
    }
  }
  
  StreamSubscription _logInStatusListener(){
    return _userBloc.accountStatus.listen((accountStatus) {
      if(accountStatus != UserAccountStatus.LOGGED_IN){
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (ctx) => RouteConverters.getFromAccountStatus(accountStatus)
        ));
      }
    });
  }

  Widget _buildNotificationsScaffold({Widget body}) {
    return InnerDrawer(
      key: _dmDrawerKey,
      position: InnerDrawerPosition.end,
      onTapClose: true,
      swipe: false,
      offset: 0.7,
      animationType: InnerDrawerAnimation.linear,
      child: NotificationsScreen(),
      innerDrawerCallback: _updateMainScreenDimming,
      scaffold: body
    );
  }

  Widget _buildMenuScaffold({Widget body}){
    return InnerDrawer(
      key: _menuDrawerKey,
      position: InnerDrawerPosition.start,
      onTapClose: true,
      swipe: false,
      offset: 0.7,
      animationType: InnerDrawerAnimation.linear,
      child: MenuScreenNavigation(
        index: currentIndex,
        onPageSelected: (newIndex) => currentIndex = newIndex,
      ),
      innerDrawerCallback: _updateMainScreenDimming,
      scaffold: _buildScaffold(
        body: body
      )
    );
  }

  _updateMainScreenDimming(bool isOpen){
    setState(() {
      _isSliderOpenController.add(isOpen);
    });
  }

  Widget _buildScaffold({Widget body}){
    return Stack(
      children: <Widget>[
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              pages[currentIndex],
              style: TextStyle(
                fontWeight: FontWeight.normal,
                letterSpacing: 1.5
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.menu
              ),
              onPressed: () => _menuDrawerKey.currentState.open(),
            ),
            centerTitle: true,
            actions: <Widget>[
              _buildUploadButton(),
              _buildNotificationsButton(),
            ],
            elevation: 0.0,
            backgroundColor: Colors.transparent,
          ),
          body: body
        ),
        _buildShading(),
      ],
    );
  }

  Widget _buildShading(){
    return SafeArea(
      child: StreamBuilder<bool>(
        stream: _isSliderOpenController,
        initialData: false,
        builder: (ctx, snap) {
          return Container(
            color: snap.data ? Colors.black.withOpacity(0.5) : null
          );
        }
      ),
    );
  }

  Widget _buildUploadButton(){
    return IconButton(
      icon: Hero(
        tag: MMKeys.uploadButtonHero,
        child: Icon(Icons.add_a_photo),
      ),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => UploadOutfitScreen()
        ));
      }
    );
  }

  Widget _buildNotificationsButton() {
    return Center(
      child: IconButton( 
        icon: NotificationIcon(
          iconData: Icons.notifications,
          messages: 1,
        ),
        onPressed: () => _dmDrawerKey.currentState.open()
      ),  
    );
  }

}