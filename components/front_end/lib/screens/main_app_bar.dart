import 'package:flutter/material.dart';
import 'package:front_end/screens.dart';
import 'package:front_end/helper_widgets.dart';
import 'dart:ui';
import 'package:hidden_drawer_menu/hidden_drawer/screen_hidden_drawer.dart';
import 'package:hidden_drawer_menu/hidden_drawer/hidden_drawer_menu.dart';
import 'package:hidden_drawer_menu/menu/item_hidden_menu.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';

class MainAppBar extends StatefulWidget {
  MainAppBar({Key key}) : super(key: key);

  @override
  _MainAppBarState createState() => _MainAppBarState();
}

class _MainAppBarState extends State<MainAppBar> {
  final GlobalKey<InnerDrawerState> _innerDrawerKey = GlobalKey<InnerDrawerState>();

  List<ScreenHiddenDrawer> itens = new List();

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
  Widget build(BuildContext context) {
    return _buildDMScaffold(
      body: _buildMenuScaffold(
        screens: itens
      )
    );
  }

  Widget _buildDMScaffold({Widget body}) {
    return InnerDrawer(
      key: _innerDrawerKey,
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

  Widget _buildMenuScaffold({List<ScreenHiddenDrawer> screens}){
    return HiddenDrawerMenu(
      backgroundMenu: DecorationImage(
        image: AssetImage('assets/background_wall.jpg'),
        fit: BoxFit.fitWidth
      ),
      backgroundColorMenu: Color.fromRGBO(255, 194, 88, 1.0),
      curveAnimation: Curves.easeOut,
      backgroundColorAppBar: Colors.white,
      screens: screens,
      initPositionSelected: 0,
      slidePercent: 90.0,
      elevationAppBar: 0.0,
      verticalScalePercent: 60.0,
      isDraggable: false,
      styleAutoTittleName: TextStyle(),
      actionsAppBar: <Widget>[
        _buildIconButton(context),
      ],
    );
  }

  Widget _buildIconButton(BuildContext context) {
    return Center(
      child: IconButton( 
        icon: NotificationIcon(
          iconData: Icons.chat,
          messages: 3,
        ),
        onPressed: () => _innerDrawerKey.currentState.open()
      ),  
    );
  }
}