import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mira_mira/helper_widgets.dart';
import 'package:data_handler/data_handler.dart';

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
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
 }  
  //MAKE STATELESS AND REMOVE APP STATUS BAR
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Outfit details"),
        centerTitle: true,
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
      child: SingleChildScrollView(
        child: Column(

          children: <Widget>[
            _buildOutfitImage(),
            Transform(
              transform: Matrix4.translationValues(0, -20, 0),
              child: Container(
                padding: EdgeInsets.only(top: 16, left: 16.0, right: 16.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.outfit.name,
                      style: Theme.of(context).textTheme.headline,
                    ),
                    _buildPosterTab()
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOutfitImage() {
    return Stack(
      children: <Widget>[
        Container(
          height: 320.0,
          width: double.infinity,
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
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 300.0,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
              child: Hero(
                tag: widget.outfit.images.first,
                child: Container(
                  child: MirrorFrame(
                    child: Image.asset(
                      //TODO: SHOW PAGECONTROLLER OF MULTIPLE IMAGES
                      widget.outfit.images.first,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPosterTab() {
    return Row(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(right: 8.0),
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(widget.outfit.poster.profilePic),
              fit: BoxFit.cover
            ),
            shape: BoxShape.circle,
            color: Colors.grey,
            boxShadow: [
              BoxShadow(
                color: Colors.black38,
                offset: Offset(0, 2),
                blurRadius: 2,
                spreadRadius: 1
              )
            ]
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'By ',
                style: Theme.of(context).textTheme.subtitle,
              ),
              TextSpan(
                text: widget.outfit.poster.name,
                style: Theme.of(context).textTheme.title,
              )
            ]
          ),
        ),
      ],
    );
  }
  
}