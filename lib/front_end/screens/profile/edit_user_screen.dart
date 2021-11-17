import 'package:flutter/material.dart';
import '../../../../middleware/middleware.dart';
import 'package:meta/meta.dart';
import '../../../../blocs/blocs.dart';
import '../../../../front_end/providers.dart';
import '../../../../front_end/helper_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class EditUserScreen extends StatefulWidget {
  
  final User user;
  
  EditUserScreen({
    @required this.user,
  });
  
  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> with LoadingAndErrorDialogs {
  
  UserBloc _userBloc;
  EditUser editUserData;

  List<StreamSubscription<dynamic>> _subscriptions;
  bool isOverlayShowing = false;

  bool loadingImages = false;
  Asset selectedAsset;
  String dirPath;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  FocusNode bioFocus =FocusNode();


  @override
  void initState() {
    super.initState();
    editUserData = EditUser.fromUser(widget.user);
    _nameController.text = editUserData.name;
    _bioController.text = editUserData.bio;
    _initTempGallery();    
  }

  _initTempGallery() async{ 
    Directory extDir = Platform.isIOS ? await getApplicationSupportDirectory()  : await getExternalStorageDirectory();
    dirPath = '${extDir.path}/Pictures/temp';
    final dir = Directory(dirPath);
    if(dir.existsSync()){
      dir.deleteSync(recursive: true);
    }
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
    return CustomScaffold(
      title: "Edit Profile",
      actions: <Widget>[
        _saveOutfitButton()
      ],
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: 8, right: 8, top: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildHeader(
                'Profile pic',
                isUpdated: editUserData.hasNewProfilePic,
              ),
              _buildProfilePicView(),
              _buildHeader(
                'Name', 
                isUpdated: editUserData.name != widget.user.name,
                isEmpty: !editUserData.hasName
              ),
              _buildNameField(),
              _buildHeader(
                'Bio', 
                isUpdated: editUserData.bio != widget.user.bio,
              ),
              _buildBioField(),
            ],
          ),
        ),
      ),
    );
  }

  _initBlocs() {
    if(_userBloc == null){
      _userBloc = UserBlocProvider.of(context);
      editUserData = EditUser.fromUser(widget.user);
      _subscriptions = <StreamSubscription<dynamic>>[
        _loadingListener(),
        _successListener(),
      ];

    }
  }

  StreamSubscription _loadingListener(){
    return _userBloc.isLoading.listen((loadingStatus) {
      if(loadingStatus && !isOverlayShowing){
        startLoading("Updating profile", context);
        isOverlayShowing = true;
      }
      if(!loadingStatus && isOverlayShowing){
        isOverlayShowing = false;
        stopLoading(context);
      }
    });
  }
  StreamSubscription _successListener(){
    return _userBloc.isSuccessful.listen((successStatus) {
      if(successStatus){
        Navigator.pop(context);
      }
    });
  }

  Widget _saveOutfitButton() {
    return IconButton(
      icon: Icon(Icons.save),
      color: Colors.green,
      onPressed: hasNewData && editUserData.canBeUpdated ? _editUser : null,
    );
  }

  bool get hasNewData {
    return !(widget.user.name == editUserData.name &&
    widget.user.bio == editUserData.bio &&
    widget.user.profilePicUrl == editUserData.profilePicUrl);
  }

  _editUser() {
    _userBloc.editUser.add(editUserData);;
  }

  Widget _buildHeader(String title, {bool isUpdated, bool isEmpty = false}){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.overline,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: isEmpty ? Container() : Icon(
              isUpdated ? Icons.fiber_new : Icons.check,
              color: isUpdated ? Colors.amber[800] : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePicView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 160,
          height: 160,
          child: Stack(
            children: <Widget>[
              _largeProfilePic(),
              Positioned(
                right: 0,
                bottom: 0,
                child: _editProfilePicButton(),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _largeProfilePic() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            blurRadius: 3,
            color: Colors.black54
          )
        ],
        color: Colors.grey,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Theme(
              data: ThemeData(
                accentColor: Colors.white
              ),
              child: CircularProgressIndicator(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Loading...',
                style: Theme.of(context).textTheme.bodyText2.apply(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      foregroundDecoration: loadingImages ? null : BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: editUserData.hasNewProfilePic ? FileImage(
            File(editUserData.profilePicUrl),
          ): CachedNetworkImageProvider(
            editUserData.profilePicUrl
          )
        )
      ),
    );
  }

  Widget _editProfilePicButton() {
    return Material(
      color: Colors.amber[800],
      shadowColor: Colors.black54,
      elevation: 2,
      shape: CircleBorder(),
      child: InkWell(
        customBorder: CircleBorder(),
        onTap: _uploadNewProfilePic,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.edit,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }

  _uploadNewProfilePic() async {
    setState(() => loadingImages = true);
    List<String> currentImages = [];
    List<Asset> selectedAssets = [];
    if(editUserData.hasNewProfilePic){
      currentImages.add(editUserData.profilePicUrl);
      selectedAssets.add(selectedAsset);
    }
    List<String> takenImages = await SelectImages.addImages(
      context,
      count: 1,
      dirPath: dirPath,
      isStillOpen: () => mounted,
      selectedAssets: selectedAssets,
      currentImages: currentImages,
      title: 'Select picture'
    );
    if(takenImages.isNotEmpty){
      editUserData.profilePicUrl = takenImages.first;
      selectedAsset = selectedAssets.first;
    }
    setState(() {
      loadingImages = false;
      editUserData.profilePicUrl = editUserData.profilePicUrl;
    });
  }


  Widget _buildNameField() {
    return Flexible(
      child: Container(
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.only(bottom: 8.0),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.grey[350]
        ),
        child: TextField(
          controller: _nameController,
          onChanged: (newName) {
            setState((){
            editUserData.name = newName;
            });
          },
          maxLength: 50,
          maxLengthEnforced: true,
          onSubmitted: (t) => FocusScope.of(context).requestFocus(bioFocus),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          style: Theme.of(context).textTheme.overline.apply(color: Colors.black),
          decoration: new InputDecoration.collapsed(
            hintText: "Theme/mood of this look...",
            hintStyle: Theme.of(context).textTheme.overline.apply(color: Colors.black.withOpacity(0.5))
          ),
        ),
      ),
    );
  } 

  Widget _buildBioField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.grey[350]
      ),
      margin: EdgeInsets.only(bottom: 16.0),
      padding: EdgeInsets.all(8.0),
      width: double.infinity,
      child: TextField(
        controller: _bioController,
        focusNode: bioFocus,
        onChanged: (newBio) {
          if(newBio.isEmpty){
            newBio = null;
          }
          setState((){
            editUserData.bio = newBio;
          });
        },
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.newline,
        maxLines: 5,
        maxLength: 500,
        maxLengthEnforced: true,
        style: Theme.of(context).textTheme.headline5,
        decoration: new InputDecoration.collapsed(
          hintText: "e.g:\nDescribe your own fashion style, what kind of stuff you like to wear and maybe some of your favourite brands!",
        ),
      ),
    );
  }

}