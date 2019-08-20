import 'package:flutter/material.dart';
import 'package:middleware/middleware.dart';
import 'package:validate/validate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:blocs/blocs.dart';
import 'package:front_end/providers.dart';
import 'dart:async';
import 'package:front_end/helper_widgets.dart';

class LogInScreen extends StatefulWidget {

  final bool isRegistering;

  LogInScreen({this.isRegistering = false});

  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> with LoadingAndErrorDialogs {
  
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmationController = TextEditingController();

  FocusNode passwordFocus = FocusNode();
  FocusNode confirmationFocus = FocusNode();
  
  UserBloc _userBloc;
  List<StreamSubscription<dynamic>> _subscriptions;

  bool isOverlayShowing = false;
  bool loggedIn = false;

  bool _giveDefaultLogIn = false;

  @override
  void initState() {
    super.initState();
    if(_giveDefaultLogIn){
      emailController.text ='hoherodu@freemailnow.net';
      passwordController.text = 'password2';
      confirmationController.text ='password2';
    }
  }

  @override
  dispose(){
    _subscriptions?.forEach((subscription) => subscription.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return CustomScaffold(
      title: widget.isRegistering ? 'Create account' : 'Log in',
      actions: <Widget>[
        IconButton(
          icon: Icon(FontAwesomeIcons.signInAlt),
          onPressed: _logIn,
        )
      ],
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Padding(padding:EdgeInsets.only(bottom: 8.0),),
            _emailField(),
            _passwordField(),
            widget.isRegistering ? _passwordField(isConfirmation: true) : _forgotPasswordPrompt(),
          ],
        ),
      ),
    );
  }

  _initBlocs(){
    if(_userBloc == null){
      _userBloc = UserBlocProvider.of(context);
      _subscriptions = <StreamSubscription<dynamic>>[
        _logInStatusListener(),
        _loadingListener(),
        _successListener(),
      ];
    }
  }

  
  StreamSubscription _logInStatusListener(){
    return _userBloc.accountStatus.listen((accountStatus) async {
      if(accountStatus!=null && accountStatus !=UserAccountStatus.LOGGED_OUT) {
        final events = AnalyticsEvents(context);
        String userId = await _userBloc.existingAuthId.first;
        events.setUserId(userId);
        if(accountStatus == UserAccountStatus.LOGGED_IN){
          events.logIn();
        }else{
          events.signUp();
        }
        _closeLoadingDialog(isLoggedIn: true);
        CustomNavigator.goToPageAtRoot(context, RouteConverters.getFromAccountStatus(accountStatus));
      }
    });
  }


  StreamSubscription _loadingListener(){
    return _userBloc.isLoading.listen((loadingStatus) {
      if(loadingStatus && !isOverlayShowing && !loggedIn){
        startLoading(widget.isRegistering ? "Creating account" : "Logging in", context);
        isOverlayShowing = true;
      }
    });
  }

  _closeLoadingDialog({bool isLoggedIn = false}){
    if(isOverlayShowing){
      isOverlayShowing = false;
      loggedIn = isLoggedIn;
      stopLoading(context);
    }
  }


  StreamSubscription _successListener(){
    return _userBloc.isSuccessful.listen((successStatus) {
      if(!successStatus){
        _closeLoadingDialog();
      }
    });
  }

  _logIn(){
    if(_formKey.currentState.validate()){
      final logInForm = LogInForm(
        fields: LogInFields(
          email: emailController.text,
          password: passwordController.text,
          passwordConfirmation: confirmationController.text,
        ), 
        method: LogInMethod.email
      );
      if(widget.isRegistering){
        _userBloc.register.add(logInForm);
      }else{
        _userBloc.logIn.add(logInForm);
      }
    }
  }
  Widget _emailField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: TextFormField(
        autofocus: true,
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(  
          border: InputBorder.none,
          labelText: 'Email Address',
          labelStyle: Theme.of(context).textTheme.subtitle.apply(color: Colors.blue),
          icon: Icon(
            Icons.email,
            color: Colors.blue,
          ),
        ),
        onFieldSubmitted: (text) {
          FocusScope.of(context).requestFocus(passwordFocus);
        },
        textInputAction: TextInputAction.next,
        validator: (String value) {
          try {
            Validate.isEmail(value);
          } catch (e) {
            return 'Invalid E-mail address.';
          }
          return null;
        },
      ),
    );
  }
  Widget _passwordField({bool isConfirmation = false}) {
    bool hasConfirmationNext = widget.isRegistering && !isConfirmation;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: TextFormField(
        obscureText: true,
        focusNode: isConfirmation ? confirmationFocus : passwordFocus,
        controller: isConfirmation ? confirmationController : passwordController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: "${isConfirmation ? 'Confirm ' :  '' }Password",
          labelStyle: Theme.of(context).textTheme.subtitle.apply(color: Colors.blue),
          icon: Icon(
            FontAwesomeIcons.key,
            color: Colors.blue,
          ),
        ),
        onFieldSubmitted: (text) {
          if(hasConfirmationNext){
            FocusScope.of(context).requestFocus(confirmationFocus);
          }else{
            _logIn();
          }
        },
        textInputAction: hasConfirmationNext ? TextInputAction.next : TextInputAction.done,
        validator: (String value) {
          if(isConfirmation){
            if(confirmationController.text != passwordController.text){
              return 'Passwords do not match';
            }
          }else{
            if(value.length < 8){
              return 'Must be at least 8 characters';
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _forgotPasswordPrompt() {
    return Padding(
      padding: EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          InkWell(
            onTap: _openResetPasswordDialog,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Forgot Password?',
                style: Theme.of(context).textTheme.button.copyWith(
                  color: Colors.deepOrange,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
  _openResetPasswordDialog() {
    ForgotPasswordDialog.launch(context,
      email: emailController.text,
      onSubmitEmail: (email) => _userBloc.resetPassword.add(email),
    );
  }
}