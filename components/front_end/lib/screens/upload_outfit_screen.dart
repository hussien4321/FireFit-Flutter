import 'package:flutter/material.dart';
import 'package:helpers/helpers.dart';

class UploadOutfitScreen extends StatefulWidget {
  @override
  _UploadOutfitScreenState createState() => _UploadOutfitScreenState();
}

class _UploadOutfitScreenState extends State<UploadOutfitScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('New Outfit'),
        centerTitle: true,
        actions: <Widget>[
          _buildUploadButton()
        ],
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildUploadButton() {
    return IconButton(
      icon: Icon(Icons.send),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _buildBody(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildSummaryHeader(),
            _buildHeader('1. Upload some pics (max 3)',true),
            _buildImagesHolder(),
            _buildHeader('2. Choose the style!', true),
            _buildStyleInput(ClothesStyles.STREET),
            _buildHeader('3. Give it a cool title', true),
            _buildTitleField(),
            _buildHeader('4. Describe it further (optional)', true),
            _buildDescriptionField(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryHeader() {
    return Container(
      padding: EdgeInsets.only(top: 16.0),
      child: Center(
        child: Text(
          'Upload a new outfit in 4 quick steps!',
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.grey,
            fontStyle: FontStyle.italic
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildStyleInput(ClothesStyles clothesStyle) {
    Style style = Style(clothesStyle);
    return Container(
      width: double.infinity,
      height: 70.0,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            style.name,
            style: Theme.of(context).textTheme.display1.apply(color: style.textColor,),
          ),
          Image.asset(
            style.asset,
            width: 50.0,
            height: 50.0,
            fit: BoxFit.contain,
          )
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return Container(
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.only(bottom: 8.0),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.grey[350]
      ),
      child: TextField(
        textCapitalization: TextCapitalization.words,
        style: Theme.of(context).textTheme.display1.apply(color: Colors.black),
        decoration: new InputDecoration.collapsed(
          hintText: "Theme/mood of this look...",
          hintStyle: Theme.of(context).textTheme.headline.apply(color: Colors.black.withOpacity(0.5))
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.grey[350]
      ),
      margin: EdgeInsets.only(bottom: 16.0),
      padding: EdgeInsets.all(8.0),
      width: double.infinity,
      child: TextField(
        textCapitalization: TextCapitalization.sentences,
        maxLines: 5,
        maxLength: 300,
        maxLengthEnforced: true,
        style: Theme.of(context).textTheme.subhead,
        decoration: new InputDecoration.collapsed(
          hintText: "e.g:\nWhere did you get these clothes?\nWhat inspired this fit?\nWhat do you want feedback on?",
          
        ),
      ),
    );
  }

  Widget _buildHeader(String title, bool completion){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      width: double.infinity,
      decoration: BoxDecoration(
        // border: BorderDirectional(
        //   bottom: BorderSide(
        //     color: Colors.grey.withOpacity(0.5),
        //     width: 0.5
        //   )
        // )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.subtitle,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(
              completion ? Icons.check : Icons.create,
              color: completion ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildImagesHolder() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      width: double.infinity,
      height: 200.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _displayImage('https://metrouk2.files.wordpress.com/2011/11/article-1320581523573-0eb039e700000578-474750_323x650.jpg'),
          _displayImage('https://qph.fs.quoracdn.net/main-qimg-c86ca0b2a2796a6a3b27798260be7d7b.webp'),
          _displayImage('http://1.media.collegehumor.cvcdn.com/38/76/2fbf94ed6d3a5bcc3cf4296f086a332f.jpg'),
          // _remainingAddImageSpace(1),
        ],
      )
    );
  }

  Widget _displayImage(String url){
    return Expanded(
      flex: 1,
      child: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0,),
              border: Border.all(),
              color: Colors.grey.withOpacity(0.5),
            ),
            child: SizedBox.expand(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            right:0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ),
        ],
      )
    );
  }

  Widget _remainingAddImageSpace(int remainingImages){
    return Expanded(
      flex: remainingImages,
      child: Container(
        margin: EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0,),
          border: Border.all(),
          color: Colors.grey.withOpacity(0.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.0,),
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Icon(Icons.add),
              Text(
                'Add ${remainingImages==3?'an':(remainingImages==2?'another':'a final')} image',
                textAlign: TextAlign.center,
              )
            ],
          )
        )
      )
    );
  }
}