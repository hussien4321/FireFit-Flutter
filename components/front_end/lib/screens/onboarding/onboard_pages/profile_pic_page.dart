import 'package:flutter/material.dart';
import 'dart:io';
import 'package:middleware/middleware.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'onboard_details.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class ProfilePicPage extends StatelessWidget {
  
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
  Widget build(BuildContext context) {
    return Container(
      child: OnboardDetails(
        icon: FontAwesomeIcons.smile,
        title: "Say cheeeeeese!",
        children: <Widget>[
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Profile picture',
                    style: Theme.of(context).textTheme.subhead,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _imageViewer(context),
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
  bool get _hasProfilePicture => onboardUser.profilePicUrl != null;

  Widget _imageViewer(BuildContext context) {
    return GestureDetector(
      onTap: () => _uploadSinglePicture(context),
      child: Container(
        padding: EdgeInsets.all(10.0),
        width: 120.0,
        height: 120.0,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).accentColor,
            width: 1.0
          ),
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          color: Theme.of(context).disabledColor,
          image: _hasProfilePicture ? DecorationImage(
            image: FileImage(
              File(onboardUser.profilePicUrl),
            ),
            fit: BoxFit.cover
          ) : null,
        ),
        child: Center(
          child: !_hasProfilePicture ? Text(
            'Upload',
            style: Theme.of(context).textTheme.button.apply(color: Colors.white),
          ): Container(),
        ),
      )
    );
  }

  Widget _compliment(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        'Looking good!',
        style: Theme.of(context).textTheme.body2.apply(color: Colors.blue),
      ),
    );
  }


  _uploadSinglePicture(BuildContext context) async {
    List<String> currentImages = [];
    List<Asset> selectedAssets = [];
    if(onboardUser.profilePicUrl!=null){
      currentImages.add(onboardUser.profilePicUrl);
      selectedAssets.add(selectedAsset);
    }
    List<String> takenImages = await SelectImages.addImages(
      count: 1,
      dirPath: dirPath,
      isStillOpen: () => true,
      selectedAssets: selectedAssets,
      currentImages: currentImages,
    );
    if(takenImages.isNotEmpty){
      print('got user id ${takenImages.first}');
      onboardUser.profilePicUrl = takenImages.first;
      onUpdateAsset(selectedAssets.first);
      onSave(onboardUser);
    }
  }
}