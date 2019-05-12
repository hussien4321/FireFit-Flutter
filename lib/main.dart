// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:front_end/main.dart' as app;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:repository_impl/repository_impl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:streamqflite/streamqflite.dart';

void main() async {
  
  CloudFunctions functions = CloudFunctions.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseImageUploader imageUploader = FirebaseImageUploader(
    storage: storage
  );
  FirebaseAuth auth = FirebaseAuth.instance;
  Database db = await LocalDatabase().db;
  // StreamDatabase streamDatabase = StreamDatabase(db);

  app.main(
    outfitRepository: FirebaseOutfitRepository(
      cloudFunctions: functions,
      imageUploader: imageUploader,
      // cache: CachedOutfitRepository(
      //   streamDatabase: streamDatabase,
      // ),
    ),
  );
}
