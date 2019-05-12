import 'package:firebase_storage/firebase_storage.dart';
import 'package:helpers/helpers.dart';
import 'package:meta/meta.dart';
import 'dart:io';
import 'package:path/path.dart';

class FirebaseImageUploader {

  
  final FirebaseStorage storage;

  const FirebaseImageUploader({
    @required this.storage,
  });

  Future<List<String>> uploadImages(List<String> imagePaths) async {
    
    List<String> imageUrls = [];

    for(int i = 0; i < imagePaths.length; i++){
      String imageUrl = await uploadImage(imagePaths[i]);  
      imageUrls.add(imageUrl);
    }

    return imageUrls;
  }


  Future<String> uploadImage(String image){
    final String uuid = Uuid().generateV4();

    String filename = '${uuid.toString()}-${basename(image)}';
    final StorageReference ref =
        storage.ref().child(filename);
    
    StorageUploadTask uploadTask = ref.putFile(
      File(image),
      StorageMetadata(
        contentType: 'image/jpeg'
      ),
    );
    
    return uploadTask.onComplete.then((snapshot) async {
      String url = await snapshot.ref.getDownloadURL();
      return url;
    });
  }
  
}