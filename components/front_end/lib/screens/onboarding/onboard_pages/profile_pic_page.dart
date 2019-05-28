import 'package:flutter/material.dart';
import 'dart:io';
import 'package:middleware/middleware.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'onboard_details.dart';

class ProfilePicPage extends StatelessWidget {
  
  final OnboardUser onboardUser;
  final ValueChanged<OnboardUser> onSave;

  ProfilePicPage({
    this.onboardUser,
    this.onSave
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
                GestureDetector(
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
                )
              ],
            )
          )
        ],
      ),
    );
  }

  bool get _hasProfilePicture => onboardUser.profilePicUrl != null;

  _uploadSinglePicture(BuildContext context) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null){
      onboardUser.profilePicUrl = image.path;
      onSave(onboardUser);
    }
  }
}