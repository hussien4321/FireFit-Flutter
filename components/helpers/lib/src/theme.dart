// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';

class ArchSampleTheme {
  static get theme {
    final originalTextTheme = ThemeData.dark().textTheme;
    final originalBody1 = originalTextTheme.body1;
    final buttonTheme = ThemeData.dark().buttonTheme;

    return ThemeData.dark().copyWith(
        buttonTheme: buttonTheme.copyWith(
          buttonColor: Colors.orangeAccent[400],
          textTheme: ButtonTextTheme.primary
        ),
        primaryColor: Colors.grey[800],
        accentColor: Colors.orangeAccent,
        buttonColor: Colors.grey[800],
        textSelectionColor: Colors.orangeAccent,
        backgroundColor: Colors.grey[800],
        toggleableActiveColor: Colors.orangeAccent,
        textTheme: originalTextTheme.copyWith(
            body1:
                originalBody1.copyWith(decorationColor: Colors.transparent)));
  }
}
