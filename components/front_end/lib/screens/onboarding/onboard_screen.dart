import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:transformer_page_view/transformer_page_view.dart';
import 'onboard_pages/onboard_pages.dart';
import 'package:blocs/blocs.dart';
import 'dart:async';
import 'package:middleware/middleware.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:front_end/providers.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class OnboardScreen extends StatefulWidget {
  @override
  _OnboardScreenState createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> with SnackbarMessages, LoadingAndErrorDialogs {
  
  OnboardUser onboardUser = OnboardUser();
  IndexController _indexController = new IndexController();
  int currentIndex = 0;
  bool canGoToNextPage = true;

  bool isEmailVerified = false;
  String emailAddress = '';

  UserBloc userBloc;
  bool isLoading = true;

  bool isOverlayShowing = false;

  List<StreamSubscription<dynamic>> _subscriptions;
  
  bool loadingImages = false;

  Asset selectedAsset;

  String dirPath;

  @override
  void initState() {
    super.initState();
    _initTempGallery();    
  }

  _initTempGallery() async{ 
    Directory extDir = await getApplicationDocumentsDirectory();
    dirPath = '${extDir.path}/Pictures/temp';
    await Directory(dirPath).create(recursive: true);
  }

  @override
  dispose(){
    _subscriptions?.forEach((subscription) => subscription.cancel());
    Directory(dirPath).deleteSync(recursive: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return WillPopScope(
      onWillPop: _goToPreviousPage,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[400],
          automaticallyImplyLeading: false,
          title: Stack(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Opacity(
                    opacity: 0.0,
                    child: FlatButton(
                      child: Text(''),
                      onPressed: (){},
                    ),
                  ),
                  Container(
                    child: Text(
                      'Create account',
                      style: Theme.of(context).textTheme.title.apply(
                        color: Colors.white
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 0.0,
                    child: FlatButton(
                      child: Text(''),
                      onPressed: (){},
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FlatButton(
                    child: Text(
                      currentIndex == 0 ? 'Log out' : 'Back',
                      style: Theme.of(context).textTheme.button.apply(
                        color: currentIndex == 0 ? Colors.red[800] : Colors.white
                      ),
                    ),
                    onPressed: _goToPreviousPage,
                  ),
                  FlatButton(
                    child: Text(
                      isLoading ? 'Loading' : 
                      !canGoToNextPage ? 'Incomplete' : 
                      currentIndex == _onboardingPages.length - 1 ? 'Submit' : 'Next',
                      style: Theme.of(context).textTheme.button.apply(
                        color: !canGoToNextPage ? Colors.white54 : Colors.blue,
                        fontWeightDelta: 3,
                        fontSizeDelta: 2
                      ),
                    ),
                    onPressed: isLoading || !canGoToNextPage ? null : _goToNextPage
                  )
                ],
              ),
            ],
          ),
          titleSpacing: 0.0,
        ),
        body: Container(
          padding: EdgeInsets.only(left: 10.0, right: 10.0),
          child: Theme(
            data: ThemeData(
              accentColor: Colors.blue
            ),
            child: DefaultTextStyle(
              style: Theme.of(context).textTheme.subhead,
              child: TransformerPageView(
                onPageChanged: (index) {
                  setState(() {currentIndex = index;});
                },
                physics: NeverScrollableScrollPhysics(),
                loop: false,
                controller: _indexController,
                duration: Duration(seconds: 1),
                transformer: new FadeInAndSlidePageTransformer(),
                itemBuilder: (BuildContext context, int index) {
                  return _onboardingPages[index];
                },
                itemCount: _onboardingPages.length
              )
            ),
          ),
        ),
      )
    );
  }

  Future<bool> _goToPreviousPage() {
    if(currentIndex != 0){
      _goToPage(--currentIndex);
      return Future.value(false);
    }
    else{
      return showDialog(
        context: context,
        builder: (secondContext) => YesNoDialog(
          title: 'Log out',
          description: 'Are you sure you want to go back to the log in page?',
          yesText: 'Yes',
          noText: 'Cancel',
          onYes: () {
            userBloc.logOut.add(null);
          },
          onNo: () {
            Navigator.pop(context);
          },
        ),
      ) ?? false;
    }
  }

  _goToNextPage(){
    if(currentIndex != _onboardingPages.length-1){
      _goToPage(++currentIndex);
    }
    else{
      userBloc.onboard.add(onboardUser);
    }
  }

  _goToPage(int index){
    FocusScope.of(context).requestFocus(new FocusNode());
    _indexController.move(index);
    _updatePageCompletedStatus(index);
  }

  
  _initBlocs(){
    if(isLoading){
      userBloc = UserBlocProvider.of(context);
      _updateEmailVerificationStatus();
      _subscriptions = <StreamSubscription<dynamic>>[
        _listenForChangesToAuthStatus(),
        _listenForOnboardCompletion(),
      ];
    }
  }

  _updateEmailVerificationStatus() async {
    userBloc.refreshVerificationEmail.add(null);
    isEmailVerified = await userBloc.isEmailVerified.first;

    if(!isEmailVerified){
      await _loadEmailData();
    }

    if(mounted){
      setState(() {
      isLoading = false; 
      });
    }
  }

  _loadEmailData() async {
    String address = await userBloc.verificationEmail.first;
    setState(() {
      onboardUser.email = address;
      onboardUser.isEmailVerified = false;      
    });
    userBloc.resendVerificationEmail.add(null);
  }

  StreamSubscription _listenForChangesToAuthStatus(){
    return userBloc.accountStatus.listen((accountStatus) {
      if(accountStatus!=null && accountStatus !=UserAccountStatus.PENDING_ONBOARDING){
        Navigator.pushReplacementNamed(context, RouteConverters.getFromAccountStatus(accountStatus));
      }
    });
  }

  StreamSubscription _listenForOnboardCompletion(){
    return userBloc.isLoading.listen((loadingStatus) {
      if(currentIndex ==_onboardingPages.length-1){
        if(loadingStatus && !isOverlayShowing){
          startLoading('Creating account', context);
          isOverlayShowing=true;
        }
        if(!loadingStatus && isOverlayShowing){
          isOverlayShowing = false;
          stopLoading(context);
        }
      }
    });
  }

  List<Widget> get _onboardingPages => 
    <Widget>[          
      OnboardDetails(
        icon: FontAwesomeIcons.handPeace,
        title: "Let's get you set up",
        children: <Widget>[
          Text(
            "Before you can start discovering and sharing awesome outfits, we just need to some info about you!",
            style: Theme.of(context).textTheme.subhead,
          ),
        ],
      ),
    ]..addAll(
      isEmailVerified ? [] : [
        EmailVerificationPage(
          onboardUser: onboardUser,
          currentEmailVerificationStatus: userBloc.isEmailVerified,
          refreshVerificationEmail: () => userBloc.refreshVerificationEmail.add(null),
          resendVerificationEmail: () => userBloc.resendVerificationEmail.add(null),
          onSave: _onSave
        ),
      ] 
    )..addAll([
      UsernamePage(
        onboardUser:onboardUser,
        isUsernameTaken: userBloc.isUsernameTaken,
        checkUsername: userBloc.checkUsername.add,
        onSave: _onSave,
      ),
      ProfilePicPage(
        onboardUser:onboardUser,
        onSave: _onSave,
        dirPath:dirPath,
        selectedAsset: selectedAsset,
        onUpdateAsset: (asset) => selectedAsset=asset,
      ),
      BiometricsPage(
        onboardUser:onboardUser,
        onSave: _onSave,
      ),
      OnboardDetails(
        icon: FontAwesomeIcons.check,
        title: "Start ur fashion journey💃",
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10.0),
            child: Text(
              "Press the submit button above to begin sharing and talking fashion!",
              style: Theme.of(context).textTheme.subhead,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    ]);

  _onSave(OnboardUser newOnboardUser) async {
    Future.delayed(Duration.zero, () => setState(() { onboardUser = newOnboardUser; }));
    _updatePageCompletedStatus(currentIndex);
  }

  _updatePageCompletedStatus(int index){
    
    int nextIndex = 1;
    if(!isEmailVerified){
      nextIndex++;
    }
    if(index == 0){
      canGoToNextPage = true;
    } 
    else if(index == 1 && !isEmailVerified){
      canGoToNextPage = onboardUser.isEmailVerified != null && onboardUser.isEmailVerified;
    }
    else if(index == nextIndex){
      canGoToNextPage = onboardUser.isUsernameTaken != null && !onboardUser.isUsernameTaken && onboardUser.name != null && onboardUser.username != null && onboardUser.name.isNotEmpty && onboardUser.username.isNotEmpty;
    }
    else if(index == nextIndex+1){
      canGoToNextPage = onboardUser.profilePicUrl != null && onboardUser.profilePicUrl.isNotEmpty;
    }
    else if(index == nextIndex+2){
      canGoToNextPage = onboardUser.genderIsMale != null && onboardUser.dateOfBirth != null;
    }

    Future.delayed(Duration.zero, () => setState(() { canGoToNextPage = canGoToNextPage; }));
  }
  
}

