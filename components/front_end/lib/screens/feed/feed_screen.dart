import 'package:flutter/material.dart';
import 'package:front_end/screens.dart';
import 'package:middleware/middleware.dart';
import 'package:blocs/blocs.dart';
import 'package:front_end/providers.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:helpers/helpers.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter/rendering.dart';

class FeedScreen extends StatefulWidget {

  final ValueChanged<ScrollController> onScrollChange;

  FeedScreen({this.onScrollChange});
  
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {


  OutfitBloc _outfitBloc;
  UserBloc _userBloc;
  String userId;

  bool isMyOutfits = true;

  ScrollController _controller;
  
  bool isLoading;
  List<Outfit> outfits;
  RefreshCallback onRefresh;
  ValueChanged<Outfit> onReachEnd;

  bool hasMaxLookbookOutfits = false;
  int maxOutfitStorage = RemoteConfigHelpers.defaults[RemoteConfigHelpers.LOOKBOOKS_OUTFITS_LIMIT];

  @override
  void initState() {
    super.initState();
    RemoteConfig.instance.then((remoteConfig) {
      maxOutfitStorage = remoteConfig.getInt(RemoteConfigHelpers.LOOKBOOKS_OUTFITS_LIMIT);
    });
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
  }
  _scrollListener() {
    if (_controller.offset >= (_controller.position.maxScrollExtent - 150) && !_controller.position.outOfRange) {
      if(onReachEnd!=null && outfits.isNotEmpty){
        onReachEnd(outfits.last);
      }
    }
    widget.onScrollChange(_controller);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return Container(
      color: Colors.grey[300],
      child: StreamBuilder<bool>(
        stream: _outfitBloc.isLoadingFeed,
        initialData: false,
        builder: (ctx, isLoadingSnap) {
          return StreamBuilder<List<Outfit>>(
            stream: _outfitBloc.feedOutfits,
            initialData: [],
            builder: (ctx, outfitsSnap) {
              isLoading = isLoadingSnap.data;
              outfits = outfitsSnap.data;
              onRefresh = () async {
                _outfitBloc.loadFeedOutfits.add(LoadOutfits(
                  userId: userId,
                  forceLoad: true,
                ));
              };
              onReachEnd = (lastOutfit) {
                _outfitBloc.loadFeedOutfits.add(LoadOutfits(
                  userId: userId,
                  startAfterOutfit: lastOutfit,
                ));
              };
              return _feedOutfits();
            },
          );
        },
      ),
    );
  }
  
  _initBlocs() async {
    if(_outfitBloc==null){
      _outfitBloc = OutfitBlocProvider.of(context);
      _userBloc = UserBlocProvider.of(context);
      userId = await _userBloc.existingAuthId.first;
      _userBloc.currentUser.first.then((user) {
        setState(() => hasMaxLookbookOutfits = user.numberOfLookbookOutfits >= maxOutfitStorage);
      });
    }
  }

  Widget _feedOutfits() {
    return Container(
      color: Colors.grey[300],
      width: double.infinity,
      child: _buildScrollableGrid(context)
    );
  }

  Widget _buildScrollableGrid(BuildContext ctx) {
    return PullToRefreshOverlay(
      matchSize: false,
      onRefresh: onRefresh, 
      child: ListView.builder(
        physics: ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        controller: _controller,
        itemCount: outfits.length+1,
        itemBuilder: (ctx,i) => i==outfits.length ? _endOfListNotice(ctx) : _buildOutfitCard(i, outfits[i], ctx, i==0),
      ),
    );
  }

  Widget _endOfListNotice(BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 24),
      child: Center(
        child: isLoading ? _loadingItemsMessage(ctx) :_noMoreItemsMessage(ctx),
      ),
    );
  }

  Widget _noMoreItemsMessage(BuildContext ctx) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'No ${moreTag}outfits\n',
            style: Theme.of(ctx).textTheme.subtitle.copyWith(
            ),
          ),
          TextSpan(
            text: 'Follow more users to widen your fashion circle!',
            style: Theme.of(ctx).textTheme.caption.copyWith(
              color: Colors.black54
            ),
          ),
        ]
      ),
      textAlign: TextAlign.center,      
    );
  }

  String get moreTag => outfits.isEmpty ? '' : 'more ';

  Widget _loadingItemsMessage(BuildContext ctx) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: CircularProgressIndicator(),
        ),
        Text(
          'Loading ${moreTag}outfits',
          style: Theme.of(ctx).textTheme.subhead.copyWith(
            color: Colors.black54
          ),
        )
      ],
    );
  }

  Widget _buildOutfitCard(int index, Outfit outfit, BuildContext ctx, bool isFirst) {
    return Container(
      margin: EdgeInsets.only(top: isFirst ? 16 : 0 , bottom: 16.0, ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _postBasicData(index, outfit, ctx),
            _outfitFullImageCard(outfit, ctx),
            _outfitActions(outfit),
          ],
        ),
      ),
    );
  }

  _openDetailedOutfit(Outfit outfit, BuildContext ctx){
    CustomNavigator.goToOutfitDetailsScreen(ctx, 
      outfitId: outfit.outfitId
    );
  }

  Widget _postBasicData(int index, Outfit outfit, BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: <Widget>[
          ProfilePicWithShadow(
            userId: outfit.poster.userId,
            url: outfit.poster.profilePicUrl,
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: outfit.poster.name,
                    style: Theme.of(context).textTheme.subtitle
                  ),
                  TextSpan(
                    text: '\nUploaded an outfit',
                    style: Theme.of(context).textTheme.caption
                  ),
                ]
              ),
            ),
          ),
          Text(
            DateFormatter.dateToSimpleFormat(outfit.createdAt),
            style: Theme.of(context).textTheme.caption,
          )
        ],
      ),
    );
  }

  Widget _outfitFullImageCard(Outfit outfit, BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.5,
        child: AspectRatio(
          aspectRatio: 2/3,
          child: GestureDetector(
            onTap: () => _openDetailedOutfit(outfit, context),
            child: OutfitMainCard(outfit: outfit,)
          )
        ),
      );
  }

  Widget _outfitActions(Outfit outfit) {
    double iconSize = 20;
    return Container(
      padding: EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          _quickAction(
            onTap: () => _commentOnOutfit(outfit),
            child: Icon(
              Icons.add_comment,
              size: iconSize,
            ),
          ),
          _quickAction(
            child: Image.asset(
              outfit.hasRating ? 'assets/flame_full.png' : 'assets/flame_empty.png',
              height: iconSize,
              width: iconSize,
            ),
            onTap: () => _rateOutfit(outfit),
          ),
          _quickAction(
            child: Icon(
              Icons.playlist_add,
              size: iconSize,
              color: hasMaxLookbookOutfits ? Colors.red : Colors.black,
            ),
            onTap: () => _saveOutfit(outfit)
          )
        ]
      )
    );
  }

  Widget _quickAction({Widget child, VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Material(
        color: Colors.white,
        shape: CircleBorder(
          side: BorderSide(
            color: Colors.grey.withOpacity(0.5),
            width: 0.5
          )
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: CircleBorder(),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: child
          ),
        ),
      ),
    );
  }

  _commentOnOutfit(Outfit outfit){
    CustomNavigator.goToCommentsScreen(context,
      focusComment: true,
      outfitId: outfit.outfitId,
      isComingFromExploreScreen: true,
    );
  }
    


  _rateOutfit(Outfit outfit) {
    return showDialog(
      context: context,
      builder: (ctx) {
        return RatingDialog(
          initialValue: outfit.userRating,
          isUpdate: outfit.hasRating,
          onSubmit: (newRating) {
            OutfitRating outfitRating = OutfitRating(
              outfit: outfit,
              ratingValue: newRating,
              userId: userId,
            );
            _outfitBloc.rateOutfit.add(outfitRating);
          }
        );
      }
    );
  }

  _saveOutfit(Outfit outfit) {
    OutfitSave saveData = OutfitSave(
      outfit: outfit,
      userId: userId,
    );
    if(hasMaxLookbookOutfits) {
      toast("Max storage reached");
    } else {
      AddToLookbookDialog.launch(context, outfitSave: saveData);
    }
  }
}