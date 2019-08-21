import 'package:flutter/material.dart';
import 'dart:io';
import 'package:middleware/middleware.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'onboard_details.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class ProfilePicPage extends StatefulWidget {
  
  final OnboardUser onboardUser;
  final ValueChanged<OnboardUser> onSave;
  final String dirPath;
  final Asset selectedAsset;
  final ValueChanged<Asset> onUpdateAsset;

  ProfilePicPage({
    this.onboardUser,
    this.onSave,
    this.dirPath,
    this.selectedAsset,
    this.onUpdateAsset,
  });

  @override
  _ProfilePicPageState createState() => _ProfilePicPageState();
}

class _ProfilePicPageState extends State<ProfilePicPage> {
  bool loadingImages = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: OnboardDetails(
        icon: FontAwesomeIcons.smile,
        title: "Say cheeeeeese!",
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Profile picture',
                    style: Theme.of(context).textTheme.subtitle,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // _imageViewer(context),
                    _buildProfilePicView(),
                    _hasProfilePicture ? _compliment(context) : Container(),
                  ],
                )
              ],
            )
          )
        ],
      ),
    );
  }

  bool get _hasProfilePicture => widget.onboardUser.profilePicUrl != null;


  Widget _compliment(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        'Looking good!',
        style: Theme.of(context).textTheme.body2.apply(color: Colors.blue),
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
      child: !loadingImages ? 
      _innerTagData(
        icon: Icon(
          Icons.camera,
          size: 48,
          color: Colors.white,
        ),
        text: 'Upload Pic',
      ) :
      _innerTagData(
        icon: Theme(
          data: ThemeData(
            accentColor: Colors.white
          ),
          child: CircularProgressIndicator(),
        ),
        text: 'Loading...',
      ),
      foregroundDecoration: loadingImages || widget.onboardUser.profilePicUrl==null ? null : BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: FileImage(
            File(widget.onboardUser.profilePicUrl),
          )
        )
      ),
    );
  }

  Widget _innerTagData({
    Widget icon,
    String text,
  }){
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          icon,
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              text,
              style: Theme.of(context).textTheme.title.apply(color: Colors.white),
            ),
          ),
        ],
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
    if(widget.onboardUser.profilePicUrl!=null){
      currentImages.add(widget.onboardUser.profilePicUrl);
      selectedAssets.add(widget.selectedAsset);
    }
    List<String> takenImages = await SelectImages.addImages(
      context,
      count: 1,
      dirPath: widget.dirPath,
      isStillOpen: () => mounted,
      selectedAssets: selectedAssets,
      currentImages: currentImages,
      title: 'Select picture'
    );
    if(takenImages.isNotEmpty){
      widget.onboardUser.profilePicUrl = takenImages.first;
      widget.onUpdateAsset(selectedAssets.first);
      widget.onSave(widget.onboardUser);
    }
    setState(() {
      loadingImages = false;
    });
  }
}