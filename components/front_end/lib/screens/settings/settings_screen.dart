import 'package:flutter/material.dart';
import 'package:blocs/blocs.dart';
import 'package:front_end/providers.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:helpers/helpers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'package:package_info/package_info.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with LoadingAndErrorDialogs {
  
  UserBloc _userBloc;
  List<StreamSubscription<dynamic>> _subscriptions;
  
  bool isOverlayShowing = false;
  
  Preferences preferences = Preferences();
  String currentDefaultPage;

  String version = 'Loading...';

  @override
  void dispose() {
    _subscriptions?.forEach((subscription) => subscription.cancel());
    super.dispose();
  }

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
              SettingsHeader('Config'),
              SettingsOption(
                icon: FontAwesomeIcons.wrench,
                name: 'Default start page',
                action: _defaultStartPageDropdown(),
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
              ),
              SettingsHeader('Social'),
              SettingsOption(
                icon:  FontAwesomeIcons.smile,
                name: 'Invite a friend',
              ),
              SettingsOption(
                icon:  FontAwesomeIcons.twitter,
                name: 'Follow us',
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
              ),
              SettingsOption(
                icon:  FontAwesomeIcons.envelopeOpenText,
                name: 'Terms of service',
              ),
              SettingsOption(
                icon:  FontAwesomeIcons.copyright,
                name: 'Copyrights',
              ),
              SettingsHeader('Account'),
              SettingsOption(
                icon:  Icons.delete_forever,
                iconColor: Colors.red,
                name: 'Delete account',
                onTap: _confirmDelete,
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
      _subscriptions = <StreamSubscription<dynamic>>[
        _loadingListener(),
      ];
    }
  }

  StreamSubscription _loadingListener(){
    return _userBloc.isLoading.listen((loadingStatus) {
      if(loadingStatus && !isOverlayShowing){
        startLoading("Deleting user", context);
        isOverlayShowing = true;
      }
      if(!loadingStatus && isOverlayShowing){
        isOverlayShowing = false;
        stopLoading(context);
      }
    });
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

  _confirmDelete(){
    return showDialog(
      context: context,
      builder: (secondContext) {
        return YesNoDialog(
          title: 'Delete Account',
          description: 'Are you sure you want to delete this account?\n(NOTE: This action is PERMANENT and cannot be undone!)',
          yesText: 'Yes',
          noText: 'Cancel',
          onYes: () {
            _userBloc.deleteUser.add(null);
          },
          onDone: () {
            Navigator.pop(context);
          },
        );
      }
    ) ?? false;
  }
}