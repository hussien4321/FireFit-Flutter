import 'package:flutter/material.dart';
import 'package:blocs/blocs.dart';
import 'package:front_end/providers.dart';
import 'package:middleware/middleware.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:front_end/screens.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum LookbookOption { EDIT, DELETE }

class LookbookScreen extends StatefulWidget {

  final Lookbook lookbook;

  LookbookScreen({this.lookbook});

  @override
  _LookbookScreenState createState() => _LookbookScreenState();
}


class _LookbookScreenState extends State<LookbookScreen> {

  OutfitBloc _outfitBloc;
  String userId;

  Lookbook lookbook;

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    lookbook = widget.lookbook;
  }

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return CustomScaffold(
      resizeToAvoidBottomPadding: false,
      title: 'Your lookbook',
      actions: <Widget>[
        _lookbookOptions()
      ],
      body: _body(),
    );
  }
  
  _initBlocs() async {
    if(_outfitBloc==null){
      _outfitBloc = OutfitBlocProvider.of(context);
      userId = await UserBlocProvider.of(context).existingAuthId.first;
      _outfitBloc.loadLookbookOutfits.add(LoadOutfits(
        userId: userId,
        lookbookId: lookbook.lookbookId,
      ));
    }
  }


  Widget _lookbookOptions(){
    List<LookbookOption> availableOptions = LookbookOption.values;
    return availableOptions.isEmpty ? Container() : PopupMenuButton<LookbookOption>(
      onSelected: (option) => _optionAction(option),
      itemBuilder: (BuildContext context) {
        return availableOptions.map((LookbookOption option) {
          return PopupMenuItem<LookbookOption>(
            value: option,
            child: Text(_optionToString(option)),
          );
        }).toList();
      },
    );
  }

  String _optionToString(LookbookOption option){
    switch (option) {
      case LookbookOption.EDIT:
        return 'Edit';
      case LookbookOption.DELETE:
        return 'Delete';
      default:
        return null;
    }
  }

  _optionAction(LookbookOption option){
    switch (option) {
      case LookbookOption.EDIT:
        _editOutfit();
        break;
      case LookbookOption.DELETE:
        _confirmDelete();
        break;
      default:
        return null;
    }
  }

  _editOutfit() => NewLookbookDialog.launch(context, lookbookToEdit: lookbook);
  
  _confirmDelete(){
    return showDialog(
      context: context,
      builder: (secondContext) {
        return YesNoDialog(
          title: 'Delete Lookbook',
          description: 'Are you sure you want to delete this lookbook?',
          yesText: 'Yes',
          noText: 'Cancel',
          onYes: () {
            _outfitBloc.deleteLookbook.add(lookbook);
            Navigator.pop(context);
          },
          onDone: () {
            Navigator.pop(context);
          },
        );
      }
    ) ?? false;
  }

  Widget _body() {
    return OutfitsStream(
      loadingStream: _outfitBloc.isLoading,
      outfitsStream: _outfitBloc.lookbookOutfits,
      builder: (isLoading, outfits) {
        return StreamBuilder<List<Lookbook>>(
          stream: _outfitBloc.lookbooks,
          builder: (ctx, lookbooksSnap) {
            if(lookbooksSnap.hasData && lookbooksSnap.data != null){
              lookbook = lookbooksSnap.data.firstWhere((lb) => lb.lookbookId==lookbook.lookbookId, orElse: null);
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _lookbookDetails(),
                _lookbookOutfitsOverview(isLoading, outfits),
              ],
            );
          }
        );
      }
    );
  }

  Widget _lookbookDetails() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 4),
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        border: BorderDirectional(
          bottom: BorderSide(
            color: Colors.black54,
            width: 0.5
          )
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _outfitsTitle(),
          _outfitsDescription(),
        ],
      ),
    );
  }
  Widget _outfitsTitle(){
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        lookbook.name,
        style: Theme.of(context).textTheme.headline,
      ),
    );
  }
  Widget _outfitsDescription(){
    bool hasDescription = lookbook.description!=null;
    return Text(
      hasDescription ? lookbook.description : 'No description added',
      style: hasDescription ? Theme.of(context).textTheme.subhead.apply(color: Colors.grey[700]) : Theme.of(context).textTheme.caption,
    );
  }

  Widget _lookbookOutfitsOverview(bool isLoading, List<Outfit> outfits) {
    return Column(
      children: <Widget>[
        outfits.isEmpty ? Container() : _lookbookOutfitsManagementOptions(),
        _outfitsGrid(isLoading, outfits),
      ],
    );
  }

  Widget _lookbookOutfitsManagementOptions(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _newLookbookButton(),
        _sortingButton(),
      ],
    );
  }

  Widget _newLookbookButton() {
    return FlatButton(
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Icon(
              isEditing? Icons.remove_red_eye : Icons.edit,
              color: Colors.black,
            ),
          ),
          Text(
            isEditing ? 'View' : 'Edit',
            style: TextStyle(
              inherit: true,
              color: Colors.black,
            ),
          )
        ],
      ),
      onPressed: _toggleEdit
    );
  }

  _toggleEdit() {
    setState(() {
      isEditing = !isEditing; 
    });
  }

  Widget _sortingButton() {
    return FlatButton(
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              'Last Added',
              style: TextStyle(
                inherit: true,
                color: Colors.grey,
              ),
            ),
          ),
          Icon(
            Icons.trending_up,
            color: Colors.grey,
          ),
        ],
      ),
      onPressed: () {},
    );
  }

  Widget _outfitsGrid(bool isLoading, List<Outfit> outfits) { 
    return OutfitsGrid(
      isLoading: isLoading,
      outfits: outfits,
      customOverlay: isEditing ? _editOverlay : null,
      emptyText: 'You have no outfits in this lookbook.\nGo to the inspiration page to find a suitable outfit to add to the lookbook!',
      onRefresh: () async {
        _outfitBloc.loadMyOutfits.add(LoadOutfits(
          userId: userId,
          lookbookId: lookbook.lookbookId,
          forceLoad: true,
        ));
      },
      onReachEnd: () => _outfitBloc.loadLookbookOutfits.add(
        LoadOutfits(
          userId: userId,        
          lookbookId: lookbook.lookbookId,
          startAfterOutfit: outfits.last
        )
      ),
    );
  }

  Widget _editOverlay(Outfit outfit) {
    return SizedBox(
      child: Material(
        color: Colors.black54,
        child: InkWell(
          onTap: () => _confirmRemoveOutfit(outfit),
          child: Container(
            child: Center(
              child: Icon(
                Icons.remove_circle_outline,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }


  _confirmRemoveOutfit(Outfit outfit){
    return showDialog(
      context: context,
      builder: (secondContext) {
        return YesNoDialog(
          title: 'Remove from lookbook',
          description: 'Are you sure you want to remove this outfit from your lookbook?',
          yesText: 'Yes',
          noText: 'Cancel',
          onYes: () {
            _outfitBloc.deleteSave.add(DeleteSave(
              userId: userId,
              save: outfit.save,
            ));
          },
          onDone: () {
            Navigator.pop(context);
          },
        );
      }
    ) ?? false;
  }
}