import 'package:flutter/material.dart';
import 'package:blocs/blocs.dart';
import 'package:front_end/providers.dart';
import 'dart:async';

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