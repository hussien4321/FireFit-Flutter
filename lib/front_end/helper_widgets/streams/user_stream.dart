import 'package:flutter/material.dart';
import '../../../../middleware/middleware.dart';
import 'dart:async';

typedef UserBuilder = Widget Function(bool isLoading, User user);

class UserStream extends StatelessWidget {
  
  final UserBuilder builder;
  final Stream<bool> loadingStream;
  final Stream<User> userStream;

  UserStream({
    @required this.builder,
    @required this.loadingStream,
    @required this.userStream,
  });
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: loadingStream,
      initialData: false,
      builder: (ctx, isLoadingSnap) {
        return StreamBuilder<User>(
          stream: userStream,
          builder: (ctx, userSnap) {
            bool hasUser = userSnap.hasData && userSnap.data!=null;
            bool isLoading=isLoadingSnap.data || !hasUser;
            return builder(isLoading, userSnap.data);
          }
        );
      }
    );
  }
}