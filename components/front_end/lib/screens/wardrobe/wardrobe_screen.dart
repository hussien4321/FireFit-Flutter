import 'package:flutter/material.dart';
import 'package:blocs/blocs.dart';
import 'package:front_end/providers.dart';
import 'package:middleware/middleware.dart';
import 'package:front_end/screens.dart';

class WardrobeScreen extends StatefulWidget {

  @override
  _WardrobeScreenState createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {

  OutfitBloc _outfitBloc;
  String userId;
  LoadOutfits searchParams = LoadOutfits(); 
   
  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return StreamBuilder<bool>(
      stream: _outfitBloc.isLoading,
      initialData: false,
      builder: (ctx, isLoadingSnap) {
        return StreamBuilder<List<Outfit>>(
          stream: _outfitBloc.myOutfits,
          initialData: [],
          builder: (ctx, outfitsSnap) {
            return OutfitsGrid(
              emptyText: 'You have no outfits in your wardrobe, upload a new outfit to display it here',
              isLoading: isLoadingSnap.data,
              outfits: outfitsSnap.data,
              onRefresh: () async {
                _outfitBloc.loadMyOutfits.add(LoadOutfits(
                  userId: userId,
                  forceLoad: true,
                ));
              },
              onReachEnd: () => (_outfitBloc.loadMyOutfits).add(
                LoadOutfits(
                  userId: userId,
                  startAfterOutfit: outfitsSnap.data.last
                )
              ),
            );
          },
        );
      },
    );
  }
  
  _initBlocs() async {
    if(_outfitBloc==null){
      _outfitBloc = OutfitBlocProvider.of(context);
      userId = await UserBlocProvider.of(context).existingAuthId.first;
      searchParams.userId = userId;
      _outfitBloc.loadMyOutfits.add(searchParams);
    }
  }

}