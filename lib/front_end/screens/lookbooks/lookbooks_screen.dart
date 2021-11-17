import 'package:flutter/material.dart';
import '../../../../front_end/helper_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../blocs/blocs.dart';
import '../../../../front_end/providers.dart';
import '../../../../helpers/helpers.dart';
import '../../../../middleware/middleware.dart';
import '../../../../helpers/helpers.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/rendering.dart';

class LookbooksScreen extends StatefulWidget {
  final bool hasSubscription;
  final ValueChanged<bool> onUpdateSubscriptionStatus;
  final ValueChanged<ScrollController> onScrollChange;

  LookbooksScreen(
      {this.hasSubscription,
      this.onUpdateSubscriptionStatus,
      this.onScrollChange});

  @override
  _LookbooksScreenState createState() => _LookbooksScreenState();
}

class _LookbooksScreenState extends State<LookbooksScreen> {
  OutfitBloc _outfitBloc;
  UserBloc _userBloc;

  String userId;
  User user;

  int maxNumLookbooks =
      RemoteConfigHelpers.defaults[RemoteConfigHelpers.LOOKBOOKS_LIMIT];
  int maxOutfitStorage =
      RemoteConfigHelpers.defaults[RemoteConfigHelpers.LOOKBOOKS_OUTFITS_LIMIT];

  bool isSortBySize = false;
  Preferences preferences = Preferences();

  ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
  }

  _scrollListener() {
    widget.onScrollChange(_controller);
  }

  _loadPreferences() async {
    isSortBySize =
        await preferences.getPreference(Preferences.LOOKBOOKS_SORT_BY_SIZE);
    final remoteConfig = RemoteConfig.instance;
    maxOutfitStorage =
        remoteConfig.getInt(RemoteConfigHelpers.LOOKBOOKS_OUTFITS_LIMIT);
    maxNumLookbooks = remoteConfig.getInt(RemoteConfigHelpers.LOOKBOOKS_LIMIT);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return UserStream(
      loadingStream: _userBloc.isLoading,
      userStream: _userBloc.currentUser,
      builder: (isLoadingUser, streamUser) => LookbooksStream(
          loadingStream: _outfitBloc.isLoadingItems,
          lookbooksStream: _outfitBloc.lookbooks,
          builder: (isLoadingLookbooks, lookbooks) {
            bool isLoading = isLoadingUser || isLoadingLookbooks;
            user = streamUser;
            lookbooks = _sortList(lookbooks);
            return ListView(
              controller: _controller,
              physics: ClampingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              children: <Widget>[
                _lookbooksOverview(isLoading),
                _lookbooksManagementOptions(lookbooks.length),
                lookbooks.isEmpty
                    ? _noLookbooksNotice()
                    : _lookbooksList(lookbooks),
              ],
            );
          }),
    );
  }

  _initBlocs() async {
    if (_outfitBloc == null) {
      _userBloc = UserBlocProvider.of(context);
      _outfitBloc = OutfitBlocProvider.of(context);
      userId = await _userBloc.existingAuthId.first;
    }
  }

  _sortList(List<Lookbook> lookbooks) {
    if (isSortBySize) {
      lookbooks.sort((a, b) => -a.numberOfOutfits.compareTo(b.numberOfOutfits));
    } else {
      lookbooks.sort((a, b) => -a.createdAt.compareTo(b.createdAt));
    }
    return lookbooks;
  }

  Widget _lookbooksOverview(bool isLoading) {
    if (isLoading) {
      return Container();
    }
    return Container(
      padding: EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 8),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  "Current size:",
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      .copyWith(color: Colors.black54),
                  textAlign: TextAlign.start,
                ),
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .copyWith(fontWeight: FontWeight.normal),
                    children: [
                      TextSpan(
                          text: user.numberOfLookbooks.toString(),
                          style: TextStyle(
                              inherit: true, fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                              " Lookbook${user.numberOfLookbooks == 1 ? '' : 's'}"),
                    ]),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  "Total outfits:",
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      .copyWith(color: Colors.black54),
                  textAlign: TextAlign.start,
                ),
              ),
              LimitedFeatureSticker(
                title: "Unlimited storage?",
                message:
                    "${user.numberOfLookbookOutfits}/$maxOutfitStorage Outfits",
                isFull: user.numberOfLookbookOutfits >= maxOutfitStorage,
                benefit: 'have unlimited outfits in your lookbooks',
                unlimitedMessage: "${user.numberOfLookbookOutfits} Outfits",
                hasSubscription: widget.hasSubscription,
                onUpdateSubscriptionStatus: widget.onUpdateSubscriptionStatus,
                initialPage: 2,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _lookbooksManagementOptions(int size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _newLookbookButton(size),
        _sortingButton(),
      ],
    );
  }

  Widget _newLookbookButton(int currentSize) {
    bool isFull = currentSize == maxNumLookbooks;
    Color color = isFull ? Colors.grey : Colors.blue;
    return FlatButton(
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Icon(
              isFull ? Icons.lock : Icons.add,
              color: color,
            ),
          ),
          Text(
            isFull ? 'Max size' : 'Create New',
            style: TextStyle(
              inherit: true,
              color: color,
            ),
          )
        ],
      ),
      onPressed: () =>
          isFull ? _notifyMaxSize() : NewLookbookDialog.launch(context),
    );
  }

  _notifyMaxSize() {
    return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('Max size reached'),
              content: Text(
                'Sorry but you seem to have reached the maximum number of lookbooks.\n\nPlease delete some of your unused lookbooks before you can create new ones.',
                style: Theme.of(context).textTheme.subtitle1,
                textAlign: TextAlign.center,
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    'Got it',
                    style: TextStyle(
                      inherit: true,
                      color: Colors.deepOrange,
                    ),
                  ),
                  onPressed: Navigator.of(ctx).pop,
                )
              ],
            ));
  }

  Widget _sortingButton() {
    return FlatButton(
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              isSortBySize ? 'Size' : 'Last Modified',
              style: TextStyle(
                inherit: true,
                color: Colors.blue,
              ),
            ),
          ),
          Icon(
            Icons.trending_up,
            color: Colors.blue,
          ),
        ],
      ),
      onPressed: _toggleSort,
    );
  }

  _toggleSort() {
    setState(() {
      isSortBySize = !isSortBySize;
    });
    preferences.updatePreference(
        Preferences.LOOKBOOKS_SORT_BY_SIZE, isSortBySize);
  }

  Widget _lookbooksList(List<Lookbook> lookbooks) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: lookbooks.length,
          itemBuilder: (ctx, i) =>
              LookbookCard(lookbooks[i % lookbooks.length])),
    );
  }

  Widget _noLookbooksNotice() {
    return Container(
      padding: EdgeInsets.only(top: 16, left: 16, right: 16),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'No lookbooks found',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Icon(
              FontAwesomeIcons.boxOpen,
              size: 64,
            ),
          ),
          Text(
            'You have not created any lookbooks yet, use lookbooks to bookmark your favourite outfits and group them into your own categories!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ],
      ),
    );
  }
}
