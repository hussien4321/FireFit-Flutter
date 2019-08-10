import 'package:flutter/material.dart';
import 'package:front_end/screens.dart';
import 'package:middleware/middleware.dart';
import 'package:blocs/blocs.dart';
import 'package:front_end/providers.dart';
import 'package:front_end/helper_widgets.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {


  OutfitBloc _outfitBloc;
  String userId;

  bool isMyOutfits = true;
  
  @override
  void initState() {
    super.initState();
 }
 
  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return Container(
      color: Colors.grey[300],
      child: StreamBuilder<bool>(
        stream: _outfitBloc.isLoadingItems,
        initialData: false,
        builder: (ctx, isLoadingSnap) {
          return StreamBuilder<List<Outfit>>(
            stream: _outfitBloc.feedOutfits,
            initialData: [],
            builder: (ctx, outfitsSnap) {
              return FeedOutfits(
                isLoading: isLoadingSnap.data,
                outfits: outfitsSnap.data,
                onRefresh: () async {
                  _outfitBloc.loadFeedOutfits.add(LoadOutfits(
                    userId: userId,
                    forceLoad: true,
                  ));
                },
                onReachEnd: (lastOutfit) {
                  _outfitBloc.loadFeedOutfits.add(LoadOutfits(
                    userId: userId,
                    startAfterOutfit: lastOutfit,
                  ));
                }
              );
            },
          );
        },
      ),
    );
  }
  
  _initBlocs() async {
    if(_outfitBloc==null){
      _outfitBloc = OutfitBlocProvider.of(context);
      userId = await UserBlocProvider.of(context).existingAuthId.first;
      // _outfitBloc.loadFeedOutfits.add(LoadOutfits(
      //   userId: userId
      // ));
    }
  }
}