import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';

class PermissionDialog extends StatelessWidget {
  
  static Future<void> launch(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => PermissionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Permission Denied',
            style: Theme.of(context).textTheme.title.copyWith(
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
              'This app has been denied access to obtain images. We need this permission in order to upload outfit and profile pictures.\n\nPlease go to the app settings to enable this permission and start uploading!',
              style: Theme.of(context).textTheme.subhead,
            ),
          ),
        ],
      ),
      contentPadding: EdgeInsets.only(left: 24, right: 24, top: 12),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'Close',
            style: Theme.of(context).textTheme.subtitle.copyWith(
              color: Colors.grey,
              fontWeight: FontWeight.bold
            ),
          ),
          onPressed: Navigator.of(context).pop,
        ),
        FlatButton(
          child: Text(
            'Settings',
            style: Theme.of(context).textTheme.subtitle.copyWith(
              color: Colors.grey,
              fontWeight: FontWeight.bold
            ),
          ),
          onPressed: () => _goToSettings(context) 
        )
      ],
    );
  }

  _goToSettings(BuildContext context) {
    AppSettings.openAppSettings();
    Navigator.pop(context);
  }
}