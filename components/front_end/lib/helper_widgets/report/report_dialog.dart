import 'package:flutter/material.dart';
import 'package:front_end/helper_widgets.dart';
import 'dart:async';
import 'package:blocs/blocs.dart';
import 'package:front_end/providers.dart';
import 'package:middleware/middleware.dart';
import 'package:overlay_support/overlay_support.dart';

class ReportDialog extends StatefulWidget {

  static Future<void> launch(BuildContext context, {String reportedUserId, int reportedOutfitId}) {
    return showDialog(
      context: context,
      builder: (ctx) => ReportDialog(
        reportedOutfitId: reportedOutfitId,
        reportedUserId: reportedUserId,
      )
    );
  }

  final String reportedUserId;
  final int reportedOutfitId;

  ReportDialog({
    this.reportedUserId,
    this.reportedOutfitId,
  });

  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {

  UserBloc _userBloc;

  String userId;

  ReportForm _reportForm =ReportForm();

  TextEditingController _descriptionController = TextEditingController();

  FocusNode descriptionFocus;

  bool canUpload = false;

  @override
  void initState() {
    super.initState();
    _reportForm.reportedUserId = widget.reportedUserId;
    _reportForm.reportedOutfitId = widget.reportedOutfitId;
    if(widget.reportedOutfitId!=null){
      _reportForm.type =ReportType.OUTFIT;
    }
  }

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return AlertDialog(
      elevation: 0,
      title: Text(
        'Report',
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
            'Report',
            style: Theme.of(context).textTheme.subtitle.copyWith(
              color: _reportForm.canBeSent ? Colors.red : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: _reportForm.canBeSent ? _createLookbook : null,
        ),
      ],
    );
  }

  _initBlocs() async {
    if(_userBloc==null){
      _userBloc = UserBlocProvider.of(context);
      String userId = await _userBloc.existingAuthId.first;
      setState(() => _reportForm.reporterUserId = userId);
    }
  }

  _createLookbook() {
    _userBloc.reportUser.add(_reportForm);
    Navigator.pop(context);
  }

  Widget _content() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _typeSelection(),
          Padding(padding: EdgeInsets.only(bottom: 8),),
          _descriptionField(),
        ],
      ),
    );
  }

  
  Widget _typeSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          'Type of report',
          style: TextStyle(
            inherit: true,
            color: Colors.grey
          ),
        ),
        DropdownButton(
          value: _reportForm.type,
          items: ReportType.values.map((type) {
            return DropdownMenuItem(
              child: Text(
                reportTypeToString(type),
                style: TextStyle(
                  inherit: true,
                  color: type==_reportForm.type ? Colors.red: Colors.grey
                ),
              ),
              value: type,
            );
          }).toList(),
          onChanged: (newType) {
            setState(() {
              _reportForm.type = newType; 
            });
          },
        ),
      ],
    );  }

  Widget _descriptionField() {
    return Column(
      children: <Widget>[
        TextField(
          focusNode: descriptionFocus,
          controller: _descriptionController,
          onChanged: (desc) {
            if(desc.isEmpty){
              desc = null;
            }
            setState(() => _reportForm.description = desc);
          }, 
          decoration: InputDecoration.collapsed(
            hintText: 'Report Details'
          ),
          maxLines: 3,
          maxLength: 300,
          maxLengthEnforced: true,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.newline,
        ),
        Container(
          height: 1,
          width: double.infinity,
          color: Colors.black54,
        )
      ],
    );
  }
}