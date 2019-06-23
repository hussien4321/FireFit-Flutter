import 'package:flutter/material.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:middleware/middleware.dart';
import 'package:helpers/helpers.dart';
import 'package:front_end/providers.dart';
import 'package:blocs/blocs.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:front_end/screens.dart';


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
      builder: (ctx, isLoadingSnap){
        if(isLoadingSnap.data){
          return _scaffold(
            body: _outfitLoadingPlaceholder()
          );
        }else{
          return StreamBuilder<Outfit>(
            stream: _outfitBloc.selectedOutfit,
            builder: (ctx, snap) { 
              if(!snap.hasData){    
                return _scaffold(body: _outfitLoadingPlaceholder());
              }
              outfit = snap.data;
              return _scaffold(body: _buildMainBody());
            },
          );
        }
      }
    );
  }

  _initBlocs() async {
    if(_outfitBloc==null){
      _outfitBloc = OutfitBlocProvider.of(context);
      userId = await UserBlocProvider.of(context).existingAuthId.first;
      LoadOutfit loadOutfit = LoadOutfit(
        outfitId: widget.outfitId,
        userId: userId,
        loadFromCloud: widget.loadOutfit
      );
      _outfitBloc.selectOutfit.add(loadOutfit);
    }
  }

  Widget _scaffold({Widget body}){
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: Navigator.of(context).pop,
        ),
        title: Text("${outfit?.poster?.name}'s Outfit"),
        centerTitle: true,
        elevation: 1.0,
        actions: <Widget>[
          _loadOutfitOptions()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadCommentsPage,
        backgroundColor: Colors.green,
        child: Icon(
          Icons.comment,
          color: Colors.white,
        ),
      ),
      body: body,
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
          noText: 'No',
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
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildOutfitImage(),
                  _buildImpressionsSummary(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildInteractButtons(),
                      Material(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 64.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              _buildTitleAndDate(),
                              _buildPosterInfo(),
                              _buildOutfitDescription(),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.grey[300]
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ), 
      child: SizedBox(
        height: 300.0,
        child: Hero(
          tag: outfit.images.first,  
          child: Container(
            child: Swiper(
              itemCount: outfit.images.length,
              viewportFraction: 0.8,
              scale: 0.9,
              itemBuilder: (context, i) => _loadImage(outfit.images[i]),
              loop: false,
              pagination: SwiperPagination(
                margin: EdgeInsets.only(top: 20.0),
                alignment: Alignment.bottomCenter,
                builder: DotSwiperPaginationBuilder(
                  color: Colors.grey,
                  activeColor: Colors.blueAccent,
                  size: 8,
                  activeSize: 12.0,
                )
              )
            ),
          ),
        ),
      ),
    );
  }

  Widget _loadImage(String url){
    return Container(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.contain,
      ),
    );
  }



  Widget _buildImpressionsSummary(){
    return Container(
      color: Colors.grey[300],
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _buildCommentsSummary(),
          _buildLikesSummary(),
        ],
      ),
    );
  }
  Widget _buildLikesSummary() {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(Icons.thumbs_up_down),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${outfit.likesOverallCount}',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' LIKES',
                  style: TextStyle(
                    letterSpacing: 1.5,
                    color: Colors.black,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ]
            ),
          ),
        ],
      )
    );
  }

  Widget _buildCommentsSummary(){
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Icon(Icons.comment),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${outfit.commentsCount} ',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
              ),
              TextSpan(
                text: 'COMMENT${outfit.commentsCount==1?'':'S'}',
                  style: TextStyle(
                    color: Colors.black,
                    letterSpacing: 1.5
                  ),
              ),
            ]
          ),
        ),
      ],
    );
  }

  Widget _buildInteractButtons() {
    OutfitImpression outfitImpression =OutfitImpression(
      outfit: outfit,
      userId: userId,
    );
    OutfitSave saveData = OutfitSave(
      outfit: outfit,
      userId: userId,
    );
    return Container(
      color: Colors.green,
      child: Material(
        child: Row(
          children: <Widget>[
            _buildInteractButton('Dislike', Colors.pinkAccent[700], 
              selected: outfit.userImpression == -1,
              onPressed: () => _outfitBloc.dislikeOutfit.add(outfitImpression)
            ),
            _buildInteractButton('Save', Colors.amberAccent[700], 
              selected: outfit.isSaved,
              onPressed: () => _outfitBloc.saveOutfit.add(saveData)
            ),
            _buildInteractButton('Like', Colors.blueAccent[700],
              selected: outfit.userImpression == 1,
              onPressed: () => _outfitBloc.likeOutfit.add(outfitImpression)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractButton(String name, Color color, {bool selected, VoidCallback onPressed}) {
    Color background = Colors.white;
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: BorderDirectional(
            bottom: BorderSide(
              color: selected ? background : color
            )
          ),
          color: selected ? color : null
        ),
        height: 50.0,
        padding: EdgeInsets.all(0.0),
        child: InkWell(
          child: Center(
            child: Text(
              '$name${selected?'d':''}',
              style: Theme.of(context).textTheme.subhead.apply(
                color: selected? background: color, 
                fontWeightDelta: 2
              ),
            )
          ),
          onTap: onPressed,
        ),
      ),
    );
  }

  Widget _buildTitleAndDate() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              outfit.title,
              style: Theme.of(context).textTheme.headline.apply(fontWeightDelta: 2),
            ),
          ),
          _drawMiniClothesStyle(Style.fromStyleString(outfit.style)),
        ],
      ),
    );
  }

  Widget _drawMiniClothesStyle(Style style){
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: style.backgroundColor
      ),
      padding: EdgeInsets.all(4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              style.name,
              style: Theme.of(context).textTheme.caption.apply(
                color: style.textColor
              ),
            ),
          ),
          Image.asset(
            style.asset,
            width: 30.0,
            height: 30.0,
          )
        ],
      ),
    );
  }

  Widget _buildPosterInfo() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
      child: Row(
        children: <Widget>[
          ProfilePicWithShadow(
            userId: outfit.poster.userId,
            url: outfit.poster.profilePicUrl,
            size: 50.0,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  outfit.poster.name,
                  style: Theme.of(context).textTheme.title,
                ),
                Text(
                  '@'+outfit.poster.username,
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
          ),
          Text(
            DateFormatter.dateToRecentFormat(outfit.createdAt),
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      ),
    );
  }
  
  Widget _buildOutfitDescription() {
    if(outfit.description == null){
      return Center(
        child: Text(
          "No description has been added",
          style: TextStyle(
            color: Colors.grey,
            fontStyle: FontStyle.italic
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

  Widget _buildCommentButton(){
    return Container(
      decoration: BoxDecoration(
        border: BorderDirectional(
          start: BorderSide(
            color: Colors.grey.withOpacity(0.5),
            width: 0.5
          )
        ),
        color: Colors.grey,
      ),
      width: double.infinity,
      child: FlatButton(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                'Add/View comments',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            Icon(
              Icons.add_comment,
              color: Colors.white,
            ),
          ],
        ),
        onPressed: () => _loadCommentsPage()
      ),
    );
  }
  _loadCommentsPage() {
    Navigator.push(context, MaterialPageRoute(
      builder: (ctx) => CommentsScreen(
        outfitId: outfit.outfitId,
      )
    ));
  }
}
