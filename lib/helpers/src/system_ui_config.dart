import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SystemUiConfig {

  static void setStatusBar(){
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]); 
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.grey[100],
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark
    ));

  }
}