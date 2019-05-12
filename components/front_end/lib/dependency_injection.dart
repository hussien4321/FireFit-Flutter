// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

library dependency_injector;

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:middleware/middleware.dart';
import 'package:blocs/blocs.dart';

class Injector extends InheritedWidget {
  final OutfitRepository outfitRepository;

  Injector({
    Key key,
    @required this.outfitRepository,
    @required Widget child,
  }) : super(key: key, child: child);

  static Injector of(BuildContext context) =>
    context.inheritFromWidgetOfExactType(Injector);

  @override
  bool updateShouldNotify(Injector oldWidget) =>
    outfitRepository != oldWidget.outfitRepository;
}
