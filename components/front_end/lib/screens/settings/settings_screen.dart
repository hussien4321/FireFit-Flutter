import 'package:flutter/material.dart';
import 'package:blocs/blocs.dart';
import 'package:front_end/providers.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:helpers/helpers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:share/share.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with LoadingAndErrorDialogs {
  
  UserBloc _userBloc;
  
  Preferences preferences = Preferences();
  String currentDefaultPage;

  String version = 'Loading...';

  String username;

  @override
  void initState() {
    super.initState();
    _loadPreferencesData();
    _loadVersion();
  }

  _loadPreferencesData() async {
    preferences.updatePreference(Preferences.DEFAULT_START_PAGE, AppConfig.MAIN_PAGES.first);
    String defaultPage = await preferences.getPreference(Preferences.DEFAULT_START_PAGE);
    setState(() {
     currentDefaultPage = defaultPage; 
    });
  }

  _loadVersion() {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        version = packageInfo.version;      
      });
  });

  }

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return CustomScaffold(
      backgroundColor: Colors.white,
      title:'Settings',
      allCaps: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SettingsHeader('Account'),
              SettingsOption(
                icon: FontAwesomeIcons.wrench,
                name: 'Default start page',
                action: _defaultStartPageDropdown(),
              ),
              SettingsOption(
                icon: FontAwesomeIcons.userSlash,
                name: 'Blocked users',
                onTap: () => CustomNavigator.goToBlockedUsersScreen(context),
              ),
              SettingsHeader('Support'),
              SettingsOption(
                icon: Icons.email,
                name: 'Suggest improvements',
                onTap: () => CustomNavigator.goToFeedbackScreen(context),
              ),
              SettingsOption(
                icon:  FontAwesomeIcons.question,
                name: 'FAQ',
                onTap: () => CustomNavigator.goToFAQScreen(context),
              ),
              SettingsHeader('Social'),
              SettingsOption(
                icon:  FontAwesomeIcons.smile,
                name: 'Invite a friend',
                onTap: _shareApp,
              ),
              SettingsOption(
                icon:  FontAwesomeIcons.twitter,
                name: 'Follow us @firefit_app',
                onTap: () => UrlLauncher.openURL(AppConfig.TWITTER_URL),
              ),
              SettingsHeader('About'),
              SettingsOption(
                icon:  FontAwesomeIcons.phone,
                name: 'Version',
                action: Text(
                  version,
                  style: Theme.of(context).textTheme.caption,
                )
              ),
              SettingsOption(
                icon:  FontAwesomeIcons.lock,
                name: 'Privacy policy',
                onTap: () => UrlLauncher.openURL(AppConfig.PRIVACY_POLICY_URL),
              ),
              SettingsOption(
                icon:  FontAwesomeIcons.envelopeOpenText,
                name: 'Terms & Conditions',
                onTap: () => UrlLauncher.openURL(AppConfig.TERMS_AND_CONDITIONS_URL),
              ),
              SettingsOption(
                icon:  FontAwesomeIcons.fileContract,
                name: 'End user license agreement',
                onTap: () => UrlLauncher.openURL(AppConfig.EULA_URL),
              ),
              SettingsOption(
                icon:  FontAwesomeIcons.copyright,
                name: 'Copyrights',
                onTap: () => UrlLauncher.openURL(AppConfig.COPYRIGHTS_URL),
              ),
              SettingsHeader('Account'),
              SettingsOption(
                icon:  Icons.delete_forever,
                iconColor: Colors.red,
                name: 'Delete account',
                onTap: () => CustomNavigator.goToDeleteAccountScreen(context),
              ),
              SettingsOption(
                icon:  FontAwesomeIcons.signOutAlt,
                iconColor: Colors.red,
                name: 'Log out',
                textColor: Colors.red,
                centerText: true,
                onTap: _confirmLogOut,
              ),
            ],
          ),
        ),
      )
    );
  }

  _initBlocs(){
    if(_userBloc == null){
      _userBloc =UserBlocProvider.of(context);
      _userBloc.currentUser.first.then((user) => username = user?.username);
    }
  }

  Widget _defaultStartPageDropdown() {
    List<String> pages = AppConfig.MAIN_PAGES;
    return DropdownButton(
      value: currentDefaultPage,
      items: pages.map((page) {
        return DropdownMenuItem(
          child: Text(
            page,
            style: TextStyle(
              inherit: true,
              color: page ==currentDefaultPage ? Colors.blue: Colors.grey
            ),
          ),
          value: page,
        );
      }).toList(),
      onChanged: (newPage) {
        preferences.updatePreference(Preferences.DEFAULT_START_PAGE, newPage);
        setState(() {
          currentDefaultPage = newPage; 
        });
      },
    );
  }
  
  _shareApp() => Share.share('I thought you might be interested in this fashion app for sharing and discussing your daily outfits: https://firefitapp.com \n\nYou can find my profile by searching for @$username in the app!');

  _confirmLogOut() {
    return showDialog(
      context: context,
      builder: (secondContext) {
        return YesNoDialog(
          title: 'Log out',
          description: 'Are you sure you want to log out?',
          yesText: 'Yes',
          noText: 'Cancel',
          onYes: () {
            _userBloc.logOut.add(null);
            Navigator.pop(context);
          },
          onDone: () {
            Navigator.pop(context);
          },
        );
      }
    ) ?? false;
  }
}