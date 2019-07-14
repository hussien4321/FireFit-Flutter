import 'package:flutter/material.dart';
import 'package:middleware/middleware.dart';
import 'dart:async';

typedef OutfitsBuilder = Widget Function(bool isLoading, List<Outfit> outfits);

class OutfitsStream extends StatelessWidget {
  
  final OutfitsBuilder builder;
  final Stream<bool> loadingStream;
  final Stream<List<Outfit>> outfitsStream;

  OutfitsStream({
    @required this.builder,
    @required this.loadingStream,
    @required this.outfitsStream,
  });
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: loadingStream,
      initialData: false,
      builder: (ctx, isLoadingSnap) {
        return StreamBuilder<List<Outfit>>(
          stream: outfitsStream,
          initialData: [],
          builder: (ctx, outfitsSnap) {
            return builder(isLoadingSnap.data, outfitsSnap.data);
          }
        );
      }
    );
  }
}