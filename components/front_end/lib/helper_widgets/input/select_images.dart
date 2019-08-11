import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'dart:async';
import 'package:front_end/helper_widgets.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

class SelectImages {

  static Future<List<String>> addImages(BuildContext context, {int count, String dirPath, List<Asset> selectedAssets, List<String> currentImages, bool Function() isStillOpen, String title = 'Select outfit'}) async {
    List<Asset> resultList = List<Asset>();
    try {
      resultList = await _pickImages(count, selectedAssets, title);
    } on PlatformException catch (e) {
      print('FAILED: ${e.message}');
      PermissionDialog.launch(context);
    }
    _removeDeselectedImages(resultList, selectedAssets, currentImages);

    if (!isStillOpen()) return null;
    List<String> newImages = await _saveImages(dirPath, resultList, selectedAssets);

    return currentImages..addAll(newImages);
  }
  

  static Future<List<Asset>> _pickImages(int count, List<Asset> selectedAssets, String title) => MultiImagePicker.pickImages(
    maxImages: count,
    enableCamera: false,
    selectedAssets: selectedAssets,
    cupertinoOptions: CupertinoOptions(
      backgroundColor: "#D3D3D3",
    ),
    materialOptions: MaterialOptions(
      actionBarColor: "#808080",
      statusBarColor: "#808080",
      lightStatusBar: true,
      actionBarTitle: title
    )
  );
  
  static void _removeDeselectedImages(List<Asset> resultList, List<Asset> selectedAssets, List<String> currentImages) {
    for(int i=selectedAssets.length-1; i >= 0; i--){
      if(!resultList.any((Asset result) => result.identifier==selectedAssets[i].identifier)){
        selectedAssets.removeAt(i);
        currentImages.removeAt(i);
      }
    }
  }

  static Future<List<String>> _saveImages(String dirPath, List<Asset> resultList, List<Asset> selectedAssets) async {
    List<String> images= [];
    for(Asset result in resultList){
      String nextImage = await _saveImage(dirPath, result, selectedAssets);
      if(nextImage!=null){
        images.add(nextImage);
      }
    }
    return images;
  }

  static String get timestamp => DateTime.now().millisecondsSinceEpoch.toString();

  static Future<String> _saveImage(String dirPath, Asset result, List<Asset> selectedAssets) async {
    if(!selectedAssets.any((Asset image) => result.identifier==image.identifier)){
      selectedAssets.add(result);
      Offset coords = _getNewCoords(result, 1208*2);
      ByteData imageData = await result.requestThumbnail(coords.dx.toInt(),coords.dy.toInt());
      // ByteData imageData = await result.requestOriginal();
      print('size: ${imageData.lengthInBytes}');
      if(imageData != null){
        String filename = '$dirPath/$timestamp.jpg';
        File filePath = File(filename);
        await filePath.writeAsBytes(imageData.buffer.asInt8List());
        return filename;
      }
    }
    return null;
  }

  static Offset _getNewCoords(Asset result, int newSize){
    int height = result.originalHeight;
    int width = result.originalWidth;
    int maxSide = max(height, width);
    if(maxSide > newSize){
      print('originalHeight:${result.originalHeight}, originalWidth:${result.originalWidth}');
      double newHeight =newSize*(height/maxSide);
      double newWidth =newSize*(width/maxSide);
      print('newHeight:$newHeight, newWidth:$newWidth');
      return Offset(newWidth, newHeight);
    }else{
      return Offset(width.toDouble(), height.toDouble());
    }
  }
}