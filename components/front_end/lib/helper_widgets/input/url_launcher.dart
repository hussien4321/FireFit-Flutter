import 'package:url_launcher/url_launcher.dart';
import 'package:overlay_support/overlay_support.dart';

class UrlLauncher {
  
  static openURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      toast("Failed to open browser");
    }
  }
}