import 'package:permission/permission.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:notification_permissions/notification_permissions.dart' as notif;

class PermissionsChecker {

  static checkPermissions(List<PermissionName> permissionNames) async {
    bool isDenied = false;
    if(Platform.isAndroid){
      await Permission.requestPermissions(permissionNames);
      var permissions = await Permission.getPermissionsStatus(permissionNames);
      permissions.forEach((permission) => print('Found permission ${permission.permissionName} with status ${permission.permissionStatus}'));
      isDenied = permissions.any((permission) => permission.permissionStatus==PermissionStatus.deny || permission.permissionStatus==PermissionStatus.notAgain);
    }else{
      isDenied = true;
    }
    if(isDenied){
      throw PlatformException(code: 'Denied permission', message: 'Found a denied permission');
    }
  }
  static checkNotificationsPermission() async {
    var permissionStatus = await notif.NotificationPermissions.getNotificationPermissionStatus();
    print('permissionStatus:$permissionStatus');
    if(permissionStatus == notif.PermissionStatus.denied){
      throw PlatformException(code: 'Denied permission', message: 'Found a denied permission');
    }
  }
}