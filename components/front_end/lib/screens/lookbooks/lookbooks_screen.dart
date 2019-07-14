import 'package:flutter/material.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:blocs/blocs.dart';
import 'package:front_end/providers.dart';
import 'package:front_end/services.dart';
import 'package:middleware/middleware.dart';
import 'package:helpers/helpers.dart';

class LookbooksScreen extends StatefulWidget {
  @override
  _LookbooksScreenState createState() => _LookbooksScreenState();
}

class _LookbooksScreenState extends State<LookbooksScreen> {

  OutfitBloc _outfitBloc;
  UserBloc _userBloc;

  String userId;
  User user;


  bool isSortBySize = false;
  Preferences preferences =Preferences();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  _loadPreferences() async {
    isSortBySize = await preferences.getPreference(Preferences.LOOKBOOKS_SORT_BY_SIZE);
  }
  
  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return UserStream(
      loadingStream: _userBloc.isLoading,
      userStream: _userBloc.currentUser,
      builder: (isLoadingUser, streamUser) => LookbooksStream(
        loadingStream: _outfitBloc.isLoading,
        lookbooksStream: _outfitBloc.lookbooks,
        builder: (isLoadingLookbooks, lookbooks) {
          bool isLoading = isLoadingUser || isLoadingLookbooks;
          user = streamUser;
          lookbooks = _sortList(lookbooks);
          return ListView(
            children: <Widget>[
              _lookbooksOverview(isLoading),
              _lookbooksManagementOptions(lookbooks.length),
              lookbooks.isEmpty ? _noLookbooksNotice() :_lookbooksList(lookbooks),
            ],
          );
        }
      ),
    );
  }

  _initBlocs() async {
    if(_outfitBloc ==null){
      _userBloc = UserBlocProvider.of(context);
      _outfitBloc =OutfitBlocProvider.of(context);
      userId = await _userBloc.existingAuthId.first; 
    }
  }
  _sortList(List<Lookbook> lookbooks){
    if(isSortBySize){
      lookbooks.sort((a, b) => -a.numberOfOutfits.compareTo(b.numberOfOutfits));
    }else{
      lookbooks.sort((a, b) => -a.createdAt.compareTo(b.createdAt));
    }
    return lookbooks;
  }

  Widget _lookbooksOverview(bool isLoading) {
    if(isLoading){
      return Container();
    }
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      width: double.infinity,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: Theme.of(context).textTheme.title.copyWith(
            fontWeight: FontWeight.normal
          ),
          children: [
            TextSpan(
              text: "You have "
            ),
            TextSpan(
              text: user.numberOfLookbooks.toString(),
              style: TextStyle(
                inherit: true,
                fontWeight: FontWeight.bold
              )
            ),
            TextSpan(
              text: " lookbook${user.numberOfLookbooks==1?'':'s'} with "
            ),
            TextSpan(
              text: user.numberOfLookbookOutfits.toString(),
              style: TextStyle(
                inherit: true,
                fontWeight: FontWeight.bold
              )
            ),
            TextSpan(
              text: " outfit${user.numberOfLookbookOutfits==1?'':'s'}"
            ),
          ]
        ),
      ),
    );
  }

  Widget _lookbooksManagementOptions(int size){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _newLookbookButton(size),
        _sortingButton(),
      ],
    );
  }

  Widget _newLookbookButton(int currentSize) {
    bool isFull = currentSize == AppConfig.MAX_NUM_LOOKBOOKS;
    Color color = isFull ? Colors.grey : Colors.blue;
    return FlatButton(
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Icon(
              isFull ? Icons.lock : Icons.add,
              color: color,
            ),
          ),
          Text(
            isFull ? 'Max size' : 'Create New',
            style: TextStyle(
              inherit: true,
              color: color,
            ),
          )
        ],
      ),
      onPressed: () => isFull ? _notifyMaxSize() : NewLookbookDialog.launch(context),
    );
  }
  
  _notifyMaxSize(){
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Max size reached'),
        content: Text(
          'Sorry but you seem to have reached the maximum number of lookbooks.\n\nPlease delete some of your unused lookbooks before you can create new ones.',
          style: Theme.of(context).textTheme.subhead,
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Got it',
              style: TextStyle(
                inherit: true,
                color: Colors.deepOrange,
              ),
            ),
            onPressed: Navigator.of(ctx).pop,
          )
        ],
      )
    );
  }
  

  Widget _sortingButton() {
    return FlatButton(
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              isSortBySize ? 'Size' : 'Last Created',
              style: TextStyle(
                inherit: true,
                color: Colors.grey,
              ),
            ),
          ),
          Icon(
            Icons.trending_up,
            color: Colors.grey,
          ),
        ],
      ),
      onPressed: _toggleSort,
    );
  }

  _toggleSort() {
    setState(() {
      isSortBySize=!isSortBySize;
    });
    preferences.updatePreference(Preferences.LOOKBOOKS_SORT_BY_SIZE, isSortBySize);
  }

  Widget _lookbooksList(List<Lookbook> lookbooks) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: GridView.builder(
        gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4
        ),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: lookbooks.length,
        itemBuilder: (ctx,i) => LookbookCard(lookbooks[i%lookbooks.length])
      ),
    );
  }

  
  Widget _noLookbooksNotice() {
    return Container(
      padding: EdgeInsets.only(top: 16, left: 16, right: 16),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'No lookbooks found',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Icon(
              FontAwesomeIcons.boxOpen,
              size: 64,
            ),
          ),
          Text(
            'You have not created any lookbooks yet, use lookbooks to bookmark your favourite outfits and group them into your own categories!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.subhead,
          ),
        ],
      ),
    );
  }

}

