import 'package:flutter/material.dart';
import 'package:blocs/blocs.dart';
import 'package:front_end/providers.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:helpers/helpers.dart';
import 'package:front_end/services.dart';
import 'dart:async';

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

  @override
  void dispose() {
    _subscriptions?.forEach((subscription) => subscription.cancel());
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadPreferencesData();
  }

  _loadPreferencesData() async {
    String defaultPage = await preferences.getPreference(Preferences.DEFAULT_START_PAGE);
    setState(() {
     currentDefaultPage = defaultPage; 
    });
  }

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SETTINGS',
          style: TextStyle(
            inherit: true,
            fontWeight: FontWeight.w300,
            fontStyle: FontStyle.italic,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
      ),
      body: Container(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _sectionHeader('MENU'),
              _defaultStartPage(),
              _sectionHeader('ACCOUNT'),
              _deleteAccount(),
            ],
          ),
        )
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

  Widget _sectionHeader(String title){
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8, top: 16),
      decoration: BoxDecoration(
        border: BorderDirectional(
          bottom: BorderSide(
            color: Colors.grey,
            width: 0.5
          )
        )
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.title.copyWith(
          inherit: true,
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.italic,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _defaultStartPage() {
    List<String> pages = AppConfig.MAIN_PAGES;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          'Default start page'
        ),
        DropdownButton(
          value: currentDefaultPage,
          items: pages.map((page) => DropdownMenuItem(
            child: Text(
              page,
              style: TextStyle(
                inherit: true,
                color: page ==currentDefaultPage ? Colors.blue: Colors.grey
              ),
            ),
            value: page,
          )).toList(),
          onChanged: (newPage) {
            preferences.updatePreference(Preferences.DEFAULT_START_PAGE, newPage);
            setState(() {
             currentDefaultPage = newPage; 
            });
          },
        ),
      ],
    );
  }

  Widget _deleteAccount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: FlatButton(
            child: Text(
              'DELETE ACCOUNT',
              style: Theme.of(context).textTheme.button.apply(color: Colors.red),
            ),
            onPressed: _confirmDelete,
          ),
        )
      ],
    );
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
  _deleteUser(){
    Navigator.pop(context);
    _userBloc.deleteUser.add(null);
  }
}