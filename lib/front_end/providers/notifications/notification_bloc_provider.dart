// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import '../../../../blocs/blocs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NotificationBlocProvider extends StatefulWidget {
  final Widget child;
  final NotificationBloc bloc;

  NotificationBlocProvider({Key key, @required this.child, @required this.bloc})
      : super(key: key);

  @override
  _NotificationBlocProviderState createState() => _NotificationBlocProviderState();

  static NotificationBloc of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<_NotificationBlocProvider>())
        .bloc;
  }
}

class _NotificationBlocProviderState extends State<NotificationBlocProvider> {
  @override
  Widget build(BuildContext context) {
    return _NotificationBlocProvider(bloc: widget.bloc, child: widget.child);
  }

  @override
  void dispose() {
    widget.bloc.dispose();
    super.dispose();
  }
}

class _NotificationBlocProvider extends InheritedWidget {
  final NotificationBloc bloc;

  _NotificationBlocProvider({
    Key key,
    @required this.bloc,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_NotificationBlocProvider old) => bloc != old.bloc;
}
