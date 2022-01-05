import 'package:flutter/material.dart';
import '../../../../front_end/helper_widgets.dart';
import 'dart:async';
import '../../../../blocs/blocs.dart';
import '../../../../front_end/providers.dart';
import '../../../../middleware/middleware.dart';
import 'package:overlay_support/overlay_support.dart';

class AddToLookbookDialog extends StatefulWidget {
  static Future<void> launch(BuildContext context, {OutfitSave outfitSave}) {
    return showDialog(
        context: context,
        builder: (ctx) => AddToLookbookDialog(
              outfitSave: outfitSave,
            ));
  }

  final OutfitSave outfitSave;

  AddToLookbookDialog({this.outfitSave});

  @override
  _AddToLookbookDialogState createState() => _AddToLookbookDialogState();
}

class _AddToLookbookDialogState extends State<AddToLookbookDialog> {
  OutfitBloc _outfitBloc;

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return AlertDialog(
      elevation: 0,
      title: Text(
        'Add to Lookbook',
        style: Theme.of(context)
            .textTheme
            .subtitle1
            .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      content: _content(),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'Cancel',
            style: Theme.of(context)
                .textTheme
                .subtitle2
                .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          onPressed: Navigator.of(context).pop,
        ),
        FlatButton(
          child: Text(
            'New Lookbook',
            style: Theme.of(context)
                .textTheme
                .subtitle2
                .copyWith(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
          onPressed: () => NewLookbookDialog.launch(context),
        ),
      ],
    );
  }

  _initBlocs() {
    if (_outfitBloc == null) {
      _outfitBloc = OutfitBlocProvider.of(context);
    }
  }

  Widget _content() {
    return LookbooksStream(
      loadingStream: _outfitBloc.isLoadingItems,
      lookbooksStream: _outfitBloc.lookbooks,
      builder: (isLoading, lookbooks) {
        lookbooks.sort((a, b) => -a.createdAt.compareTo(b.createdAt));
        return lookbooks.isEmpty
            ? _noLookbooksPrompt()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: lookbooks
                    .map((lookbook) => _lookbookTag(
                        lookbook,
                        lookbooks.indexWhere(
                                (l) => l.lookbookId == lookbook.lookbookId) ==
                            0))
                    .toList(),
              );
      },
    );
  }

  _noLookbooksPrompt() {
    return Container(
      width: double.infinity,
      child: Text(
        'No lookbooks created',
        style: Theme.of(context).textTheme.button.apply(color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _lookbookTag(Lookbook lookbook, bool isFirst) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            height: 0.5,
            color: isFirst ? Colors.transparent : Colors.black54,
          ),
        ),
        Container(
          width: double.infinity,
          child: InkWell(
            onTap: () => _addOutfitToLookbook(lookbook),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 4),
              child: Text(
                lookbook.name,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  _addOutfitToLookbook(Lookbook lookbook) {
    OutfitSave saveData = widget.outfitSave;
    saveData.lookbookId = lookbook.lookbookId;
    _outfitBloc.saveOutfit.add(saveData);
    Navigator.pop(context);
  }
}
