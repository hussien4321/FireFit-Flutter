import 'package:firebase_storage/firebase_storage.dart';
import 'package:meta/meta.dart';
import 'dart:io';
import 'dart:async';

class FirebaseImageUploader {

  
  final FirebaseStorage storage;

  const FirebaseImageUploader({
    @required this.storage,
  });

  Future<Null> uploadImages(List<String> imagePaths, List<String> imageNames) async {    
    for(int i = 0; i < imagePaths.length; i++){
      await uploadImage(imagePaths[i], imageNames[i]);  
    }
  }


  Future<Null> uploadImage(String imagePath, String imageName) async {
    final Reference ref =
        storage.ref().child(imageName);
    
    UploadTask uploadTask = ref.putFile(
      File(imagePath),
      SettableMetadata(
        contentType: 'image/jpeg'
      ),
    );
    
    await uploadTask.whenComplete(() => null);
  }
  
}