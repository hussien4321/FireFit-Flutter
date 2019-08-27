import 'package:flutter/material.dart';
import 'package:front_end/helper_widgets.dart';
import 'dart:async';
import 'package:blocs/blocs.dart';
import 'package:front_end/providers.dart';
import 'package:middleware/middleware.dart';
import 'package:overlay_support/overlay_support.dart';

class BlockDialog extends StatefulWidget {

  static Future<void> launch(BuildContext context, {String blockingUserId, String blockedUserId, String name}) {
    return showDialog(
      context: context,
      builder: (ctx) => BlockDialog(
        blockingUserId: blockingUserId,
        blockedUserId: blockedUserId,
        name: name,
      )
    );
  }

  final String blockingUserId;
  final String blockedUserId;
  final String name;

  BlockDialog({
    this.blockingUserId,
    this.blockedUserId,
    this.name,
  });

  @override
  _BlockDialogState createState() => _BlockDialogState();
}

class _BlockDialogState extends State<BlockDialog> {

  UserBloc _userBloc;

  UserBlock _userBlock = UserBlock();

  @override
  void initState() {
    super.initState();
    _userBlock.blockingUserId = widget.blockingUserId;
    _userBlock.blockedUserId = widget.blockedUserId;
  }

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return AlertDialog(
      elevation: 0,
      title: Text(
        'Block user',
        style: Theme.of(context).textTheme.headline.copyWith(
          color: Colors.red,
          fontWeight: FontWeight.bold
        ),
      ),
     content: _content(),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'Cancel',
            style: Theme.of(context).textTheme.subtitle.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold
            ),
          ),
          onPressed: Navigator.of(context).pop,
        ),
        FlatButton(
          child: Text(
            'Block',
            style: Theme.of(context).textTheme.subtitle.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: _blockUser,
        ),
      ],
    );
  }

  _initBlocs() async {
    if(_userBloc==null){
      _userBloc = UserBlocProvider.of(context);
    }
  }

  _blockUser() {
    _userBloc.blockUser.add(_userBlock);
    Navigator.popUntil(context, (s) => s.isFirst);
  }

  Widget _content() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "Are you sure you want to block ${widget.name}?\n\n",
            style: TextStyle(
              inherit: true,
              color: Colors.black
            )
          ),
          TextSpan(
            text: "Note: This will hide all outfits from this user",
            style: TextStyle(
              inherit: true,
              color: Colors.grey
            )
          ),
        ]
      ),
    );
  }
}