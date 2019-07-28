import 'package:flutter/material.dart';
import 'package:middleware/middleware.dart';
import 'package:meta/meta.dart';
import 'package:blocs/blocs.dart';
import 'package:front_end/providers.dart';
import 'package:helpers/helpers.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:front_end/screens.dart';
import 'dart:async';

class EditOutfitScreen extends StatefulWidget {
  
  final Outfit outfit;
  
  EditOutfitScreen({
    @required this.outfit,
  });
  
  @override
  _EditOutfitScreenState createState() => _EditOutfitScreenState();
}

class _EditOutfitScreenState extends State<EditOutfitScreen> with LoadingAndErrorDialogs {
  
  OutfitBloc _outfitBloc;
  EditOutfit editOutfitData;

  List<StreamSubscription<dynamic>> _subscriptions;
  bool isOverlayShowing = false;

  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  FocusNode descriptionFocus =FocusNode();

  @override
  void initState() {
    editOutfitData = EditOutfit.fromOutfit(widget.outfit);
    _titleController.text = editOutfitData.title;
    _descriptionController.text = editOutfitData.description;
    super.initState();
  }

  
  @override
  dispose(){
    _subscriptions?.forEach((subscription) => subscription.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return CustomScaffold(
      title: 'Edit Outfit',
      actions: <Widget>[
        _saveOutfitButton()
      ],
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: 8, right: 8, top: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildHeader(
                'Style',
                isUpdated: editOutfitData.style != widget.outfit.style,
              ),
              _buildStyleInput(),
              _buildHeader(
                'Title', 
                isUpdated: editOutfitData.title != widget.outfit.title,
                isEmpty: !editOutfitData.hasTitle
              ),
              _buildTitleField(),
              _buildHeader(
                'Description', 
                isUpdated: editOutfitData.description != widget.outfit.description,
              ),
              _buildDescriptionField(),
            ],
          ),
        ),
      ),
    );
  }

  _initBlocs() {
    if(_outfitBloc == null){
      _outfitBloc = OutfitBlocProvider.of(context);
      editOutfitData = EditOutfit.fromOutfit(widget.outfit);
      _subscriptions = <StreamSubscription<dynamic>>[
        _loadingListener(),
        _successListener(),
      ];

    }
  }

  StreamSubscription _loadingListener(){
    return _outfitBloc.isLoading.listen((loadingStatus) {
      if(loadingStatus && !isOverlayShowing){
        startLoading("Updating outfit", context);
        isOverlayShowing = true;
      }
      if(!loadingStatus && isOverlayShowing){
        isOverlayShowing = false;
        stopLoading(context);
      }
    });
  }
  StreamSubscription _successListener(){
    return _outfitBloc.isSuccessful.listen((successStatus) {
      if(successStatus){
        Navigator.pop(context);
      }
    });
  }

  Widget _saveOutfitButton() {
    return IconButton(
      icon: Icon(Icons.save),
      color: Colors.green,
      onPressed: hasNewData && editOutfitData.canBeUpdated ? _editOutfit : null,
    );
  }

  bool get hasNewData {
    return !(widget.outfit.title == editOutfitData.title &&
    widget.outfit.description == editOutfitData.description &&
    widget.outfit.style == editOutfitData.style);
  }

  _editOutfit() {
    _outfitBloc.editOutfit.add(editOutfitData);;
  }

  Widget _buildHeader(String title, {bool isUpdated, bool isEmpty = false}){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.headline,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: isEmpty ? Container() : Icon(
              isUpdated ? Icons.fiber_new : Icons.check,
              color: isUpdated ? Colors.amber[800] : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildStyleInput() {
    Style style = Style.fromStyleString(editOutfitData.style);
    return StyleBanner(
      style: style, 
      onTap: _selectNewStyle
    );
  }

  _selectNewStyle() async {
    String styleName = await CustomNavigator.goToStyleSelectorScreen(context);
    if(!mounted || styleName == null) return;
    setState(() {
      editOutfitData.style = styleName;    
    });
  }


  Widget _buildTitleField() {
    return Container(
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.only(bottom: 8.0),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.grey[350]
      ),
      child: TextField(
        controller: _titleController,
        onChanged: (newTitle) {
          setState((){
          editOutfitData.title = newTitle;
          });
        },
        maxLength: 50,
        maxLengthEnforced: true,
        onSubmitted: (t) => FocusScope.of(context).requestFocus(descriptionFocus),
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        style: Theme.of(context).textTheme.headline.apply(color: Colors.black),
        decoration: new InputDecoration.collapsed(
          hintText: "Theme/mood of this look...",
          hintStyle: Theme.of(context).textTheme.headline.apply(color: Colors.black.withOpacity(0.5))
        ),
      ),
    );
  } 

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.grey[350]
      ),
      margin: EdgeInsets.only(bottom: 16.0),
      padding: EdgeInsets.all(8.0),
      width: double.infinity,
      child: TextField(
        controller: _descriptionController,
        focusNode: descriptionFocus,
        onChanged: (newDesc) {
          if(newDesc.isEmpty){
            newDesc = null;
          }
          setState((){
            editOutfitData.description = newDesc;
          });
        },
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.newline,
        maxLines: 5,
        maxLength: 500,
        maxLengthEnforced: true,
        style: Theme.of(context).textTheme.subhead,
        decoration: new InputDecoration.collapsed(
          hintText: "e.g:\nWhere did you get these clothes?\nWhat inspired this fit?\nWhat do you want feedback on?",
          
        ),
      ),
    );
  }

}