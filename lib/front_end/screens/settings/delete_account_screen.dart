import 'package:flutter/material.dart';
import '../../../../front_end/helper_widgets.dart';
import '../../../../blocs/blocs.dart';
import '../../../../front_end/providers.dart';
import 'dart:async';

class DeleteAccountScreen extends StatefulWidget {
  
  @override
  _DeleteAccountScreenState createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> with LoadingAndErrorDialogs {

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
    return CustomScaffold(
      title: 'Delete Account',
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32.0, left: 8, right: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _confirmationPrompt(),
              _deletionSummary(),
              _deleteButton(),
              Text(
                'Good luck on your fashion journey!👋'
              ),
            ],
          ),
        ),
      ),
    );
  }

  _initBlocs(){
    if(_userBloc==null){
      _userBloc=UserBlocProvider.of(context);
      _subscriptions = <StreamSubscription<dynamic>>[
        _loadingListener(),
      ];
    }
  }

  StreamSubscription _loadingListener(){
    return _userBloc.isLoading.listen((loadingStatus) {
      if(loadingStatus && !isOverlayShowing){
        startLoading("Deleting account", context);
        isOverlayShowing = true;
      }
      if(!loadingStatus && isOverlayShowing){
        isOverlayShowing = false;
        stopLoading(context);
      }
    });
  }

  Widget _confirmationPrompt(){
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      child: Text(
        'Are you sure you want to delete your account?😢',
        style: Theme.of(context).textTheme.overline,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _deletionSummary(){
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.caption,
        children: [
          TextSpan(
            text: "This is a",
            style: Theme.of(context).textTheme.headline5,
          ),
          TextSpan(
            text: " permanent action",
            style: Theme.of(context).textTheme.headline5.copyWith(color: Colors.red),
          ),
          TextSpan(
            text: " and you will",
            style: Theme.of(context).textTheme.headline5,
          ),
          TextSpan(
            text: " lose all your data",
            style: Theme.of(context).textTheme.headline5.copyWith(color: Colors.red),
          ),
          TextSpan(
            text: " after doing this, this includes:\n\n",
            style: Theme.of(context).textTheme.headline5,
          ),
          TextSpan(
            text: "    All your followers and people you are following\n\n" 
          ),
          TextSpan(
            text: "    All the outfits you have uploaded\n\n" 
          ),
          TextSpan(
            text: "    All the lookbooks you have created\n\n" 
          ),
          TextSpan(
            text: "Please note however, this does NOT cancel any active subscription you may have, you can do so from the app store.",
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ]
      ),
    );
  }
  
  Widget _deleteButton(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
      child: RaisedButton(
        onPressed: _confirmDelete,
        color: Colors.red,
        padding: EdgeInsets.all(16),
        child: Text(
          'Yes I want to delete my account',
          style: Theme.of(context).textTheme.headline5.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  _confirmDelete(){
    return showDialog(
      context: context,
      builder: (secondContext) {
        return YesNoDialog(
          title: 'Last chance',
          description: 'Are you absolutely sure you want to do this?',
          yesText: "I'm sure",
          yesColor: Theme.of(context).errorColor,
          noText: 'Cancel',
          noColor: Colors.grey,
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