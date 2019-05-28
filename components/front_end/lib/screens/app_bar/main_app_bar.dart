import 'package:flutter/material.dart';
import 'package:front_end/screens.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:helpers/helpers.dart';
import 'package:hidden_drawer_menu/hidden_drawer/screen_hidden_drawer.dart';
import 'package:hidden_drawer_menu/menu/item_hidden_menu.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:front_end/providers.dart';
import 'package:blocs/blocs.dart';
import 'dart:async';
import 'package:middleware/middleware.dart';

class MainAppBar extends StatefulWidget {
  MainAppBar({Key key}) : super(key: key);

  @override
  _MainAppBarState createState() => _MainAppBarState();
}

class _MainAppBarState extends State<MainAppBar> {
  final GlobalKey<InnerDrawerState> _dmDrawerKey = GlobalKey<InnerDrawerState>();
  final GlobalKey<InnerDrawerState> _menuDrawerKey = GlobalKey<InnerDrawerState>();

  List<ScreenHiddenDrawer> itens = new List();

  UserBloc _userBloc;
  List<StreamSubscription<dynamic>> _subscriptions;

  @override
  void initState() {
    itens.add(ScreenHiddenDrawer(
      ItemHiddenMenu(name: "INPSPIRATION", colorLineSelected: Colors.blue,),//Discover new styles
      ExploreScreen()
    ));
    itens.add(ScreenHiddenDrawer(
      ItemHiddenMenu(name: "FASHION CIRCLE", colorLineSelected: Colors.blue,),//see what style your firends are rocking
      ExploreScreen()
    ));
    itens.add(ScreenHiddenDrawer(
      ItemHiddenMenu(name: "WARDROBE", colorLineSelected: Colors.blue,),//view your favourite outfits
      ExploreScreen()
    ));
    itens.add(ScreenHiddenDrawer(
      ItemHiddenMenu(name: "PROFILE", colorLineSelected: Colors.blue,),
      ExploreScreen()
    ));
    itens.add(ScreenHiddenDrawer(
      ItemHiddenMenu(name: "SETTINGS", colorLineSelected: Colors.blue,),
      ExploreScreen()
    ));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _subscriptions?.forEach((subscription) => subscription.cancel());
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
      String userId = await _userBloc.existingAuthId.first;
      _userBloc.registerNotificationToken.add(userId);
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
      colorTransition: Colors.red,
      animationType: InnerDrawerAnimation.linear,
      child: DMPreviewScreen(),
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
      colorTransition: Colors.red,
      animationType: InnerDrawerAnimation.linear,
      child: MenuScreenNavigation(
        onLogOut: () => _userBloc.logOut.add(null),
      ),
      scaffold: _buildScaffold(
        body: body
      )
    );
  }

  Widget _buildScaffold({Widget body}){
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('MIRA MRIA'),
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
      body: body,
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
  // Widget _buildMenuScaffold2({List<ScreenHiddenDrawer> screens}){
  //   return HiddenDrawerMenu(
  //     backgroundMenu: DecorationImage(
  //       image: AssetImage('assets/background_wall.jpg'),
  //       fit: BoxFit.fitWidth
  //     ),
  //     backgroundColorMenu: Color.fromRGBO(255, 194, 88, 1.0),
  //     curveAnimation: Curves.easeOut,
  //     backgroundColorAppBar: Colors.white,
  //     screens: screens,
  //     initPositionSelected: 0,
  //     slidePercent: 90.0,
  //     elevationAppBar: 0.0,
  //     verticalScalePercent: 60.0,
  //     isDraggable: false,
  //     styleAutoTittleName: TextStyle(),
  //     actionsAppBar: <Widget>[
  //       _buildIconButton(context),
  //     ],
  //   );
  // }

}