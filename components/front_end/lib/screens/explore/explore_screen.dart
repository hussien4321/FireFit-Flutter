import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:blocs/blocs.dart';
import 'package:middleware/middleware.dart';
import 'package:front_end/providers.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:front_end/screens.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_code_picker/country_code.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:helpers/helpers.dart';
import 'dart:async';

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with SingleTickerProviderStateMixin{
  
  final Color imageOverlayColor = Colors.white;

  String userId;

  int adCounter = 50;

  bool isPaginationDropdownInFocus = false;
  bool isFilterDropdownInFocus = false;
  bool get isAnyDropdownInFocus => isPaginationDropdownInFocus || isFilterDropdownInFocus;

  OutfitBloc _outfitBloc;
  
  OutfitFilters outfitFilters =OutfitFilters();
  bool isSortByTop = false;

  Preferences preferences = Preferences();

  int index = 0;

  @override
  void initState() {
    super.initState();
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
        child: PullToRefreshOverlay(
          matchSize: true,
          onRefresh: () async {
            _outfitBloc.exploreOutfits.add(LoadOutfits(
              userId: userId,
              forceLoad: true,
              sortByTop: isSortByTop,
              filters: outfitFilters,
            ));
          },
          child: Column(
            children: <Widget>[
              _searchDetailsBar(),
              Expanded(
                child: StreamBuilder<bool>(
                  stream: _outfitBloc.isLoading,
                  initialData: false,
                  builder: (ctx, isLoadingSnap) => StreamBuilder<List<Outfit>>(
                    stream: _outfitBloc.exploredOutfits,
                    initialData: [],
                    builder: (ctx, outfitsSnap) {
                      List<Outfit> outfits = outfitsSnap.data;
                        if(outfits.length>0){
                          outfits = sortOutfits(outfits, isSortByTop);
                        }
                        return _outfitsCarousel(outfits, isLoadingSnap.data);
                    }
                  )
                )
              ),
            ],
          )
        )
      ),
    );
  }

  _initBlocs() async {
    if(_outfitBloc==null){
      _outfitBloc = OutfitBlocProvider.of(context);
      userId = await UserBlocProvider.of(context).existingAuthId.first;
      await _loadFiltersFromPreferences();
      // _outfitBloc.exploreOutfits.add(LoadOutfits(
      //   userId: userId,
      //   filters: outfitFilters,
      //   sortByTop: isSortByTop
      // ));
    }
  }
  _loadFiltersFromPreferences() async {
    final newSortByTop = await preferences.getPreference(Preferences.EXPLORE_PAGE_SORT_BY_TOP);
    final filterData = await preferences.getPreference(Preferences.EXPLORE_PAGE_FILTERS);
    setState(() {
      isSortByTop = newSortByTop;
      outfitFilters = OutfitFilters.fromMap(filterData);
    });
  }

  Widget _searchDetailsBar(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  isSortByTop ? 'Hottest Fits' : 'Freshest Fits',
                  style: Theme.of(context).textTheme.display1.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Text(
                  _searchTagline(),
                  maxLines: 1,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.caption.copyWith(
                    fontStyle: FontStyle.italic
                  ),
                ),
              ],
            )
          ),
          IconButton(
            onPressed: _openFilters,
            icon: NotificationIcon(
              iconData: Icons.tune,
              showBubble: hasCustomSearchQuery,
              iconColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
  String _searchTagline() {
    String tagline = "";
    if(isSortByTop){
      tagline+="Highest rated";
    }else{
      tagline+="Most recently uploaded";
    }
    if(outfitFilters.genderIsMale!=null){
      if(outfitFilters.genderIsMale){
        tagline+=" male";
      }else{
        tagline+=" female";
      }
    }
    if(outfitFilters.style!=null){
      tagline +=" ${outfitFilters.style}";
    }
    tagline += " outfits";
    if(isSortByTop){
      tagline+=" of all time";
    }
    tagline+="!";
    return tagline;
  }
  _addCountryTagline(){
    String countryTagline = "";
    countryTagline+="from";
    if(outfitFilters.countryCode!=null){
      CountryCode country = CountryPicker.getCountry(outfitFilters.countryCode);
      if(CountryPicker.countriesWithTheInFrontOfName().contains(country)){
        countryTagline+= " the";
      }
      countryTagline+=" ${country.name}";
    }else{
      countryTagline+=" around the world";
    }
    return countryTagline;
  }

  bool get hasCustomSearchQuery => !outfitFilters.isEmpty || isSortByTop;

  _openFilters(){
    FiltersDialog.launch(context,
      filters: outfitFilters,
      sortByTop: isSortByTop,
      onSearch: _onSearch
    );
  }
  _onSearch(LoadOutfits filterData) {
    setState(() {
      outfitFilters = filterData.filters;
      isSortByTop = filterData.sortByTop;
    });
    preferences.updatePreference(Preferences.EXPLORE_PAGE_SORT_BY_TOP, isSortByTop);
    preferences.updatePreference(Preferences.EXPLORE_PAGE_FILTERS, outfitFilters.toJson());
    _outfitBloc.exploreOutfits.add(LoadOutfits(
      filters: filterData.filters,
      sortByTop: filterData.sortByTop,
      userId: userId,
    ));

  }

  Widget _outfitsCarousel(List<Outfit> outfits, bool isLoading) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: CarouselSlider(
              height: double.infinity,
              enlargeCenterPage: true,
              onPageChanged: (i) {
                setState(() => index = i);
                if(i+1>=outfits.length && outfits.length>0){
                  _outfitBloc.exploreOutfits.add(LoadOutfits(
                    userId: userId,
                    startAfterOutfit: outfits.last,
                    filters: outfitFilters,
                    sortByTop: isSortByTop,
                  ));
                }
              },
              items: outfits.map((outfit) => _buildOutfitCard(outfit, index)).toList()..add(_endCard(isLoading, outfits.isEmpty)),
              enableInfiniteScroll: false,
              viewportFraction: 0.8,
            ),
          )
        ),
        _outfitInteractionButtons(outfits, index),
      ],
    );
                     
  }

  Widget _buildOutfitCard(Outfit outfit, int index) {
    return _card(
      child: OutfitMainCard(outfit: outfit)
    );
  }

  Widget _card({Widget child, bool addShadow = true}) {
    List<BoxShadow> shadows = [];
    if(addShadow){
      shadows.add(
        BoxShadow(
          color: Colors.black54,
          blurRadius: 2,
          offset: Offset(1, 1)
        )
      );
    }
    return Container(
      padding: EdgeInsets.all(4),
      child: Align(
        alignment: Alignment.center,
        child: AspectRatio(
          aspectRatio: 2/3,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: shadows
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: child,
            ),
          )
        )
      )
    );
  }

  Widget _endCard(bool isLoading, bool isEmpty) {
    return _card(
      addShadow: false,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          gradient: LinearGradient(
            colors: [
              Colors.grey[300],
              Colors.black54
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              isLoading? 
              Theme(
                data: ThemeData(
                  accentColor: Colors.white
                ),
                child: CircularProgressIndicator()
              ) : Icon(
                FontAwesomeIcons.boxOpen,
                color: Colors.white,
                size: 48,
              ),
              Text(isLoading ? 'Loading Fits' : (isEmpty? 'No Fits Found' : 'No More Fits'),
                style: Theme.of(context).textTheme.display1.copyWith(
                  color: Colors.white
                ),
                textAlign: TextAlign.center,
              ),
              Text(isLoading ? 'Please wait while we find you more fire fits!' : 'Try a different search filter or refresh the page to check for new fits!',
                style: Theme.of(context).textTheme.subtitle.copyWith(
                  color: Colors.white
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      )
    );
  }

  Widget _outfitInteractionButtons(List<Outfit> outfits, int index) {
    Outfit currentOutfit = outfits.length <= index ? null : outfits[index];
    bool hasOutfit =currentOutfit != null;
    bool hasRating =currentOutfit?.hasRating == true;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _actionButton(
            icon: Icon(
              Icons.comment,
              size: 24,
            ),
            hasData: hasOutfit,
            onPressed: () => _loadCommentsPage(currentOutfit),
          ),
          _actionButton(
            icon: Image.asset(
              'assets/firefit_logo.png',
              width: 32,
              height: 32,
            ),
            hasData: hasOutfit,
            selected: hasRating,
            unselectedColor: Colors.blue,
            hideBorder: true,
            iconPadding: 8,
            onPressed: () => _giveRating(currentOutfit),
          ),
          _actionButton(
            icon: Icon(
              Icons.playlist_add,
              size: 24,
            ),
            hasData: hasOutfit,
            onPressed: () => AddToLookbookDialog.launch(context, outfitSave: OutfitSave(
                outfit: currentOutfit,
                userId: userId,
              )
            )
          ),
        ],
      ),
    );  
  }

  _loadCommentsPage(Outfit outfit) {
    CustomNavigator.goToCommentsScreen(context,
      focusComment: false,
      outfitId: outfit.outfitId,
      isComingFromExploreScreen: true,
    );
  }


  _actionButton({Widget icon, bool hasData = false, bool selected = false, double iconPadding = 4.0, Color unselectedColor = Colors.white, bool hideBorder = false, VoidCallback onPressed}){
    return RawMaterialButton(
      fillColor: !hasData ? Colors.grey : selected ? Colors.red : unselectedColor,
      elevation: hasData ? 2 : 0,
      shape: CircleBorder(
        side: BorderSide(
          color: Colors.grey.withOpacity(hideBorder ? 0.0 : 0.5),
          width: 0.5
        )
      ),
      onPressed: hasData ? onPressed : null,
      child: Padding(
        padding: EdgeInsets.all(iconPadding),
        child: icon,
      )
    );
  } 

  _giveRating(Outfit currentOutfit) {
    return showDialog(
      context: context,
      builder: (ctx) {
        return RatingDialog(
          initialValue: currentOutfit.userRating,
          isUpdate: currentOutfit.hasRating,
          onSubmit: (newRating) {
            OutfitRating outfitRating = OutfitRating(
              outfit: currentOutfit,
              ratingValue: newRating,
              userId: userId,
            );
            _outfitBloc.rateOutfit.add(outfitRating);
          }
        );
      }
    );
  }
}

