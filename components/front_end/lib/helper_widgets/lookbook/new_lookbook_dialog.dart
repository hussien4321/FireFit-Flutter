import 'package:flutter/material.dart';
import 'package:front_end/helper_widgets.dart';
import 'dart:async';
import 'package:blocs/blocs.dart';
import 'package:front_end/providers.dart';
import 'package:middleware/middleware.dart';
import 'package:overlay_support/overlay_support.dart';

class NewLookbookDialog extends StatefulWidget {

  static Future<void> launch(BuildContext context, {Lookbook lookbookToEdit}) {
    return showDialog(
      context: context,
      builder: (ctx) => NewLookbookDialog(lookbookToEdit: lookbookToEdit)
    );
  }

  final Lookbook lookbookToEdit;
  NewLookbookDialog({this.lookbookToEdit});

  @override
  _NewLookbookDialogState createState() => _NewLookbookDialogState();
}

class _NewLookbookDialogState extends State<NewLookbookDialog> {

  UserBloc _userBloc;
  OutfitBloc _outfitBloc;

  String userId;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  FocusNode descriptionFocus;

  bool canUpload = false;

  bool isEditing = false;

  Lookbook get lookbook => widget.lookbookToEdit;

  @override
  void initState() {
    super.initState();
    setState(() => isEditing = widget.lookbookToEdit!=null);
    if(isEditing){
      _nameController.text = lookbook.name;
      _descriptionController.text = lookbook.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return AlertDialog(
      elevation: 0,
      title: Text(
        '${isEditing?'Edit':'New'} Lookbook',
        style: Theme.of(context).textTheme.subhead.copyWith(
          color: Colors.black,
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
            isEditing?'Update':'Create',
            style: Theme.of(context).textTheme.subtitle.copyWith(
              color: canUpload ? Colors.blue : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: canUpload ? (isEditing? _editLookbook: _createLookbook): null,
        ),
      ],
    );
  }

  _initBlocs() async {
    if(_outfitBloc==null){
      _updateUploadStatus();
      _outfitBloc = OutfitBlocProvider.of(context);
      _userBloc = UserBlocProvider.of(context);
      userId = await _userBloc.existingAuthId.first;
    }
  }
  _updateUploadStatus() {
    
    setState(() {
      canUpload= hasName && (!isEditing || (hasNewName || hasNewDescription)); 
    });
  }
  bool get hasName =>  !(_nameController.text==null || _nameController.text.isEmpty); 
  bool get hasNewName => lookbook.name != _nameController.text;
  bool get hasNewDescription {
    String currentDescription = _descriptionController.text.isEmpty ? null :_descriptionController.text;
    return lookbook.description != currentDescription;
  }

  _createLookbook() {
    _outfitBloc.createLookbook.add(AddLookbook(
      name: _nameController.text,
      description: _descriptionController.text,
      userId: userId,
    ));
    Navigator.pop(context);
  }

  _editLookbook() {
    _outfitBloc.editLookbook.add(EditLookbook(
      lookbookId: lookbook.lookbookId,
      name: _nameController.text,
      description: _descriptionController.text,
      userId: userId,
    ));
    Navigator.pop(context);
  }

  Widget _content() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _nameField(),
          _descriptionField(),
        ],
      ),
    );
  }

  Widget _nameField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: <Widget>[
          TextField(
            autofocus: true,
            controller: _nameController,
            onChanged: (t) => _updateUploadStatus(),
            onSubmitted: (s) => FocusScope.of(context).requestFocus(descriptionFocus),
            decoration: InputDecoration.collapsed(
              hintText: 'Name'
            ),
            maxLength: 50,
            maxLengthEnforced: true,
            textCapitalization: TextCapitalization.words,
          ),
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.black54,
          )
        ],
      ),
    );
  }

  Widget _descriptionField() {
    return Column(
      children: <Widget>[
        TextField(
          focusNode: descriptionFocus,
          controller: _descriptionController,
          onChanged: (t) => _updateUploadStatus(),
          decoration: InputDecoration.collapsed(
            hintText: 'Description\n(optional)'
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