import 'package:flutter/material.dart';
import '../../../../blocs/blocs.dart';
import '../../../../front_end/providers.dart';

class Comments extends StatefulWidget {
  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  
  OutfitBloc _outfitBloc;


  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return Container(
      
    );
  }

  _initBlocs() {
    if(_outfitBloc == null){
      _outfitBloc =OutfitBlocProvider.of(context);
      // _outfitBloc.comments()
    }
  }
}