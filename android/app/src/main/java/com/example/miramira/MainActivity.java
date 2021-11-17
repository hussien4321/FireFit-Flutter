package com.progrs.software.miramira;

import io.flutter.embedding.android.FlutterActivity;
import android.app.NotificationManager;
import android.content.Context;

public class MainActivity extends FlutterActivity {

  @Override
  protected void onResume() {
    super.onResume();
    cancelAllNotifications();
  }

  private void cancelAllNotifications() {
    NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
    notificationManager.cancelAll();
  }
}
