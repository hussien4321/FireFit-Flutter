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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum OutfitOption { EDIT, REPORT, DELETE }

class OutfitDetailsScreen extends StatefulWidget {

  final int outfitId;
  final bool loadOutfit;

  OutfitDetailsScreen({
    this.outfitId,
    this.loadOutfit = false,
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
  
  @override
  void initState() {
    super.initState();
    // SystemChrome.setEnabledSystemUIOverlays([]);
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
      stream: _outfitBloc.isLoading,
      initialData: false,
      builder: (ctx, isLoadingSnap) => StreamBuilder<Outfit>(
        stream: _outfitBloc.selectedOutfit,
        builder: (ctx, outfitSnap) {
          if(isLoadingSnap.data || !outfitSnap.hasData && outfitSnap.data == null){
            return _overlayScaffold(
              body: _outfitLoadingPlaceholder()
            );
          }else{
            outfit = outfitSnap.data;
            return _overlayScaffold(body: _buildMainBody());
          }
        }
      ),
    );
  }

  _initBlocs() async {
    if(_outfitBloc==null){
      _outfitBloc = OutfitBlocProvider.of(context);
      userId = await UserBlocProvider.of(context).existingAuthId.first;
      _outfitBloc.selectOutfit.add(LoadOutfit(
        outfitId: widget.outfitId,
        userId: userId,
        loadFromCloud: widget.loadOutfit
      ));
    }
  }
  Widget _overlayScaffold({Widget body}){
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              body,
              _appBarButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBarButtons() {
    return Positioned(
      top: 0,
      right: 0,
      left: 0,
      child: Container(
        padding: EdgeInsets.all(4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              padding: EdgeInsets.all(0),
              onPressed: Navigator.of(context).pop,
              icon: Icon(Icons.close),
            ),
            outfit == null ? Container() : _loadOutfitOptions()
          ],
        ),
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
        break;
      case OutfitOption.DELETE:
        _confirmDelete();
        break;
      default:
        return null;
    }
  }

  _editOutfit() {
    Navigator.push(context, MaterialPageRoute(
      builder: (ctx) => EditOutfitScreen(
        outfit: outfit,
      )
    ));
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(
                          outfit.images.first
                        ),
                        
                        fit: BoxFit.cover,
                      ),
                       boxShadow: []
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
                            _outfitTitle(),    
                            _buildOutfitImage(),
                            _buildRatingsSummary(),
                            _styleSummary(),
                            Padding(padding: EdgeInsets.only(bottom: 8),),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            _buildPosterInfo(),
                            _buildOutfitDescription(),
                            _actionButtons(),
                            _commentsPreview(),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _outfitTitle() {
    return Padding(
      padding: EdgeInsets.only(left: 64, right: 64, top: 12),
      child: Text(
        outfit.title,
        style: Theme.of(context).textTheme.headline.apply(fontWeightDelta: 2),
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
      padding: EdgeInsets.only(top: 16),
      child: SizedBox(
        height: 300.0,
        child: Container(
          child: CarouselSliderWithIndicator(
            height: 300,
            viewportFraction: 0.7,
            enableInfiniteScroll: false,
            items: imageIndexes.map((index) => _loadImage(index)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _loadImage(int index){
    return Container(
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
    );
  }



  Widget _buildRatingsSummary(){
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Text(
          //   'Rating:',
          //   style: Theme.of(context).textTheme.display1.copyWith(
          //     color: Colors.red[900],
          //     fontSize: 28,
          //     fontWeight: FontWeight.bold,
          //     fontStyle: FontStyle.italic
          //   ),
          // ),
          Container(
            padding: EdgeInsets.all(4),
            child: RatingBar(
              value: outfit?.averageRating?.round(),
              size: 28,
            ),
          )
        ],
      ),
    );
  }

  Widget _styleSummary() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: outfit.style
          ),
          TextSpan(
            text: ' - '
          ),
          TextSpan(
            text: DateFormatter.dateToSimpleFormat(outfit.createdAt)
          )
        ],
        style: Theme.of(context).textTheme.subtitle.copyWith(
          fontStyle: FontStyle.italic,
          color: Colors.black45
        ),
      ),
    );
  }

  Widget _buildPosterInfo() {
    String hero = 'Outfit-details-poster-${outfit.poster.profilePicUrl}';
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 3,
        color: Colors.grey[200],
        child: InkWell(
          onTap: () => _navigateToProfileScreen(hero),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ProfilePicWithShadow(
                  hasOnClick: false,
                  userId: outfit.poster.userId,
                  url: outfit.poster.profilePicUrl,
                  size: 50.0,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Posted by:',
                        style: Theme.of(context).textTheme.caption,
                      ),
                      Text(
                        outfit.poster.name,
                        style: Theme.of(context).textTheme.title,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'View Profile',
                    style: Theme.of(context).textTheme.button.apply(color: Colors.black),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _navigateToProfileScreen(String hero) {
    CustomNavigator.goToProfileScreen(context, true,
      userId: outfit.poster.userId,
      heroTag: hero,
    );
  }
  
  Widget _buildOutfitDescription() {
    if(outfit.description == null){
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "No description has been added",
            style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic
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
              "Description:",
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.grey[350]
            ),
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 16.0),
            padding: EdgeInsets.all(8.0),
            child: Text(
              outfit.description,
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _actionButton(
            icon: Icons.add_comment,
            text: 'Commment',
            onPressed: () => _loadCommentsPage(
              focusComment: true,
            ),
          ),
          _actionButton(
            icon: FontAwesomeIcons.fireAlt,
            selectedIcon: FontAwesomeIcons.fire,
            text: 'Rate',
            selected: outfit.hasRating,
            onPressed: () => _rateOutfit(),
          ),
          _actionButton(
            icon: Icons.star_border,
            text: 'Save',
            selected: outfit.isSaved,
            selectedIcon: Icons.star,
            onPressed: () => _outfitBloc.saveOutfit.add(saveData)
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

  Widget _actionButton({IconData icon, String text, bool selected = false, IconData selectedIcon, VoidCallback onPressed, bool isEnd = false}){
    return Expanded(
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: isEnd ? null :BoxDecoration(
              border: BorderDirectional(
                end: BorderSide(
                  color: Colors.grey[300],
                  width: 0.5
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Material(
                    elevation: selected ? 0 : 1,
                    shape: CircleBorder(
                      side: BorderSide(
                        color: Colors.black,
                        width: 0.5
                      )                    
                    ),
                    color: selected? Colors.black : Colors.white,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        selected ? selectedIcon : icon,
                        color: selected ? Colors.white : Colors.black
                      )
                    ),
                  ),
                ),
                Text(
                  '$text${selected? 'd':''}', 
                  style: Theme.of(context).textTheme.caption
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _commentsPreview(){
    return Padding(
      padding: EdgeInsets.only(left: 8, bottom: 8),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: () => _loadCommentsPage(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Text(
              'View all ${outfit.commentsCount} comment${outfit.commentsCount==1?'':'s'}',
              style: Theme.of(context).textTheme.subtitle.copyWith(
                color: Colors.black
              ),
            ),
          ),
        ),
      ),
    );
  }

  _loadCommentsPage({bool focusComment = false}) {
    Navigator.push(context, MaterialPageRoute(
      builder: (ctx) => CommentsScreen(
        outfitId: outfit.outfitId,
        focusComment: focusComment,
      )
    ));
  }
}
