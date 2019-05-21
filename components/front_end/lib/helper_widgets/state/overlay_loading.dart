import 'package:flutter/material.dart';


abstract class OverlayLoading {

  void startLoading(String message, BuildContext context){
    showDialog(
      context: context,
      barrierDismissible: false,
      child: WillPopScope(
        onWillPop: () {},
        child: Dialog(
          child: Container(
            padding: EdgeInsets.only(top:20.0, bottom: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Theme(
                  data: ThemeData(
                    accentColor: Colors.blue
                  ),
                  child: CircularProgressIndicator(),
                ),
                Padding(padding: EdgeInsets.only(bottom: 10.0),),
                Text(
                  "$message...",
                  style: Theme.of(context).textTheme.button.apply(color: Colors.blue),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void stopLoading(BuildContext context){
    Navigator.pop(context);
  }

}