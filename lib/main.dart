// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'front_end/main.dart' as app;
import 'package:firebase_auth/firebase_auth.dart';
import 'blocs/blocs.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'repository_impl/repository_impl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlbrite/sqlbrite.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'front_end/providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.stack != null) {
      crashlytics.recordFlutterError(details);
    }
  };

  RemoteConfigHelpers.loadDefaults();

  Preferences preferences = new Preferences();

  FirebaseAdMob.instance.initialize(appId: AdmobTools.appId);
  FirebaseFunctions functions = FirebaseFunctions.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseImageUploader imageUploader = FirebaseImageUploader(storage: storage);
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  Database db = await LocalDatabase().db;
  BriteDatabase streamDatabase = BriteDatabase(db);

  CachedUserRepository userCache =
      CachedUserRepository(streamDatabase: streamDatabase);
  CachedOutfitRepository outfitCache = CachedOutfitRepository(
    streamDatabase: streamDatabase,
    userCache: userCache,
  );
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  FirebaseOutfitRepository outfitRepository = FirebaseOutfitRepository(
    cloudFunctions: functions,
    imageUploader: imageUploader,
    cache: outfitCache,
    analytics: analytics,
  );
  FirebaseUserRepository userRepository = FirebaseUserRepository(
    auth: auth,
    outfitCache: outfitCache,
    userCache: userCache,
    cloudFunctions: functions,
    imageUploader: imageUploader,
    messaging: messaging,
    analytics: analytics,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  messaging.requestPermission();

  app.main(
    outfitRepository: outfitRepository,
    userRepository: userRepository,
    messaging: messaging,
    analytics: analytics,
    preferences: preferences,
  );
}
