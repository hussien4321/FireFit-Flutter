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

  bool _giveDefaultLogIn = true;

  @override
  void initState() {
    super.initState();
    if(_giveDefaultLogIn){
      emailController.text ='xuri@mail-click.net';
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
            widget.isRegistering ? _passwordField(isConfirmation: true) : Container(),
          ],
        ),
      ),
    );
  }

  _initBlocs(){
    if(_userBloc == null){
      _userBloc = UserBlocProvider.of(context);
      _subscriptions = <StreamSubscription<dynamic>>[
        _loadingListener(),
        _successListener(),
        _errorListener(),
      ];
    }
  }

  StreamSubscription _loadingListener(){
    return _userBloc.isLoading.listen((loadingStatus) {
      if(loadingStatus && !isOverlayShowing){
        startLoading(widget.isRegistering ? "Creating account" : "Logging in", context);
        isOverlayShowing = true;
      }
      if(!loadingStatus && isOverlayShowing){
        isOverlayShowing = false;
        stopLoading(context);
      }
    });
  }


  StreamSubscription _successListener(){
    return _userBloc.isSuccessful.listen((successStatus) {
      if(successStatus){
        Navigator.pop(context);
      }
    });
  }

  StreamSubscription _errorListener(){
    return _userBloc.hasError.listen((errorMessage) {
      displayError(errorMessage, context);
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
}