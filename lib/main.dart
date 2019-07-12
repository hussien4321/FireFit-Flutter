// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:front_end/main.dart' as app;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:front_end/services.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:repository_impl/repository_impl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:streamqflite/streamqflite.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

void main() async {
  
  new Preferences();
  CloudFunctions functions = CloudFunctions.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseImageUploader imageUploader = FirebaseImageUploader(
    storage: storage
  );
  FirebaseMessaging messaging =FirebaseMessaging();
  FirebaseAuth auth = FirebaseAuth.instance;
  Database db = await LocalDatabase().db;
  StreamDatabase streamDatabase = StreamDatabase(db);
  CachedUserRepository userCache = CachedUserRepository(streamDatabase: streamDatabase);
  CachedOutfitRepository outfitCache = CachedOutfitRepository(
    streamDatabase: streamDatabase,
    userCache: userCache,
  );
  FirebaseOutfitRepository outfitRepository = FirebaseOutfitRepository(
    cloudFunctions: functions,
    imageUploader: imageUploader,
    cache: outfitCache,
  );
  FirebaseUserRepository userRepository= FirebaseUserRepository(
    auth: auth,
    outfitCache: outfitCache,
    userCache: userCache,
    cloudFunctions: functions,
    imageUploader: imageUploader,
    messaging: messaging,
  );
  FirebaseAnalytics analytics = FirebaseAnalytics();

  app.main(
    outfitRepository: outfitRepository,
    userRepository: userRepository,
    messaging: messaging,
    analytics: analytics
  );
}
