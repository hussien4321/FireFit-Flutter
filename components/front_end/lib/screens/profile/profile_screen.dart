import 'package:flutter/material.dart';
import 'package:middleware/middleware.dart';
import 'package:blocs/blocs.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:front_end/providers.dart';
import 'package:front_end/screens.dart';
import 'package:front_end/services.dart';


enum UserOption { EDIT, REPORT }

class ProfileScreen extends StatefulWidget {
  final String userId;
  final String heroTag;
  final int pagesSinceOutfitScreen;
  final int pagesSinceProfileScreen;

  ProfileScreen({
    this.userId, 
    this.heroTag,
    this.pagesSinceOutfitScreen = 0,
    this.pagesSinceProfileScreen = 0,
});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  
  UserBloc _userBloc;
  OutfitBloc _outfitBloc;

  ScrollController _controller;

  FollowUser followUser =FollowUser();
  
  String currentUserId;

  final double splashSize = 200;
  final double profilePicSize = 100; 
  Outfit lastOutfit;

  bool isSortingByTop = false;
  Preferences preferences = Preferences();

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
  }
  _scrollListener() {
    if (_controller.offset >= (_controller.position.maxScrollExtent-100) && !_controller.position.outOfRange) {
      _outfitBloc.loadUserOutfits.add(
        LoadOutfits(
          userId: widget.userId,
          startAfterOutfit: lastOutfit,
          sortByTop: isSortingByTop,
        )
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return Scaffold(
      body: StreamBuilder<bool>(
        stream: _userBloc.isLoading,
        initialData: false,
        builder: (ctx, loadingSnap){
          return StreamBuilder<bool>(
            stream: _outfitBloc.isLoading,
            initialData: false,
            builder: (ctx, loadingOutfitsSnap) => StreamBuilder<User>(
              stream: _userBloc.selectedUser,
              builder: (ctx, snap) {
                if(loadingSnap.data || !snap.hasData){
                  return Center(child: CircularProgressIndicator(),);
                }
                if(followUser.followed == null){
                  AnalyticsEvents(context).profileViewed(snap.data);
                }
                followUser.followed = snap.data;
                return _profileScaffold(snap.data, loadingOutfitsSnap.data);
              },
            ),
          );
        }
      ),
    );
  }
  
  _initBlocs() async {
    if(_userBloc == null){
      _userBloc = UserBlocProvider.of(context);
      _outfitBloc = OutfitBlocProvider.of(context);
      _userBloc.selectUser.add(widget.userId);
      currentUserId = await _userBloc.existingAuthId.first;
      await _loadFiltersFromPreferences();
      _outfitBloc.loadUserOutfits.add(
        LoadOutfits(
          userId: widget.userId,
          sortByTop: isSortingByTop,
        )
      );
      followUser.followerUserId = currentUserId;
    }
  }

  _loadFiltersFromPreferences() async {
    final newSortByTop = await preferences.getPreference(Preferences.SELECTED_USER_OUTFITS_SORT_BY_TOP);
    setState(() {
      isSortingByTop = newSortByTop;
    });
  }

  Widget _profileScaffold(User user, bool isLoadingOutfits){
    return CustomScaffold(
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.black,
        ),
        onPressed: Navigator.of(context).pop,
      ),
      title: isCurrentUser ? "My Profile" :
        "${user.name}'s Profile",
      actions: <Widget>[
        _loadUserOptions(user),
      ],
      body: Column(
        children: <Widget>[
          Expanded(
            child: PullToRefreshOverlay(
              matchSize: false,
              onRefresh: () async {
                _userBloc.selectUser.add(widget.userId);
                _outfitBloc.loadUserOutfits.add(
                  LoadOutfits(
                    userId: widget.userId,
                    forceLoad: true,
                    sortByTop: isSortingByTop,
                  )
                );
              },
              child: ListView(
                controller: _controller,
                children: <Widget>[
                  _biometricInfo(user),
                  _spaceSeparator(),
                  _overallStatistics(user),
                  _spaceSeparator(),
                  _buildOutfitDescription(user),
                  _spaceSeparator(),
                  _outfitsOverview(user, isLoadingOutfits),
                ],
              ),
            ),
          ),
          isCurrentUser ? Container() : _buildInteractButton(user),
        ],
      ),
    );
  }

  bool get isCurrentUser => currentUserId == widget.userId;
  
  Widget _loadUserOptions(User user){
    List<UserOption> availableOptions = UserOption.values.where((option) => _canShowOption(option)).toList();
    return availableOptions.isEmpty ? Container() : PopupMenuButton<UserOption>(
      onSelected: (option) => _optionAction(option, user),
      itemBuilder: (BuildContext context) {
        return availableOptions.map((UserOption option) {
          return PopupMenuItem<UserOption>(
            value: option,
            child: Text(_optionToString(option)),
          );
        }).toList();
      },
    );
  }

  String _optionToString(UserOption option){
    switch (option) {
      case UserOption.EDIT:
        return 'Edit';
      case UserOption.REPORT:
        return 'Report';
      default:
        return null;
    }
  }

  bool _canShowOption(UserOption option){
    switch (option) {
      case UserOption.EDIT:
        return isCurrentUser;
      case UserOption.REPORT:
        return !isCurrentUser;
      default:
        return null;
    }
  }

  _optionAction(UserOption option, User user){
    switch (option) {
      case UserOption.EDIT:
        _editUser(user);
        break;
      case UserOption.REPORT:
        break;
      default:
        return null;
    }
  }


  _editUser(User user) {
    CustomNavigator.goToEditUserScreen(context, user:user);
  }


  Widget _spaceSeparator(){
    return Padding(
      padding: EdgeInsets.only(bottom: 24.0),
    );
  }

  Widget _closeButtonStack({Widget child}){
    return Stack(
      children: <Widget>[
        child,
        Positioned(
          top: 4,
          left: 4,
          child: IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.black,
            ),
            onPressed: Navigator.of(context).pop,
          ),
        )
      ],
    );
  }
  Widget _biometricInfo(User user) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _profilePic(user),
          _userInfo(user),
        ],
      ),
    );
  }

  Widget _profilePic(User user){
    String heroTag = widget.heroTag == null ? 'null' : widget.heroTag;
    return Center(
      child: Hero(
        tag: widget.heroTag == null ? 'null' : widget.heroTag,
        child: Container(
            margin: EdgeInsets.all(8.0),
            width: profilePicSize,
            height: profilePicSize,
            child: ImagePreview(
              title: 'Profile Picture',
              imageUrl: user.profilePicUrl,
              heroTag: heroTag,
            ),
          ),
      ), 
    );
  }

  Widget _userInfo(User user){
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            CountrySticker(countryCode: user.countryCode),
            Expanded(
              child: Text(
                user.name,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 1.2
                ),
                textAlign: TextAlign.center,
              ),
            ),
            DemographicSticker(user),
          ],
        ),
        Text(
          '@'+user.username,
          style: Theme.of(context).textTheme.caption,
        ),
      ],
    );
  }


  Widget _overallStatistics(User user){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _buildStatisticTab(
          count: user.numberOfFollowers, 
          name: 'Follower${user.numberOfFollowers==1?'':'s'}',
          onTap: () => _showFollowers(user.userId),
          isFollowersTab: true,
        ),
        _buildStatisticTab(
          count: user.numberOfFollowing, 
          name: 'Following',
          onTap: () => _showFollowing(user.userId),
        ),
        _buildStatisticTab(
          count: user.numberOfOutfits, 
          name: 'Outfit${user.numberOfOutfits==1?'':'s'}'
        ),
        _buildStatisticTab(
          count: user.numberOfFlames, 
          name: 'Flame${user.numberOfFlames==1?'':'s'}', 
          isEnd: true
        ),
      ],
    );
  }
  Widget _buildStatisticTab({int count, String name, VoidCallback onTap, bool isFollowersTab = false, bool isEnd = false}){
    return Expanded(
      child: Material(
        shape: CircleBorder(),
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: isEnd ? null :BoxDecoration(
              border: BorderDirectional(
                end: BorderSide(
                  color: Colors.grey[300],
                  width: 0.5
                )
              )
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('$count', style: Theme.of(context).textTheme.title),
                Text(name, style: Theme.of(context).textTheme.subhead),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _showFollowing(String userId){
    CustomNavigator.goToFollowUsersScreen(context,
      selectedUserId: userId,
      isFollowers: false,
      pagesSinceOutfitScreen: widget.pagesSinceOutfitScreen,
      pagesSinceProfileScreen: widget.pagesSinceProfileScreen+1,
    );
  }
  _showFollowers(String userId){
    CustomNavigator.goToFollowUsersScreen(context,
      selectedUserId: userId,
      isFollowers: true,
      pagesSinceOutfitScreen: widget.pagesSinceOutfitScreen,
      pagesSinceProfileScreen: widget.pagesSinceProfileScreen+1,
    );
  }

  Widget _buildOutfitDescription(User user) {
    if(user.bio == null){
      return Center(
        child: Text(
          "No bio has been added",
          style: TextStyle(
            color: Colors.grey,
            fontStyle: FontStyle.italic
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _sectionHeader("User Bio"),
          Text(
            user.bio,
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String header) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: BorderDirectional(
          bottom: BorderSide(
            color: Colors.grey[300],
            width: 0.5
          )
        )
      ),
      margin: const EdgeInsets.only(bottom:8.0),
      child: Text(
        header,
        style: Theme.of(context).textTheme.subhead.apply(fontWeightDelta: 3)
      ),
    );
  }

  Widget _outfitsOverview(User user, bool isLoadingOutfits){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _sectionHeader("Outfits"),
              ),
              _sortingButton(user),
            ],
          ),
          _outfitsGrid(isLoadingOutfits),
        ],
      ),
    );
  }

  Widget _sortingButton(User user){
    bool enabled = user != null && user.numberOfOutfits > 0;
    return FlatButton(
      child: Row(
        children: <Widget>[
          Text(
            isSortingByTop ? 'Top rated' : 'Last Uploaded',
            style: TextStyle(
              inherit: true,
              color: enabled ? Colors.blue : Colors.grey,
            ),
          ),
          Icon(
            Icons.trending_up,
            color: enabled ? Colors.blue : Colors.grey,
          ),
        ],
      ),
      onPressed: enabled ? _sortList : null,
    );
  }

  _sortList() {
    setState(() {
      isSortingByTop = !isSortingByTop;
    });
    preferences.updatePreference(Preferences.WARDROBE_SORT_BY_TOP, isSortingByTop);
    _outfitBloc.loadUserOutfits.add(LoadOutfits(
      userId: widget.userId,
      sortByTop: isSortingByTop,
    ));
  }


  Widget _outfitsGrid(bool isLoading) {
    return StreamBuilder<List<Outfit>>(
      stream: _outfitBloc.selectedOutfits,
      initialData: [],
      builder: (ctx, outfitsSnap) {
        if(outfitsSnap.data != null && outfitsSnap.data.isNotEmpty){
          lastOutfit=outfitsSnap.data.last;
        }
        List<Outfit> outfits = outfitsSnap.data;
        if(outfits.isNotEmpty){
          outfits = sortOutfits(outfits, isSortingByTop);
        }
        return OutfitsGrid(
          emptyText: 'This user has no outfits, follow them to get notified when they upload one!',
          isLoading: isLoading,
          outfits: outfits,
          hasFixedHeight: true,
          pagesSinceProfileScreen: widget.pagesSinceProfileScreen+1,
          pagesSinceOutfitScreen: widget.pagesSinceOutfitScreen,
        );
      }
    );
  }
  Widget _buildInteractButton(User user){
    return Container(
      decoration: BoxDecoration(
        border: BorderDirectional(
          start: BorderSide(
            color: Colors.grey.withOpacity(0.5),
            width: 0.5
          )
        ),
        color: user.isFollowing ? Colors.purpleAccent : Colors.grey,
      ),
      width: double.infinity,
      child: FlatButton(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                user.isFollowing ? 'Following' : 'Follow User',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            Icon(
              user.isFollowing ? Icons.check : Icons.person_add,
              color: Colors.white,
            ),
          ],
        ),
        onPressed: () => _userBloc.followUser.add(followUser),
      ),
    );
  }
}
