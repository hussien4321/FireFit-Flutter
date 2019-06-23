import 'package:flutter/material.dart';
import 'package:blocs/blocs.dart';
import 'package:front_end/providers.dart';
import 'package:front_end/helper_widgets.dart';
import 'dart:async';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with LoadingAndErrorDialogs {
  
  UserBloc _userBloc;
  List<StreamSubscription<dynamic>> _subscriptions;
  
  bool isOverlayShowing = false;

  @override
  void dispose() {
    _subscriptions?.forEach((subscription) => subscription.cancel());
    super.dispose();
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
        padding: EdgeInsets.only(left: 8, right: 8, top: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _sectionHeader('Account'),
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
        style: Theme.of(context).textTheme.subtitle.apply(fontSizeDelta: 10, color: Colors.grey),
      ),
    );
  }

  Widget _deleteAccount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          'Delete account',
          style: Theme.of(context).textTheme.subhead,
        ),
        RaisedButton(
          child: Text(
            'Delete',
            style: Theme.of(context).textTheme.button.apply(color: Colors.white),
          ),
          color: Colors.red,
          onPressed: _confirmDelete,
        )
      ],
    );
  }

  _confirmDelete(){
    return showDialog(
      context: context,
      builder: (secondContext) {
        return YesNoDialog(
          title: 'Delete Outfit',
          description: 'Are you sure you want to delete this outfit?\n(NOTE: This action is PERMANENT and cannot be undone!)',
          yesText: 'Yes',
          noText: 'No',
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