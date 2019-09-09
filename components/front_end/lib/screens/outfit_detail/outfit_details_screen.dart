import 'package:flutter/material.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:middleware/middleware.dart';
import 'package:helpers/helpers.dart';
import 'package:front_end/providers.dart';
import 'package:blocs/blocs.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:front_end/screens.dart';
import 'package:front_end/helper_widgets.dart';
import 'dart:ui';
import 'package:overlay_support/overlay_support.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum OutfitOption { EDIT, REPORT, BLOCK, DELETE }

class OutfitDetailsScreen extends StatefulWidget {

  final int outfitId;
  final bool loadOutfit;
  final int pagesSinceOutfitScreen;
  final int pagesSinceProfileScreen;

  OutfitDetailsScreen({
    this.outfitId,
    this.loadOutfit = false,
    this.pagesSinceOutfitScreen = 0,
    this.pagesSinceProfileScreen = 0,
  });

  @override
  _OutfitDetailsScreenState createState() => _OutfitDetailsScreenState();
}

class _OutfitDetailsScreenState extends State<OutfitDetailsScreen> {


  OutfitBloc _outfitBloc;
  Outfit outfit;

  String userId;

  bool canSendComment = false;
  TextEditingController commentTextController = new TextEditingController();
  
  int maxOutfitStorage = RemoteConfigHelpers.defaults[RemoteConfigHelpers.LOOKBOOKS_OUTFITS_LIMIT];
  bool hasMaxLookbookOutfits = false;

  @override
  void initState() {
    super.initState();
    RemoteConfig.instance.then((remoteConfig) {
      maxOutfitStorage = remoteConfig.getInt(RemoteConfigHelpers.LOOKBOOKS_OUTFITS_LIMIT);
    });
  }

  @override
  void dispose() {
    super.dispose();
    // SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
 }  

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return StreamBuilder<bool>(
      stream: _outfitBloc.noOutfitFound,
      initialData: false,
      builder: (ctx, noOutfitFoundSnap) => 
        StreamBuilder<bool>(
        stream: _outfitBloc.isLoading,
        initialData: true,
        builder: (ctx, isLoadingSnap) => StreamBuilder<Outfit>(
          stream: _outfitBloc.selectedOutfit,
          builder: (ctx, outfitSnap) {
            if(noOutfitFoundSnap.data) {
              return ItemNotFound(itemType: 'Outfit');
            } else if(isLoadingSnap.data || !outfitSnap.hasData || outfitSnap.data == null){
              return _overlayScaffold(
                body: _outfitLoadingPlaceholder()
              );
            }else{
              if(outfit==null){
                AnalyticsEvents(context).outfitViewed(outfitSnap.data);
              }
              outfit = outfitSnap.data;
              return  _overlayScaffold(
                body: _buildMainBody()
              );
            }
          }
        ),
      ),
    );
  }

  _initBlocs() async {
    if(_outfitBloc==null){
      _outfitBloc = OutfitBlocProvider.of(context);
      final _userBloc = UserBlocProvider.of(context);
      userId = await _userBloc.existingAuthId.first;
      _userBloc.currentUser.first.then((user) {
        setState(() => hasMaxLookbookOutfits = user.numberOfLookbookOutfits >= maxOutfitStorage);
      });

      _outfitBloc.selectOutfit.add(LoadOutfit(
        outfitId: widget.outfitId,
        userId: userId,
        loadFromCloud: widget.loadOutfit
      ));
    }
  }
  Widget _overlayScaffold({Widget body}){
    return CustomScaffold(
      resizeToAvoidBottomPadding: false,
      elevation: 2,
      leading: IconButton(
        padding: EdgeInsets.all(0),
        onPressed: Navigator.of(context).pop,
        icon: Icon(Icons.arrow_back),
      ),
      actions: <Widget>[
        outfit == null ? Container() : _loadOutfitOptions()
      ],
      title: outfit == null ? "Loading..." : outfit.title,
      body: Container(
        color: Colors.white,
        child: body,
      ),
    );
  }

  Widget _loadOutfitOptions(){
    List<OutfitOption> availableOptions = OutfitOption.values.where((option) => _canShowOption(option)).toList();
    return availableOptions.isEmpty ? Container() : PopupMenuButton<OutfitOption>(
      onSelected: (option) => _optionAction(option),
      itemBuilder: (BuildContext context) {
        return availableOptions.map((OutfitOption option) {
          return PopupMenuItem<OutfitOption>(
            value: option,
            child: Text(_optionToString(option)),
          );
        }).toList();
      },
    );
  }

  String _optionToString(OutfitOption option){
    switch (option) {
      case OutfitOption.EDIT:
        return 'Edit';
      case OutfitOption.REPORT:
        return 'Report';
      case OutfitOption.BLOCK:
        return 'Block';
      case OutfitOption.DELETE:
        return 'Delete';
      default:
        return null;
    }
  }

  bool _canShowOption(OutfitOption option){
    switch (option) {
      case OutfitOption.EDIT:
        return isCurrentUser;
      case OutfitOption.REPORT:
        return !isCurrentUser;
      case OutfitOption.BLOCK:
        return !isCurrentUser;
      case OutfitOption.DELETE:
        return isCurrentUser;
      default:
        return null;
    }
  }

  bool get isCurrentUser => outfit?.poster?.userId == userId;

  _optionAction(OutfitOption option){
    switch (option) {
      case OutfitOption.EDIT:
        _editOutfit();
        break;
      case OutfitOption.REPORT:
        _reportUser();
        break;
      case OutfitOption.BLOCK:
        _blockUser();
        break;
      case OutfitOption.DELETE:
        _confirmDelete();
        break;
      default:
        return null;
    }
  }

  _editOutfit() => CustomNavigator.goToEditOutfitScreen(context, outfit: outfit);

  _reportUser() {
    ReportDialog.launch(context,
      reportedUserId: outfit.poster.userId,
      reportedOutfitId: outfit.outfitId,
    );
  }

  _blockUser() {
    BlockDialog.launch(context,
      blockingUserId: userId,
      blockedUserId: outfit.poster.userId,
      name: outfit.poster.name,
    );
  }

  _confirmDelete(){
    return showDialog(
      context: context,
      builder: (secondContext) {
        return YesNoDialog(
          title: 'Delete Outfit',
          description: 'Are you sure you want to delete this outfit?',
          yesText: 'Yes',
          noText: 'Cancel',
          onYes: () {
            _outfitBloc.deleteOutfit.add(outfit);
            Navigator.pop(context);
          },
          onDone: () {
            Navigator.pop(context);
          },
        );
      }
    ) ?? false;
  }

  Widget _outfitLoadingPlaceholder(){
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  _buildMainBody() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: <Widget>[
          Expanded(
            child: PullToRefreshOverlay(
              matchSize: false,
              onRefresh: () async {
                _outfitBloc.selectOutfit.add(LoadOutfit(
                outfitId: widget.outfitId,
                userId: userId,
                loadFromCloud: true,
                ));
              },
              child: ListView(
                physics: ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                children: <Widget>[
                  _outfitMainDetails(),
                  _outfitFurtherDetails(),
                ],
              ),
            ),
          ),
          _actionButtons(),
        ],
      ),
    );
  }

  Widget _outfitMainDetails() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(
            outfit.images.first
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: Container(
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildOutfitImage(),
              _buildRatingsSummary(),
              _commentsPreview(),
              Padding(padding: EdgeInsets.only(bottom: 8),),
            ],
          ),
        ],
      ),
    );
  }

  Widget _outfitTitle() {
    return Padding(
      padding: EdgeInsets.only(left: 32, right: 32, top: 8),
      child: Text(
        outfit.title,
        style: Theme.of(context).textTheme.headline.copyWith(
            letterSpacing: 1.2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOutfitImage() {
    List<int> imageIndexes = [];
    for(int i = 0; i < outfit.images.length; i ++){
      imageIndexes.add(i);
    }
    return Container(
      padding: EdgeInsets.only(top: 8),
      child: SizedBox(
        height: 250.0,
        child: CarouselSliderWithIndicator(
          height: 250,
          viewportFraction: 0.6,
          enableInfiniteScroll: false,
          items: imageIndexes.map((index) => _loadImage(index)).toList(),
        ),
      ),
    );
  }

  Widget _loadImage(int index){
    return Stack(
      children: <Widget>[
        _loadingImageSpinner(),
        Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black87,
                  blurRadius: 5,
                  offset: Offset(1.5, 1.5)
                )
              ]
            ),
            child: ImageGalleryPreview(
              imageUrls: outfit.images,
              currentIndex: index, 
              title: 'Outfit Image',
            ),
          ),
        ),
      ],
    );
  }

  Widget _loadingImageSpinner(){
    return Center(
      child: SizedBox(
        height: 50,
        width: 50,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[700],
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 2,
                offset: Offset(1, 1)
              )
            ]
          ),
          padding: EdgeInsets.all(8),
          child: Theme(
            data: ThemeData(
              accentColor: Colors.white,
            ),
            child: CircularProgressIndicator()
          ),
        ),
      ),
    );
  }

  Widget _buildRatingsSummary(){
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 8, right: 8, top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Text(
              outfit.averageRating.toString(),
              style: Theme.of(context).textTheme.subtitle.copyWith(
                color: Colors.red[900],
              ),
              textAlign: TextAlign.end,
            ),
          ),
          Container(
            padding: EdgeInsets.all(4),
            child: RatingBar(
              value: outfit?.averageRating,
              size: 28,
            ),
          ),
          Expanded(
            child: Text(
              '${outfit.ratingsCount} Rating${outfit.ratingsCount==1?'':'s'}',
              style: Theme.of(context).textTheme.subtitle.copyWith(
                color: Colors.red[900],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _outfitFurtherDetails() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          UserPreviewCard(
            outfit.poster,
            isPoster: true,
            pagesSinceOutfitScreen: widget.pagesSinceOutfitScreen+1,
            pagesSinceProfileScreen: widget.pagesSinceProfileScreen,
          ),
          _styleSummary(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _buildOutfitDescription(),
          ),
        ],
      )
    );
  }
  
  Widget _styleSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          StyleSticker(
            size: 12,
            style: Style.fromStyleString(outfit.style),
          ),
          Text(
            DateFormatter.dateToSimpleFormat(outfit.createdAt),
            style: Theme.of(context).textTheme.subtitle.copyWith(
              color: Colors.black45
            )
          ),
        ],
      ),
    );
  }
  Widget _buildOutfitDescription() {
    if(outfit.description == null){
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "No description has been added",
            style: Theme.of(context).textTheme.subhead.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w300
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 4.0),
            child: Text(
              "Description",
              style: Theme.of(context).textTheme.headline.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w300
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.grey[350]
            ),
            width: double.infinity,
            padding: EdgeInsets.all(8.0),
            child: Text(
              outfit.description,
              style: Theme.of(context).textTheme.body1.copyWith(
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons(){
    OutfitSave saveData = OutfitSave(
      outfit: outfit,
      userId: userId,
    );
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 2
          )
        ]
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _actionButton(
            icon: Icon(
              Icons.add_comment,
              size: 24,
            ),
            text: 'Comment',
            onPressed: () => _loadCommentsPage(
              focusComment: true,
            ),
          ),
          _actionButton(
            icon: Image.asset(
              outfit.hasRating ? 'assets/flame_full.png' : 'assets/flame_empty.png',
              width: 24,
              height: 24,
            ),
            text: 'Rate',
            selected: outfit.hasRating,
            iconPadding: 8,
            onPressed: () => _rateOutfit(),
          ),
          _actionButton(
            icon: Icon(
              Icons.playlist_add,
              size: 24,
              color: hasMaxLookbookOutfits ? Colors.red : Colors.black,
            ),
            isEnd: true,
            text: 'Add to',
            unselectedColor: hasMaxLookbookOutfits ? Colors.red : Colors.black,
            onPressed: () {
              if(hasMaxLookbookOutfits) {
                toast("Max storage reached");
              } else {
                AddToLookbookDialog.launch(context, outfitSave: saveData);
              }
            }
          ),
        ],
      ),
    );
  }

  _rateOutfit() {
    return showDialog(
      context: context,
      builder: (ctx) {
        return RatingDialog(
          initialValue: outfit.userRating,
          isUpdate: outfit.hasRating,
          isTransparent: false,
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

  Widget _actionButton({Widget icon, String text, Color unselectedColor = Colors.black,  double iconPadding = 4.0, bool selected = false, VoidCallback onPressed, bool isEnd = false}){
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: onPressed,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RawMaterialButton(
                    fillColor: Colors.white,
                    elevation: 2,
                    shape: CircleBorder(
                      side: BorderSide(
                        color: Colors.grey.withOpacity(0.5),
                        width: 0.5
                      )
                    ),
                    onPressed: onPressed,
                    child: Padding(
                      padding: EdgeInsets.all(iconPadding),
                      child: icon,
                    )
                  ),
                  Text(
                    '$text${selected? 'd':''}', 
                    style: Theme.of(context).textTheme.caption.copyWith(
                      color: selected? Colors.red : unselectedColor
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _commentsPreview(){
    String text = 'View 0 Comments';
    if(outfit.commentsCount==1){
      text = 'View 1 Comment';
    }
    else if(outfit.commentsCount>1){
      text = 'View all ${outfit.commentsCount} Comments';
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _loadCommentsPage(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            text,
            style: Theme.of(context).textTheme.subtitle.copyWith(
              color: Colors.blue[900]
            ),
          ),
        ),
      ),
    );
  }

  _loadCommentsPage({bool focusComment = false}) {
    CustomNavigator.goToCommentsScreen(context,
      focusComment: focusComment,
      outfitId: outfit.outfitId,
      pagesSinceOutfitScreen: widget.pagesSinceOutfitScreen+1,
      pagesSinceProfileScreen: widget.pagesSinceProfileScreen,
    );
  }
}
