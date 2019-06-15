import 'package:flutter/material.dart';
import 'package:helpers/helpers.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:middleware/middleware.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:front_end/screens.dart';
import 'package:blocs/blocs.dart';
import 'package:front_end/providers.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class UploadOutfitScreen extends StatefulWidget {
  @override
  _UploadOutfitScreenState createState() => _UploadOutfitScreenState();
}


class _UploadOutfitScreenState extends State<UploadOutfitScreen> with LoadingAndErrorDialogs, SnackbarMessages {
  List<Asset> images = List<Asset>();

  UploadOutfit uploadOutfit;
  TextEditingController titleTextEdit;
  TextEditingController descriptionTextEdit;

  OutfitBloc _outfitBloc;
  UserBloc _userBloc;
  List<StreamSubscription<dynamic>> _subscriptions;
  
  bool loadingImages = false;

  String dirPath;

  @override
  void initState() {
    super.initState();
    uploadOutfit = UploadOutfit();
    titleTextEdit = TextEditingController(text: uploadOutfit.title);
    descriptionTextEdit = TextEditingController(text: uploadOutfit.description);

    _initTempGallery();
    
  }

  _initTempGallery() async{ 
    Directory extDir = await getApplicationDocumentsDirectory();
    dirPath = '${extDir.path}/Pictures/temp';
    await Directory(dirPath).delete(recursive: true);
    await Directory(dirPath).create(recursive: true);
  }

  @override
  dispose(){
    _subscriptions?.forEach((subscription) => subscription.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('New Outfit'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.send),
            color: uploadOutfit.canBeUploaded ? Colors.green : Colors.orange,
            onPressed: () {
              if(uploadOutfit.canBeUploaded){
                _uploadOutfit();
              }else{
                displayNoticeSnackBar(context, 'Finish steps 1-3 first!');
              }
            },
          )
        ],
      ),
      body: _buildBody(),
    );
  }

  _initBlocs() async {
    if(_outfitBloc==null){
      _outfitBloc = OutfitBlocProvider.of(context);
      _userBloc = UserBlocProvider.of(context);
      String userId = await _userBloc.existingAuthId.first;
      uploadOutfit.posterUserId = userId;
      _subscriptions = <StreamSubscription<dynamic>>[
        _loadingListener(),
        _successListener(),
        _errorListener(),
      ];
    }
  }

  StreamSubscription _loadingListener(){
    return _outfitBloc.isLoading.listen((loadingStatus) {
      if(loadingStatus){
        startLoading("Uploading outfit", context);
      }
      else{
        stopLoading(context);
      }
    });
  }


  StreamSubscription _successListener(){
    return _outfitBloc.isSuccessful.listen((successStatus) {
      if(successStatus){
        Navigator.pop(context);
      }
    });
  }

  StreamSubscription _errorListener(){
    return _outfitBloc.hasError.listen((errorMessage) {
      displayErrorSnackBar(context, errorMessage);
    });
  }

  
  _uploadOutfit() => _outfitBloc.uploadOutfit.add(uploadOutfit);
  
  
  Widget _buildBody(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildSummaryHeader(),
            _buildHeader(
              '1. Upload some pics (max 3)', 
              isComplete: uploadOutfit.imagesUploaded
            ),
            _buildImagesHolder(),
            _buildHeader(
              '2. Choose the style!', 
              isComplete: uploadOutfit.styleUploaded
            ),
            _buildStyleInput(),
            _buildHeader(
              '3. Give it a cool title', 
              isComplete: uploadOutfit.titleUploaded
            ),
            _buildTitleField(),
            _buildHeader(
              '4. Describe it further (optional)', 
              isComplete: uploadOutfit.descriptionUploaded
            ),
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

  Widget _buildStyleInput() {
    Style style = Style.fromStyleString(uploadOutfit.style);
    return StyleTab(
      style: style, 
      onTap: _selectNewStyle
    );
  }

  _selectNewStyle() async {
    String styleName = await Navigator.push(context, MaterialPageRoute(
      builder: (context) => StyleSelectorScreen()
    ));
    if(!mounted || styleName == null) return;
    setState(() {
      uploadOutfit.style = styleName;    
    });
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
        controller: titleTextEdit,
        onChanged: (newTitle) {
          setState((){
            uploadOutfit.title = newTitle;
          });
        },
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
        controller: descriptionTextEdit,
        onChanged: (newDesc) {
          setState((){
            uploadOutfit.description = newDesc;
          });
        },
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

  Widget _buildHeader(String title, {bool isComplete}){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      width: double.infinity,
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
              isComplete ? Icons.check : Icons.create,
              color: isComplete ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildImagesHolder() {
    List<Widget> tabs = [];
    for(int i = 0; i < uploadOutfit.images.length ; i ++){
      tabs.add(_displayImage(i));
    }
    if(uploadOutfit.images.length < 3){
      tabs.add(_remainingAddImageSpace(3-uploadOutfit.images.length));
    }
  
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      width: double.infinity,
      height: 200.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: tabs,
      )
    );
  }

  Widget _displayImage(int index){
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
                child: Image.file(
                  File(uploadOutfit.images[index]),
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
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      )
    );
  }

  _removeImage(int index){
    uploadOutfit.images.removeAt(index);
    images.removeAt(index);
    setState(() {});
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
          onTap: loadingImages ? null : _addImages,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              loadingImages ? CircularProgressIndicator() : Hero(
                tag: MMKeys.uploadButtonHero,
                child: Icon(Icons.add_a_photo),
              ),
              Text(
                loadingImages ? 'Loading...' : 'Add ${remainingImages==3?'an':(remainingImages==2?'another':'a final')} image',
                textAlign: TextAlign.center,
              )
            ],
          )
        )
      )
    );
  }


  Future<void> _addImages() async {
    List<Asset> resultList = List<Asset>();
    try {
      resultList = await _pickImages();
    } on PlatformException catch (e) {
      print('FAILED: ${e.message}');
    }
    if (!mounted) return;    
    _saveImages(resultList);
  }

  Future<List<Asset>> _pickImages() => MultiImagePicker.pickImages(
    maxImages: 3,
    enableCamera: true,
    selectedAssets: images,
    cupertinoOptions: CupertinoOptions(
      backgroundColor: "#D3D3D3",
    ),
    materialOptions: MaterialOptions(
      actionBarColor: "#808080",
      statusBarColor: "#808080",
      lightStatusBar: true,
      actionBarTitle: 'Select outfit'
    )
  );
  

  _saveImages(List<Asset> resultList) async {
    setState(() => loadingImages = true);

    for(Asset result in resultList){
      await _saveImage(result);
    }
    
    setState(() {
      uploadOutfit.images = uploadOutfit.images;
      loadingImages = false;
    });
  }

  String get timestamp => DateTime.now().millisecondsSinceEpoch.toString();

  _saveImage(Asset result) async {
    if(!images.any((Asset image) => result.identifier==image.identifier)){
      images.add(result);
      ByteData imageData = await result.requestOriginal(quality: 50);
      if(imageData != null){
        String filename = '$dirPath/$timestamp.jpg';
        File filePath = File(filename);
        await filePath.writeAsBytes(imageData.buffer.asInt8List());
        uploadOutfit.images.add(filename);
      }
    }
  }
}


