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
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:overlay_support/overlay_support.dart';

class MainAppBar extends StatefulWidget {

  FirebaseMessaging messaging;

  MainAppBar({Key key,
    @required this.messaging,
  }) : super(key: key);

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

  String userId;

  Widget currentPage = ExploreScreen();

  int currentIndex = 0;
  List<Widget> currentPages = [
    ExploreScreen(),
    FeedScreen(),
    WardrobeScreen(),
  ];

  List<String> pages = [
      "INPSPIRATION",
      "FASHION CIRCLE",
      "WARDROBE",
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
      widget.messaging.configure(
        onMessage: (res) => _loadNewNotifications(),
      );
      _subscriptions = <StreamSubscription<dynamic>>[
        _logInStatusListener()
      ];
      _userBloc.loadCurrentUser.add(null);
      userId = await _userBloc.existingAuthId.first;
      _notificationBloc.registerNotificationToken.add(userId);
      _notificationBloc.loadStaticNotifications.add(userId);
    }
  }

  _loadNewNotifications() {
    _notificationBloc.loadLiveNotifications.add(userId);
    showSimpleNotification(
      Text(
        'New notification!',
        style: Theme.of(context).textTheme.title.apply(color: Colors.white),
      ),
      background: Colors.grey,
    );
  }
  
  StreamSubscription _logInStatusListener(){
    return _userBloc.accountStatus.listen((accountStatus) {
      if(accountStatus!=null && accountStatus != UserAccountStatus.LOGGED_IN){
        Navigator.pushReplacementNamed(context, RouteConverters.getFromAccountStatus(accountStatus));
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
      child: MenuNavigationScreen(
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
            leading: _buildMenuButton(),
            title: Text(
              pages[currentIndex],
              style: TextStyle(
                fontWeight: FontWeight.normal,
                letterSpacing: 1.5
              ),
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

  Widget _buildMenuButton() {
    return StreamBuilder<bool>(
      stream: _userBloc.currentUser.map((user) => user.hasNewFeedOutfits || user.hasNewFollowers),
      initialData: false,
      builder: (context, hasFeedSnap) {
        return IconButton(
          icon: NotificationIcon(
              iconData: Icons.menu,
              showBubble: hasFeedSnap.data == true,
            ),
          onPressed: () => _menuDrawerKey.currentState.open(),
        );
      }
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
      child: StreamBuilder<int>(
        stream: _userBloc.currentUser.map((user) => user.numberOfNewNotifications),
        initialData: 0,
        builder: (ctx, countSnap) { 
          int messages = 0;
          if(countSnap.data != null){
            messages =countSnap.data;
          }
          return IconButton( 
            icon: NotificationIcon(
              iconData: Icons.notifications,
              messages: messages,
            ),
            onPressed: () => _dmDrawerKey.currentState.open()
          );
        }
      )  
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

}

class MessageNotification extends StatelessWidget {
  final VoidCallback onReplay;

  const MessageNotification({Key key, this.onReplay}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: SafeArea(
        child: ListTile(
          leading: SizedBox.fromSize(
              size: const Size(40, 40),
              child: ClipOval(child: Image.asset('assets/avatar.png'))),
          title: Text('Lily MacDonald'),
          subtitle: Text('Do you want to see a movie?'),
          trailing: IconButton(
              icon: Icon(Icons.reply),
              onPressed: () {
                ///TODO i'm not sure it should be use this widget' BuildContext to create a Dialog
                ///maybe i will give the answer in the future
                if (onReplay != null) onReplay();
              }),
        ),
      ),
    );
  }
}
