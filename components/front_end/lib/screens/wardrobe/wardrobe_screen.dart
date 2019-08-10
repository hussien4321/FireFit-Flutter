import 'package:flutter/material.dart';
import 'package:blocs/blocs.dart';
import 'package:front_end/providers.dart';
import 'package:middleware/middleware.dart';
import 'package:front_end/screens.dart';
import 'package:helpers/helpers.dart';
import 'package:helpers/helpers.dart';
import 'package:front_end/helper_widgets.dart';
import 'dart:math';
class WardrobeScreen extends StatefulWidget {

  @override
  _WardrobeScreenState createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {

  OutfitBloc _outfitBloc;
  UserBloc _userBloc;
  String userId;

  String motivationalMessage;

  Preferences preferences = Preferences();
  bool isSortingByTop = false;

  @override
  void initState() {
    super.initState();
    _generateRandomMessage();
  }
  _generateRandomMessage(){
    Random random =Random();
    List<String> allMessages = FashionMessages.MOTIVATIONAL_MESSAGES;
    motivationalMessage = allMessages[random.nextInt(allMessages.length)];
  }
   
  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return _outfitsGrid();
  }
  
  _initBlocs() async {
    if(_outfitBloc==null){
      _outfitBloc = OutfitBlocProvider.of(context);
      _userBloc = UserBlocProvider.of(context);
      userId = await _userBloc.existingAuthId.first;
      await _loadFiltersFromPreferences();
      _userBloc.markWardrobeSeen.add(userId);
      // _outfitBloc.loadMyOutfits.add(LoadOutfits(
      //   userId: userId,
      //   sortByTop: isSortingByTop
      // ));
    }
  }

  _loadFiltersFromPreferences() async {
    final newSortByTop = await preferences.getPreference(Preferences.WARDROBE_SORT_BY_TOP);
    setState(() {
      isSortingByTop = newSortByTop;
    });
  }

  Widget _wardrobeMotivation(){
    return Container(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          padding: EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            border: BorderDirectional(
              bottom: BorderSide(
                width: 0.5,
                color: Colors.black54,
              )
            )
          ),
          child: Text( 
            motivationalMessage,
            style: Theme.of(context).textTheme.subhead.apply(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _wardrobeSortOptions(User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _outfitsCount(user),
          _sortingButton(user),
        ],
      ),
    );
  }
  Widget _outfitsCount(User user){
    return user==null ? Container() : Text(
      '${user.numberOfOutfits} Upload${user.numberOfOutfits==1?'':'s'}',
      style: Theme.of(context).textTheme.title.apply(
        color: Colors.black54
      ),
    );
  }

  Widget _sortingButton(User user) {
    bool enabled = user!=null && user.numberOfOutfits > 0;
    return FlatButton(
      child: Row(
        children: <Widget>[
          Text(
            isSortingByTop ? 'Top rated' : 'Last Uploaded',
            style: TextStyle(
              inherit: true,
              color: enabled ? Colors.blue : Colors.grey,
            ),
          ),
          Icon(
            Icons.trending_up,
            color: enabled ? Colors.blue : Colors.grey,
          ),
        ],
      ),
      onPressed: enabled ? _sortList : null,
    ); 
  }

  _sortList() {
    setState(() {
      isSortingByTop = !isSortingByTop;
    });
    preferences.updatePreference(Preferences.WARDROBE_SORT_BY_TOP, isSortingByTop);
    _outfitBloc.loadMyOutfits.add(LoadOutfits(
      userId: userId,
      sortByTop: isSortingByTop,
    ));
  }


  Widget _outfitsGrid() {
    return UserStream(
      loadingStream: _userBloc.isLoading,
      userStream: _userBloc.currentUser,
      builder: (isLoadingUser, streamUser) => StreamBuilder<bool>(
        stream: _outfitBloc.isLoadingItems,
        initialData: false,
        builder: (ctx, isLoadingSnap) {
          return StreamBuilder<List<Outfit>>(
            stream: _outfitBloc.myOutfits,
            initialData: [],
            builder: (ctx, outfitsSnap) {
              bool isLoading = isLoadingSnap.data || isLoadingUser;
              List<Outfit> outfits = outfitsSnap.data;
              if(outfits.isNotEmpty){
                outfits = sortOutfits(outfits, isSortingByTop);
              }
              return OutfitsGrid(
                leading: Column(
                  children: <Widget>[
                    _wardrobeMotivation(),
                    _wardrobeSortOptions(streamUser),
                  ],
                ),
                emptyText: 'You have no outfits in your wardrobe, upload a new outfit to display it here',
                isLoading: isLoading,
                outfits: outfitsSnap.data,
                onRefresh: () async {
                  _outfitBloc.loadMyOutfits.add(LoadOutfits(
                    userId: userId,
                    forceLoad: true,
                    sortByTop: isSortingByTop,
                  ));
                },
                onReachEnd: () => (_outfitBloc.loadMyOutfits).add(
                  LoadOutfits(
                    userId: userId,
                    startAfterOutfit: outfitsSnap.data.last,
                    sortByTop: isSortingByTop,
                  )
                ),
              );
            },
          );
        },
      ),
    );
  }
}