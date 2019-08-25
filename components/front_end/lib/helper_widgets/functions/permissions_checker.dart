import 'package:permission/permission.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:notification_permissions/notification_permissions.dart' as notif;

class PermissionsChecker {

  static checkPhotoPermissions() async {
    bool isDenied = false;
    if(Platform.isAndroid){
      List<PermissionName> permissionNames = [PermissionName.Camera, PermissionName.Storage];
      await Permission.requestPermissions(permissionNames);
      var permissions = await Permission.getPermissionsStatus(permissionNames);
      isDenied = permissions.any((permission) => _isDenied(permission.permissionStatus));
    }else{
      await Permission.requestSinglePermission(PermissionName.Camera);
      var permissionStatus = await Permission.getSinglePermissionStatus(PermissionName.Camera);
      isDenied = _isDenied(permissionStatus);
    }
    if(isDenied){
      throw PlatformException(code: 'Denied permission', message: 'Found a denied permission');
    }
  }

  static bool _isDenied(PermissionStatus permissionStatus) => permissionStatus==PermissionStatus.deny || permissionStatus==PermissionStatus.notAgain;

  static checkNotificationsPermission() async {
    var permissionStatus = await notif.NotificationPermissions.getNotificationPermissionStatus();
    if(permissionStatus == notif.PermissionStatus.denied){
      throw PlatformException(code: 'Denied permission', message: 'Found a denied permission');
    }
  }
}