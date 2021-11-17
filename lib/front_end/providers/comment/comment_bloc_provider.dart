// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import '../../../../blocs/blocs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CommentBlocProvider extends StatefulWidget {
  final Widget child;
  final CommentBloc bloc;

  CommentBlocProvider({Key key, @required this.child, @required this.bloc})
      : super(key: key);

  @override
  _CommentBlocProviderState createState() => _CommentBlocProviderState();

  static CommentBloc of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<_CommentBlocProvider>())
        .bloc;
  }
}

class _CommentBlocProviderState extends State<CommentBlocProvider> {
  @override
  Widget build(BuildContext context) {
    return _CommentBlocProvider(bloc: widget.bloc, child: widget.child);
  }

  @override
  void dispose() {
    widget.bloc.dispose();
    super.dispose();
  }
}

class _CommentBlocProvider extends InheritedWidget {
  final CommentBloc bloc;

  _CommentBlocProvider({
    Key key,
    @required this.bloc,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_CommentBlocProvider old) => bloc != old.bloc;
}
