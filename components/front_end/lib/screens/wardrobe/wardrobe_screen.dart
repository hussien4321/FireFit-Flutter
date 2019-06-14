import 'package:flutter/material.dart';
import 'package:blocs/blocs.dart';
import 'package:front_end/providers.dart';
import 'package:middleware/middleware.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:front_end/screens.dart';

class WardrobeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Container(
          child: Column(
            children: <Widget>[
              TabBar(
                tabs: <Widget>[
                  Tab(text: 'MY UPLOADS',),
                  Tab(text: 'SAVED',),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    CustomOutfitsGrid(
                      isSavedOutfits: false,
                    ),
                    CustomOutfitsGrid(
                      isSavedOutfits: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class CustomOutfitsGrid extends StatefulWidget {

  final bool isSavedOutfits;

  CustomOutfitsGrid({this.isSavedOutfits = false});

  @override
  _CustomOutfitsGridState createState() => _CustomOutfitsGridState();
}

class _CustomOutfitsGridState extends State<CustomOutfitsGrid> {

  OutfitBloc _outfitBloc;
  String userId;
  OutfitsSearch searchParams = OutfitsSearch(); 

  bool isMyOutfits = true;
  
  @override
  void initState() {
    super.initState();
    isMyOutfits = !widget.isSavedOutfits;
 }
 
  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return StreamBuilder<bool>(
      stream: _outfitBloc.isLoading,
      initialData: false,
      builder: (ctx, isLoadingSnap) {
        return StreamBuilder<List<Outfit>>(
          stream: _outfitBloc.outfits,
          initialData: [],
          builder: (ctx, outfitsSnap) {
            return OutfitsGrid(
              isLoading: isLoadingSnap.data,
              outfits: outfitsSnap.data,
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
      if(isMyOutfits){
        _outfitBloc.loadMyOutfits.add(searchParams);
      }
      if(widget.isSavedOutfits){
        _outfitBloc.loadSavedOutfits.add(searchParams);
      }
    }
  }

}