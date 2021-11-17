import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

enum PermissionType {
  IMAGES,
  NOTIFICATIONS
} 
class PermissionDialog extends StatelessWidget {

  static Future<void> launch(BuildContext context, {PermissionType permissionType}) {
    return showDialog(
      context: context,
      builder: (ctx) => PermissionDialog(
        permissionType: permissionType
      ),
    );
  }

  final PermissionType permissionType;

  PermissionDialog({this.permissionType});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Permission Denied',
            style: Theme.of(context).textTheme.overline.copyWith(
              color: Colors.red[900],
              fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            width: double.infinity,
            child: Text(
              'FireFit has been denied access to $permissionObject.\n\nPlease go to the app settings (below) to enable this permission$footer',
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
        ],
      ),
      contentPadding: EdgeInsets.only(left: 24, right: 24, top: 12),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'Close',
            style: Theme.of(context).textTheme.subtitle1.copyWith(
              color: Colors.grey,
              fontWeight: FontWeight.bold
            ),
          ),
          onPressed: Navigator.of(context).pop,
        ),
        FlatButton(
          child: Text(
            'Settings',
            style: Theme.of(context).textTheme.subtitle1.copyWith(
              color: Colors.blue,
              fontWeight: FontWeight.bold
            ),
          ),
          onPressed: () => _goToSettings(context) 
        )
      ],
    );
  }

  String get permissionObject { 
    switch (permissionType) {
      case PermissionType.IMAGES:
        return 'the image folder';
      case PermissionType.NOTIFICATIONS:
        return 'receive notifications';
      default:
        return 'unknown';
    }
  }
  String get footer { 
    switch (permissionType) {
      case PermissionType.IMAGES:
        return ' and start uploading!';
      case PermissionType.NOTIFICATIONS:
        return '!\n\nWARNING: Not doing so will result in unexpected behaviour';
      default:
        return 'unknown';
    }
  }
  

  _goToSettings(BuildContext context) {
    openAppSettings();
    Navigator.pop(context);
  }
}