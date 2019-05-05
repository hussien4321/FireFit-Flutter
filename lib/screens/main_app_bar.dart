import 'package:flutter/material.dart';
import 'package:mira_mira/screens.dart';
import 'dart:ui';
import 'package:hidden_drawer_menu/hidden_drawer/screen_hidden_drawer.dart';
import 'package:hidden_drawer_menu/hidden_drawer/hidden_drawer_menu.dart';
import 'package:hidden_drawer_menu/menu/item_hidden_menu.dart';

class MainAppBar extends StatefulWidget {
  MainAppBar({Key key}) : super(key: key);

  @override
  _MainAppBarState createState() => _MainAppBarState();
}

class _MainAppBarState extends State<MainAppBar> {
  List<ScreenHiddenDrawer> itens = new List();

  @override
  void initState() {
    itens.add(new ScreenHiddenDrawer(
      new ItemHiddenMenu(
        name: "Explore",
        colorLineSelected: Colors.blue,
      ),
      ExploreOutfitsScreen()
    ));
    itens.add(new ScreenHiddenDrawer(
      new ItemHiddenMenu(
        name: "Your Feed",          
        colorLineSelected: Colors.blue,
      ),
      ExploreOutfitsScreen()
    ));
    itens.add(new ScreenHiddenDrawer(
      new ItemHiddenMenu(
        name: "Lookbooks",
        colorLineSelected: Colors.blue,
      ),
      ExploreOutfitsScreen()
    ));
    itens.add(new ScreenHiddenDrawer(
      new ItemHiddenMenu(
        name: "Saved outfits",          
        colorLineSelected: Colors.blue,
      ),
      ExploreOutfitsScreen()
    ));
    itens.add(new ScreenHiddenDrawer(
      new ItemHiddenMenu(
        name: "Settings",
        colorLineSelected: Colors.blue,
      ),
      ExploreOutfitsScreen()
    ));
    itens.add(new ScreenHiddenDrawer(
      new ItemHiddenMenu(
        name: "Logout",
        colorLineSelected: Colors.blue,
      ),
      ExploreOutfitsScreen()
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return HiddenDrawerMenu(
      backgroundColorMenu: Color.fromRGBO(255, 194, 88, 1.0),
      curveAnimation: Curves.easeOut,
      backgroundColorAppBar: Colors.white,
      elevationAppBar: 0.0,
      screens: itens,
      initPositionSelected: 0,
      slidePercent: 92.0,
      verticalScalePercent: 60.0,
      isDraggable: false,
      // backgroundMenu: DecorationImage(
      //   image: AssetImage(
      //     'assets/background_wall.jpg'
      //   ),
      //   fit:BoxFit.cover,
      //   colorFilter: ColorFilter.mode(
      //     Colors.black38, BlendMode.multiply)
      // ),
      tittleAppBar: Center(
        child: Text(
          'MIRA MIRA'
        ),
      ),
      actionsAppBar: <Widget>[
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Icon(Icons.chat)
        )
      ],
    );
    
  }
}