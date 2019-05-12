import 'package:flutter/material.dart';
import 'package:hidden_drawer_menu/hidden_drawer/hidden_drawer_menu.dart';
import 'package:hidden_drawer_menu/simple_hidden_drawer/simple_hidden_drawer.dart';

class HiddenDrawerCustom extends HiddenDrawerMenu {
  
  
  HiddenDrawerCustom({
    screens,
    initPositionSelected = 0,
    backgroundColorAppBar,
    elevationAppBar = 4.0,
    iconMenuAppBar = const Icon(Icons.menu),
    backgroundMenu,
    backgroundColorMenu,
    backgroundColorContent = Colors.white,
    whithAutoTittleName = true,
    styleAutoTittleName,
    actionsAppBar,
    tittleAppBar,
    enableShadowItensMenu = false,
    curveAnimation = Curves.decelerate,
    isDraggable = true,
    enablePerspective = false,
    slidePercent = 80.0,
    verticalScalePercent = 80.0,
    contentCornerRadius = 10.0,
  }) : super(
    screens: screens,
    initPositionSelected: initPositionSelected,
    backgroundColorAppBar: backgroundColorAppBar,
    elevationAppBar: elevationAppBar,
    iconMenuAppBar: iconMenuAppBar,
    backgroundMenu: backgroundMenu,
    slidePercent: slidePercent,
    verticalScalePercent: verticalScalePercent,
    backgroundColorMenu: backgroundColorMenu,
    curveAnimation: curveAnimation,
    isDraggable: isDraggable,
    actionsAppBar: actionsAppBar,
  );

  @override
  Widget build(BuildContext context) {
    return SimpleHiddenDrawer(
      isDraggable: isDraggable,
      curveAnimation: curveAnimation,
      slidePercent: slidePercent,
      verticalScalePercent: verticalScalePercent,
      contentCornerRadius: contentCornerRadius,
      menu: buildMenu(),
      screenSelectedBuilder: (position,bloc){
        return Scaffold(
          backgroundColor: backgroundColorContent,
          appBar: AppBar(
            backgroundColor: backgroundColorAppBar,
            elevation: elevationAppBar,
            title: getTittleAppBar(position),
            leading: new IconButton(
                icon: iconMenuAppBar,
                onPressed: () {
                  bloc.toggle();
                }),
            actions: actionsAppBar,
          ),
          body: screens[position].screen,
        );
      },
    );
  }

}