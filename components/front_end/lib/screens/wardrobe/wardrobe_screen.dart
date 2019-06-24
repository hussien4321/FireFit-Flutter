import 'package:flutter/material.dart';
import 'package:blocs/blocs.dart';
import 'package:front_end/providers.dart';
import 'package:middleware/middleware.dart';
import 'package:front_end/screens.dart';

class WardrobeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:DefaultTabController(
        length: 2,
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.white,
                child: TabBar(
                  indicatorColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  tabs: <Widget>[
                    Tab(text: 'MY UPLOADS',),
                    Tab(text: 'SAVED',),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
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
  LoadOutfits searchParams = LoadOutfits(); 

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
          stream: isMyOutfits ? _outfitBloc.myOutfits : _outfitBloc.savedOutfits,
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