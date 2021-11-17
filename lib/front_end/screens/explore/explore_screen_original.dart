import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../blocs/blocs.dart';
import '../../../../middleware/middleware.dart';
import '../../../../front_end/providers.dart';
import '../../../../front_end/helper_widgets.dart';
import 'package:flutter/gestures.dart';
import '../../../../front_end/screens.dart';

class ExploreScreenOriginal extends StatefulWidget {
  @override
  _ExploreScreenOriginalState createState() => _ExploreScreenOriginalState();
}

class _ExploreScreenOriginalState extends State<ExploreScreenOriginal> {
  
  final Color imageOverlayColor = Colors.white;

  LoadOutfits explore = LoadOutfits();
  String userId;

  int adCounter = 50;
  int currentIndex=0;
  int pageNumber = 1;
  int get previousIndex => currentIndex - 1;
  int get nextIndex => currentIndex + 1;

  bool isPaginationDropdownInFocus = false;
  bool isFilterDropdownInFocus = false;
  bool get isAnyDropdownInFocus => isPaginationDropdownInFocus || isFilterDropdownInFocus;

  OutfitBloc _outfitBloc;

  @override
  void initState() {
    super.initState();
  }

  restartSearch(){
    currentIndex=0;
    pageNumber=1;
    _outfitBloc.exploreOutfits.add(explore);
  }

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))
        ),
        padding: EdgeInsets.only(top: 16.0),
        child: _buildOutfitLiveStream()
      ),
    );
  }


  _initBlocs() async {
    if(_outfitBloc==null){
      _outfitBloc = OutfitBlocProvider.of(context);
      userId = await UserBlocProvider.of(context).existingAuthId.first;
      explore.userId = userId;
      restartSearch();
    }
  }
  Widget _buildOutfitLiveStream() {
    return StreamBuilder<bool>(
      stream: _outfitBloc.isLoadingItems,
      initialData: true,
      builder: (ctx, loadingSnap) {
        return StreamBuilder<List<Outfit>>(
          stream: _outfitBloc.exploredOutfits,
          initialData: [],
          builder: (ctx, snap) {
            List<Outfit> outfits = snap.data;
            return Column(
              children: <Widget>[
                _extraInfoBar(loadingSnap.data),
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      _buildOutfitViewAndOptions(
                        outfitView: OutfitFadingCard(
                          previousOutfit: outfitAtIndex(outfits, previousIndex),
                          currentOutfit: outfitAtIndex(outfits, currentIndex),
                          nextOutfit: outfitAtIndex(outfits, nextIndex),
                          thickness: 10,
                          onPageSwitch: (isForward) => setState(() => pageNumber+=isForward?1:-1),
                          onNextPicShown: () => _incrementIndexes(1),
                          onPrevPicShown: () => _incrementIndexes(-1),
                          backgroundColor: imageOverlayColor,
                          isLoading: loadingSnap.data,
                          enabled: !isAnyDropdownInFocus,
                        ),
                        options: _buildActionBar(outfitAtIndex(outfits, currentIndex)),
                      ),
                      _searchManipulatorButtons(),
                    ],
                  ),
                ),
              ],
            );
          }
        );
      }
    );
  }
  Widget _extraInfoBar(bool isLoading) {
    return Container(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          isLoading ? _loadingBanner() : Container(),
          _adCounter(),
        ],
      ),
    );
  }
  Widget _loadingBanner() {
    return Text(
      'Loading new outfits...',
      style: TextStyle(
        color: Colors.grey,
        fontSize: 12.0
      ),
    );
  }


  Widget _adCounter() {
    return Text(
      'Next ad in: $adCounter',
      style: TextStyle(
        color: Colors.grey,
        fontStyle: FontStyle.italic,
        fontSize: 12.0
      ),
    );
  }
  Widget _buildOutfitViewAndOptions({
    Widget outfitView,
    Widget options,
  }){
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 2,
            offset: Offset(0, -1)
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
        child: Container(
          color: imageOverlayColor,
          child: Column(
            children: <Widget>[
              Expanded(
                child: outfitView
              ),
              options,
            ],
          ),
        ),
      ),
    );
  }

  Outfit outfitAtIndex(List<Outfit> allOutfits, int index) {
    if(allOutfits == null || allOutfits.length <= index || index < 0){
      return null;
    }
    return allOutfits[index];
  }

  Widget _searchManipulatorButtons(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildPaginationDropdown(),
          _buildFilterDropdown(),
        ],
      ),
    );
  }

  Widget _buildPaginationDropdown() {
    return DropdownButtons(
      child: Text(
        '$pageNumber',
        style: Theme.of(context).textTheme.subtitle1.apply(color: Colors.white),
      ),
      onFocusChanged: (isInFocus) {
        setState(() {
          isPaginationDropdownInFocus = isInFocus;
        });
      },
      enabled: !isFilterDropdownInFocus,
      options: <DropdownOption>[
        DropdownOption(
          child: Icon(
            Icons.repeat_one,
            color: Colors.white,
          ),
          tag: "Refresh & Restart",
          onPressed: restartSearch
        ),
        DropdownOption(
          child: Icon(
            Icons.search,
            color: Colors.white,
          ),
          tag: "Go To Page",
          onPressed: restartSearch
        ),
      ],
      alignStart: true,
    );
  }
  Widget _buildFilterDropdown() {
    return DropdownButtons(
      child: Icon(
        Icons.tune,
        color: Colors.white,
      ),
      onFocusChanged: (isInFocus) {
        setState(() {
          isFilterDropdownInFocus = isInFocus;
        });
      },
      enabled: !isPaginationDropdownInFocus,
      options: <DropdownOption>[
        DropdownOption(
          child: Icon(
            Icons.category,
            color: Colors.white,
          ),
          tag: "Select Cateogry"
        ),
        DropdownOption(
          child: Icon(
            Icons.show_chart,
            color: Colors.white,
          ),
          tag: "Sort By Top"
        ),
        DropdownOption(
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
          tag: "Undo Filters"
        ),
      ],
      alignStart: false,
    );
  }


  _incrementIndexes(int diff){
    setState(() {
      currentIndex+=diff;
    });
    _incrementAdCounter();
  }
  _incrementAdCounter(){
    setState(() {
      adCounter--;
    });
    if(adCounter==0){
      _displayAd();
      adCounter = 50;
    }
  }
  _displayAd() => print('ad displayed');

  Widget _buildActionBar(Outfit currentOutfit) {
    OutfitRating outfitRating =OutfitRating(
      outfit: currentOutfit,
      userId: userId,
    );
    OutfitSave saveData = OutfitSave(
      outfit: currentOutfit,
      userId: userId,
    );
    final allDisabled = currentOutfit == null;
    return Material(
      color: imageOverlayColor,
      child: Container(
        padding: EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0, top: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            CustomFab(
              color: Colors.deepPurple,
              icon: Icons.person,
              disabled: allDisabled,
              selected: currentOutfit?.poster?.userId == userId,
              onPressed: () => _openCurrentProfile(currentOutfit.poster.userId),
            ),
            CustomFab(
              color: Colors.pinkAccent,
              icon: Icons.thumb_down,
              largeIcon: true,
              disabled: allDisabled || currentOutfit?.userRating == 1,
              selected: currentOutfit?.userRating == -1,
              // onPressed: () => _outfitBloc.dislikeOutfit.add(outfitRating),
            ),
            CustomFab(
              color: Colors.greenAccent[700],
              icon: Icons.comment,
              disabled: allDisabled,
              onPressed: () => _composeComment(currentOutfit),
            ),
            CustomFab(
              color: Colors.blueAccent,
              icon: Icons.thumb_up,
              largeIcon: true,
              disabled: allDisabled || currentOutfit?.userRating == -1,
              selected: currentOutfit?.userRating == 1,
            // onPressed: () => _outfitBloc.likeOutfit.add(outfitRating),
            ),
            CustomFab(
              color: Colors.amberAccent,
              icon: Icons.star,
              disabled: allDisabled,
              onPressed: () => _outfitBloc.saveOutfit.add(saveData),
            ),
          ],
        ),
      ),
    );
  }

  _composeComment(Outfit outfit){
    CustomNavigator.goToCommentsScreen(context, 
      focusComment: true, 
      outfitId: outfit.outfitId
    );
  }

  _openCurrentProfile(String userId) {
    CustomNavigator.goToProfileScreen(context,
      userId: userId
    );
  }
}