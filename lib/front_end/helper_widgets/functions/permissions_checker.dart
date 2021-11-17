import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:notification_permissions/notification_permissions.dart' as notif;

class PermissionsChecker {

  static checkPhotoPermissions() async {
    List<Permission> permissionNames = [Permission.camera];
    if(Platform.isAndroid){
      permissionNames.add(Permission.storage);
    }
    bool isDenied = false;
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
    ].request();
    isDenied = statuses.values.contains(PermissionStatus.denied);
    if(isDenied){
      throw PlatformException(code: 'Denied permission', message: 'Found a denied permission');
    }
  }

  static checkNotificationsPermission() async {
    var permissionStatus = await notif.NotificationPermissions.getNotificationPermissionStatus();
    if(permissionStatus == notif.PermissionStatus.denied){
      throw PlatformException(code: 'Denied permission', message: 'Found a denied permission');
    }
  }
}