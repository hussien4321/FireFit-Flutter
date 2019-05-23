import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:middleware/middleware.dart';
import 'package:helpers/helpers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class OutfitDetailsScreen extends StatefulWidget {

  final Outfit outfit;

  OutfitDetailsScreen({this.outfit});

  @override
  _OutfitDetailsScreenState createState() => _OutfitDetailsScreenState();
}

class _OutfitDetailsScreenState extends State<OutfitDetailsScreen> {

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Outfit details"),
        centerTitle: true,
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: (){},
          )
        ],
      ),
      body: _buildMainBody(),
    );
  }

  _buildMainBody() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
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
                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
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
          tag: widget.outfit.images.first,  
          child: Container(
            child: Swiper(
              itemCount: widget.outfit.images.length,
              viewportFraction: 0.8,
              scale: 0.9,
              itemBuilder: (context, i) => _loadImage(widget.outfit.images[i]),
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
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildLikesSummary(),
          Padding(padding: EdgeInsets.symmetric(horizontal: 8.0),),
          _buildCommentsSummary(),
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
                  text: '${widget.outfit.likesCount} ',
                  style: TextStyle(
                    color: Colors.black,
                    letterSpacing: 1.5
                  ),
                ),
                TextSpan(
                  text: 'TOTAL LIKE${widget.outfit.likesCount==1?'':'S'}',
                  style: TextStyle(
                    color: Colors.black,
                    letterSpacing: 1.5
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
                text: '${widget.outfit.commentsCount} ',
                  style: TextStyle(
                    color: Colors.black,
                    letterSpacing: 1.5
                  ),
              ),
              TextSpan(
                text: 'COMMENT${widget.outfit.likesCount==1?'':'S'}',
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
    return Container(
      color: Colors.green,
      child: Material(
        child: Row(
          children: <Widget>[
            _buildInteractButton('Dislike', Colors.pinkAccent[700], false),
            _buildInteractButton('Save', Colors.amberAccent[700], true),
            _buildInteractButton('Like', Colors.blueAccent[700], false),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractButton(String name, Color color, bool selected) {
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
          onTap: () => print('aa'),
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
              widget.outfit.title,
              style: Theme.of(context).textTheme.display1,
            ),
          ),
          _drawMiniClothesStyle(Style.fromStyleString(widget.outfit.style)),
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
      padding: const EdgeInsets.only(bottom: 8.0, left: 16.0, right: 16.0),
      child: Row(
        children: <Widget>[
          ProfilePicWithShadow(
            url: widget.outfit.poster.profilePicUrl,
          ),
          Expanded(
            child: Text(
              widget.outfit.poster.name,
              style: Theme.of(context).textTheme.title,
            ),
          ),
          Text(
            DateFormatter.dateToRecentFormat(widget.outfit.createdAt),
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      ),
    );
  }
  
  Widget _buildOutfitDescription() {
    if(widget.outfit.description == null){
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
              widget.outfit.description,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildCommentField() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ProfilePicWithShadow(
              url: widget.outfit.poster.profilePicUrl,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 2.0),
                  child: Text(
                    widget.outfit.poster.name,
                    style: Theme.of(context).textTheme.subtitle
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.grey[350]
                  ),
                  width: double.infinity,
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'widget outfit description widget outfit description widget outfit description widget outfit description ',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: IconButton(
              icon: Icon(
                FontAwesomeIcons.solidHeart,
                color: Colors.redAccent,
              ),
              onPressed: () => print('aaa'),
            ),
          ),
        ],
      ),
    );
  }
}