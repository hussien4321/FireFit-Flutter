import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';
import '../../../../blocs/blocs.dart';
import '../../../../middleware/middleware.dart';
import '../../../../front_end/providers.dart';
import '../../../../front_end/helper_widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:country_code_picker/country_code.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:overlay_support/overlay_support.dart';

class ExploreScreen extends StatefulWidget {
  final VoidCallback onShowAd;
  final bool hasSubscription;
  final ValueChanged<bool> onUpdateSubscriptionStatus;

  ExploreScreen(
      {this.onShowAd, this.hasSubscription, this.onUpdateSubscriptionStatus});

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  final Color imageOverlayColor = Colors.white;

  String userId;

  int adCounter = 0;
  int adFrequency = RemoteConfigHelpers
      .defaults[RemoteConfigHelpers.CAROUSEL_AD_FREQUENCY_KEY];
  int maxOutfitStorage =
      RemoteConfigHelpers.defaults[RemoteConfigHelpers.LOOKBOOKS_OUTFITS_LIMIT];

  bool isPaginationDropdownInFocus = false;
  bool isFilterDropdownInFocus = false;
  bool get isAnyDropdownInFocus =>
      isPaginationDropdownInFocus || isFilterDropdownInFocus;

  OutfitBloc _outfitBloc;

  OutfitFilters outfitFilters = OutfitFilters();
  bool isSortByTop = false;

  Preferences preferences = Preferences();
  int index = 0;

  bool hasMaxLookbookOutfits = false;

  List<Outfit> outfits = [];

  @override
  void initState() {
    super.initState();
    RemoteConfig remoteConfig = RemoteConfig.instance;
    adFrequency =
        remoteConfig.getInt(RemoteConfigHelpers.CAROUSEL_AD_FREQUENCY_KEY);
    maxOutfitStorage =
        remoteConfig.getInt(RemoteConfigHelpers.LOOKBOOKS_OUTFITS_LIMIT);
  }

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      child: Container(
          padding: EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
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
                          stream: _outfitBloc.isLoadingExplore,
                          initialData: false,
                          builder: (ctx, isLoadingSnap) =>
                              StreamBuilder<List<Outfit>>(
                                  stream: _outfitBloc.exploredOutfits,
                                  initialData: [],
                                  builder: (ctx, outfitsSnap) {
                                    bool isLoading = isLoadingSnap.data;
                                    outfits = outfitsSnap.data;
                                    if (outfits.length > 0) {
                                      outfits =
                                          sortOutfits(outfits, isSortByTop);
                                    }
                                    return _outfitsCarousel(outfits, isLoading);
                                  }))),
                ],
              ))),
    );
  }

  _initBlocs() async {
    if (_outfitBloc == null) {
      _outfitBloc = OutfitBlocProvider.of(context);
      final _userBloc = UserBlocProvider.of(context);
      userId = await _userBloc.existingAuthId.first;
      _userBloc.currentUser.first.then((user) {
        setState(() => hasMaxLookbookOutfits =
            user.numberOfLookbookOutfits >= maxOutfitStorage);
      });
      await _loadFiltersFromPreferences();
    }
  }

  _loadFiltersFromPreferences() async {
    final newSortByTop =
        await preferences.getPreference(Preferences.EXPLORE_PAGE_SORT_BY_TOP);
    final filterData =
        await preferences.getPreference(Preferences.EXPLORE_PAGE_FILTERS);
    setState(() {
      isSortByTop = newSortByTop;
      outfitFilters = OutfitFilters.fromMap(filterData);
    });
  }

  Widget _searchDetailsBar() {
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
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              Text(
                _searchTagline(),
                maxLines: 1,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .copyWith(fontStyle: FontStyle.italic),
              ),
            ],
          )),
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
    if (isSortByTop) {
      tagline += "Highest rated";
    } else {
      tagline += "Most recently uploaded";
    }
    if (outfitFilters.genderIsMale != null) {
      if (outfitFilters.genderIsMale) {
        tagline += " male";
      } else {
        tagline += " female";
      }
    }
    if (outfitFilters.style != null) {
      tagline += " ${outfitFilters.style}";
    }
    tagline += " outfits";
    if (isSortByTop && outfitFilters.dateRange == null) {
      tagline += " of all time";
    } else if (isSortByTop && outfitFilters.dateRange != DateRanges.CUSTOM) {
      tagline +=
          " from the ${dateRangeToString(outfitFilters.dateRange).toLowerCase()}";
    }
    tagline += "!";
    return tagline;
  }

  _addCountryTagline() {
    String countryTagline = "";
    countryTagline += "from";
    if (outfitFilters.countryCode != null) {
      CountryCode country = CountryPicker.getCountry(outfitFilters.countryCode);
      if (CountryPicker.countriesWithTheInFrontOfName().contains(country)) {
        countryTagline += " the";
      }
      countryTagline += " ${country.name}";
    } else {
      countryTagline += " around the world";
    }
    return countryTagline;
  }

  bool get hasCustomSearchQuery => !outfitFilters.isEmpty || isSortByTop;

  _openFilters() {
    FiltersDialog.launch(
      context,
      filters: outfitFilters,
      sortByTop: isSortByTop,
      onSearch: _onSearch,
      hasSubscription: widget.hasSubscription,
      onUpdateSubscriptionStatus: widget.onUpdateSubscriptionStatus,
    );
  }

  _onSearch(LoadOutfits filterData) {
    setState(() {
      outfitFilters = filterData.filters;
      isSortByTop = filterData.sortByTop;
    });
    preferences.updatePreference(
        Preferences.EXPLORE_PAGE_SORT_BY_TOP, isSortByTop);
    preferences.updatePreference(
        Preferences.EXPLORE_PAGE_FILTERS, outfitFilters.toJson());
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
          child: LayoutBuilder(builder: (ctx, constraints) {
            double heightMaxSize =
                min(constraints.maxWidth, constraints.maxHeight);
            double fraction = (heightMaxSize * 0.65) / constraints.maxWidth;
            return CarouselSlider(
              options: CarouselOptions(
                height: heightMaxSize,
                enlargeCenterPage: true,
                onPageChanged: (i, _) {
                  _incrementAdCounter();
                  setState(() => index = i);
                  if (i + 1 >= outfits.length && outfits.length > 0) {
                    _outfitBloc.exploreOutfits.add(LoadOutfits(
                      userId: userId,
                      startAfterOutfit: outfits.last,
                      filters: outfitFilters,
                      sortByTop: isSortByTop,
                    ));
                  }
                },
                enableInfiniteScroll: false,
                viewportFraction: fraction,
              ),
              items: outfits
                  .map((outfit) => _buildOutfitCard(outfit, index))
                  .toList()
                ..add(_endCard(isLoading, outfits.isEmpty)),
            );
          }),
        )),
        _outfitInteractionButtons(outfits, index),
      ],
    );
  }

  _incrementAdCounter() {
    adCounter++;
    if (adCounter >= adFrequency) {
      adCounter = 0;
      widget.onShowAd();
    }
  }

  Widget _buildOutfitCard(Outfit outfit, int index) {
    return _card(child: OutfitMainCard(outfit: outfit));
  }

  Widget _card({Widget child, bool addShadow = true}) {
    List<BoxShadow> shadows = [];
    if (addShadow) {
      shadows.add(BoxShadow(
          color: Colors.black54, blurRadius: 2, offset: Offset(1, 1)));
    }
    return Container(
        padding: EdgeInsets.all(2),
        child: Align(
            alignment: Alignment.center,
            child: AspectRatio(
                aspectRatio: 2 / 3,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: shadows),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: child,
                  ),
                ))));
  }

  Widget _endCard(bool isLoading, bool isEmpty) {
    return _card(
        addShadow: false,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            gradient: LinearGradient(
              colors: [Colors.grey[300], Colors.black54],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                isLoading
                    ? Theme(
                        data: ThemeData(accentColor: Colors.white),
                        child: CircularProgressIndicator())
                    : Icon(
                        FontAwesomeIcons.boxOpen,
                        color: Colors.white,
                        size: 48,
                      ),
                Text(
                  isLoading
                      ? 'Loading Fits'
                      : (isEmpty ? 'No Fits Found' : 'No More Fits'),
                  style: Theme.of(context)
                      .textTheme
                      .headline4
                      .copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                Text(
                  isLoading
                      ? 'Please wait while we find you ${isEmpty ? 'some' : 'more'} Fire Fits!'
                      : 'Try a different search filter or refresh the page to check for new fits!',
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2
                      .copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        ));
  }

  Widget _outfitInteractionButtons(List<Outfit> outfits, int index) {
    Outfit currentOutfit = outfits.length <= index ? null : outfits[index];
    bool hasOutfit = currentOutfit != null;
    bool hasRating = currentOutfit?.hasRating == true;
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
              hasRating ? 'assets/flame_full.png' : 'assets/flame_empty.png',
              width: 32,
              height: 32,
            ),
            outlineColor: Colors.deepOrange,
            hasData: hasOutfit,
            selected: hasRating,
            iconPadding: 8,
            onPressed: () => _giveRating(currentOutfit),
          ),
          _actionButton(
              icon: Icon(
                Icons.playlist_add,
                size: 24,
                color: hasMaxLookbookOutfits ? Colors.red : Colors.black,
              ),
              hasData: hasOutfit,
              onPressed: () {
                if (hasMaxLookbookOutfits) {
                  toast("Max storage reached");
                } else {
                  AddToLookbookDialog.launch(context,
                      outfitSave: OutfitSave(
                        outfit: currentOutfit,
                        userId: userId,
                      ));
                }
              }),
        ],
      ),
    );
  }

  _loadCommentsPage(Outfit outfit) {
    CustomNavigator.goToCommentsScreen(
      context,
      focusComment: false,
      outfitId: outfit.outfitId,
      isComingFromExploreScreen: true,
    );
  }

  _actionButton(
      {Widget icon,
      bool hasData = false,
      Color outlineColor = Colors.blue,
      bool selected = false,
      double iconPadding = 4.0,
      VoidCallback onPressed}) {
    return RawMaterialButton(
        fillColor: hasData ? Colors.white : Colors.grey,
        elevation: hasData ? 1 : 0,
        shape: CircleBorder(
            side: BorderSide(
                color: hasData ? outlineColor : Colors.transparent, width: 1)),
        onPressed: hasData ? onPressed : null,
        child: Padding(
          padding: EdgeInsets.all(iconPadding),
          child: icon,
        ));
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
              });
        });
  }
}
