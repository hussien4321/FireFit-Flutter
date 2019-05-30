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
  List<StreamSubscription<dynamic>> _subscriptions;

  BehaviorSubject<bool> _isSliderOpenController =BehaviorSubject<bool>(seedValue: false);

  Widget currentPage = ExploreScreen();
  
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
    return _buildDMScaffold(
      body: _buildMenuScaffold(
        body: ExploreScreen()
      )
    );
  }

  _initBlocs() async {
    if(_userBloc == null){
      _userBloc = UserBlocProvider.of(context);
      _subscriptions = <StreamSubscription<dynamic>>[
        _logInStatusListener()
      ];
      _userBloc.loadCurrentUser.add(null);
      _userBloc.registerNotificationToken.add(null);
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

  Widget _buildDMScaffold({Widget body}) {
    return InnerDrawer(
      key: _dmDrawerKey,
      position: InnerDrawerPosition.end,
      onTapClose: true,
      swipe: false,
      offset: 0.7,
      animationType: InnerDrawerAnimation.linear,
      child: DMPreviewScreen(),
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
      child: MenuScreenNavigation(),
      innerDrawerCallback: _updateMainScreenDimming,
      scaffold: _buildShading(
        body: body
      )
    );
  }

  _updateMainScreenDimming(bool isOpen){
    setState(() {
      _isSliderOpenController.add(isOpen);
    });
  }

  
  Widget _buildShading({Widget body}){
    return Stack(
      children: <Widget>[
        _buildScaffold(body: body),
        StreamBuilder<bool>(
          stream: _isSliderOpenController,
          initialData: false,
          builder: (ctx, snap) {
            return Container(
              color: snap.data ? Colors.black.withOpacity(0.5) : null
            );
          }
        )
      ],
    );
  }

  Widget _buildScaffold({Widget body}){
    return Stack(
      children: <Widget>[
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              'INSPIRATION',
              style: TextStyle(
                fontWeight: FontWeight.normal,
                // fontStyle: FontStyle.italic,
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
              _buildDMButton(),
            ],
            elevation: 0.0,
            backgroundColor: Colors.transparent,
          ),
          body: body
        ),
        StreamBuilder<bool>(
          stream: _isSliderOpenController,
          initialData: false,
          builder: (ctx, snap) {
            return Container(
              color: snap.data ? Colors.black.withOpacity(0.5) : null
            );
          }
        )
      ],
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

  Widget _buildDMButton() {
    return Center(
      child: IconButton( 
        icon: NotificationIcon(
          iconData: Icons.chat,
          messages: 3,
        ),
        onPressed: () => _dmDrawerKey.currentState.open()
      ),  
    );
  }

}