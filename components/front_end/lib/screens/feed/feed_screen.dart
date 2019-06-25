import 'package:flutter/material.dart';
import 'package:front_end/screens.dart';
import 'package:middleware/middleware.dart';
import 'package:blocs/blocs.dart';
import 'package:front_end/providers.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:async';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {


  OutfitBloc _outfitBloc;
  List<StreamSubscription<dynamic>> _subscriptions;

  String userId;
  LoadOutfits searchParams = LoadOutfits(); 

  bool isMyOutfits = true;

  RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh:false);
 }
 
  @override
  void dispose() {
    super.dispose();
    _subscriptions?.forEach((subscription) => subscription.cancel());
 }

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return _refresher(
      child: StreamBuilder<bool>(
        stream: _outfitBloc.isLoading,
        initialData: false,
        builder: (ctx, isLoadingSnap) {
          return StreamBuilder<List<Outfit>>(
            stream: _outfitBloc.feedOutfits,
            initialData: [],
            builder: (ctx, outfitsSnap) {
              return FeedOutfits(
                isLoading: isLoadingSnap.data,
                outfits: outfitsSnap.data,
              );
            },
          );
        },
      ),
    );
  }

  Widget _refresher({Widget child}){
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: false,
      header: WaterDropMaterialHeader(),
      controller: _refreshController,
      onRefresh: _forceRefresh,
      child: child
    );
  }
  
  _initBlocs() async {
    if(_outfitBloc==null){
      _outfitBloc = OutfitBlocProvider.of(context);
      userId = await UserBlocProvider.of(context).existingAuthId.first;
      searchParams.userId = userId;
      _outfitBloc.loadFeedOutfits.add(searchParams);
      _subscriptions = <StreamSubscription<dynamic>>[
        _loadingListener(),
      ];
    }
  }

  StreamSubscription _loadingListener(){
    return _outfitBloc.isLoading.listen((loadingStatus) {
      if(!loadingStatus){
        _refreshController.refreshCompleted();
      }
    });
  }

  _forceRefresh() {
    _outfitBloc.loadFeedOutfits.add(searchParams);
  }
}