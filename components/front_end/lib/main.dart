// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:helpers/helpers.dart';
import 'package:blocs/blocs.dart';
import 'package:middleware/middleware.dart';
import 'package:front_end/dependency_injection.dart';
import 'package:front_end/providers.dart';
import 'package:front_end/screens.dart';
import 'package:front_end/localization.dart';

void main({
  @required OutfitRepository outfitRepository,
  @required UserRepository userRepository,
}) {
  runApp(Injector(
    outfitRepository: outfitRepository,
    child: UserBlocProvider(
      bloc:  UserBloc(userRepository),
      child: OutfitBlocProvider(
        bloc:  OutfitBloc(outfitRepository),
        child:MaterialApp(
          title: BlocLocalizations().appTitle,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColorBrightness: Brightness.light,
            primarySwatch: Colors.grey,
          ),
          home: LoadingScreen(),
        ),
      ),
    ),
  ));
}
