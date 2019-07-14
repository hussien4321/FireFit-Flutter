import 'package:flutter/material.dart';
import 'package:middleware/middleware.dart';
import 'dart:async';

typedef LookbooksBuilder = Widget Function(bool isLoading, List<Lookbook> lookbooks);

class LookbooksStream extends StatelessWidget {
  
  final LookbooksBuilder builder;
  final Stream<bool> loadingStream;
  final Stream<List<Lookbook>> lookbooksStream;

  LookbooksStream({
    @required this.builder,
    @required this.loadingStream,
    @required this.lookbooksStream,
  });
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: loadingStream,
      initialData: false,
      builder: (ctx, isLoadingSnap) {
        return StreamBuilder<List<Lookbook>>(
          stream: lookbooksStream,
          initialData: [],
          builder: (ctx, lookbooksSnap) {
            return builder(isLoadingSnap.data, lookbooksSnap.data); 
          }
        );
      }
    );
  }
}