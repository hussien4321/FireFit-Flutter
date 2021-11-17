// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import '../../../../blocs/blocs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class OutfitBlocProvider extends StatefulWidget {
  final Widget child;
  final OutfitBloc bloc;

  OutfitBlocProvider({Key key, @required this.child, @required this.bloc})
      : super(key: key);

  @override
  _OutfitBlocProviderState createState() => _OutfitBlocProviderState();

  static OutfitBloc of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<_OutfitBlocProvider>())
        .bloc;
  }
}

class _OutfitBlocProviderState extends State<OutfitBlocProvider> {
  @override
  Widget build(BuildContext context) {
    return _OutfitBlocProvider(bloc: widget.bloc, child: widget.child);
  }

  @override
  void dispose() {
    widget.bloc.dispose();
    super.dispose();
  }
}

class _OutfitBlocProvider extends InheritedWidget {
  final OutfitBloc bloc;

  _OutfitBlocProvider({
    Key key,
    @required this.bloc,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_OutfitBlocProvider old) => bloc != old.bloc;
}
