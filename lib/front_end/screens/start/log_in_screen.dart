import 'package:flutter/material.dart';
import '../../../../middleware/middleware.dart';
import 'package:validate/validate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../blocs/blocs.dart';
import '../../../../front_end/providers.dart';
import 'dart:async';
import 'package:flutter/gestures.dart';
import '../../../../helpers/helpers.dart';
import '../../../../front_end/helper_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:overlay_support/overlay_support.dart';

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

  bool hasReadDocuments = false;

  @override
  void initState() {
    super.initState();
    if (_giveDefaultLogIn) {
      emailController.text = 'hoherodu@freemailnow.net';
      passwordController.text = 'password2';
      confirmationController.text = 'password2';
    }
  }

  @override
  dispose() {
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
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 8.0),
              ),
              _emailField(),
              _passwordField(),
              widget.isRegistering
                  ? _passwordField(isConfirmation: true)
                  : _forgotPasswordPrompt(),
              widget.isRegistering ? _finalConfirmationPage() : Container()
            ],
          ),
        ),
      ),
    );
  }

  _initBlocs() {
    if (_userBloc == null) {
      _userBloc = UserBlocProvider.of(context);
      _subscriptions = <StreamSubscription<dynamic>>[
        _logInStatusListener(),
        _loadingListener(),
        _successListener(),
        _errorListener(),
      ];
    }
  }

  StreamSubscription _logInStatusListener() {
    return _userBloc.accountStatus.listen((accountStatus) async {
      if (accountStatus != null &&
          accountStatus != UserAccountStatus.LOGGED_OUT) {
        final events = AnalyticsEvents(context);
        String userId = await _userBloc.existingAuthId.first;
        events.setUserId(userId);
        if (accountStatus == UserAccountStatus.LOGGED_IN) {
          events.logIn();
        } else {
          events.signUp();
        }
        _closeLoadingDialog(isLoggedIn: true);
        CustomNavigator.goToPageAtRoot(
            context, RouteConverters.getFromAccountStatus(accountStatus));
      }
    });
  }

  StreamSubscription _loadingListener() {
    return _userBloc.isLoading.listen((loadingStatus) {
      if (loadingStatus && !isOverlayShowing && !loggedIn) {
        startLoading(
            widget.isRegistering ? "Creating account" : "Logging in", context);
        isOverlayShowing = true;
      }
    });
  }

  _closeLoadingDialog({bool isLoggedIn = false}) {
    if (isOverlayShowing) {
      isOverlayShowing = false;
      loggedIn = isLoggedIn;
      stopLoading(context);
    }
  }

  StreamSubscription _errorListener() {
    return _userBloc.hasError.listen((message) {
      _closeLoadingDialog();
      _errorDialog(message);
    });
  }

  _errorDialog(String message) {
    ErrorDialog.launch(
      context,
      message: message,
    );
  }

  StreamSubscription _successListener() {
    return _userBloc.isSuccessful.listen((successStatus) {
      if (!successStatus) {
        _closeLoadingDialog();
      }
    });
  }

  _logIn() {
    if (_formKey.currentState.validate()) {
      final logInForm = LogInForm(
          fields: LogInFields(
            email: emailController.text,
            password: passwordController.text,
            passwordConfirmation: confirmationController.text,
          ),
          method: LogInMethod.email);
      if (widget.isRegistering) {
        if (hasReadDocuments) {
          _userBloc.register.add(logInForm);
        } else {
          toast("Please confirm you have read the documents below");
          FocusScope.of(context).unfocus();
        }
      } else {
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
          labelStyle:
              Theme.of(context).textTheme.subtitle2.apply(color: Colors.blue),
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
        controller:
            isConfirmation ? confirmationController : passwordController,
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.none,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: "${isConfirmation ? 'Confirm ' : ''}Password",
          labelStyle:
              Theme.of(context).textTheme.subtitle2.apply(color: Colors.blue),
          icon: Icon(
            FontAwesomeIcons.key,
            color: Colors.blue,
          ),
        ),
        onFieldSubmitted: (text) {
          if (hasConfirmationNext) {
            FocusScope.of(context).requestFocus(confirmationFocus);
          } else {
            _logIn();
          }
        },
        textInputAction:
            hasConfirmationNext ? TextInputAction.next : TextInputAction.done,
        validator: (String value) {
          if (isConfirmation) {
            if (confirmationController.text != passwordController.text) {
              return 'Passwords do not match';
            }
          } else {
            if (value.length < 8) {
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
    ForgotPasswordDialog.launch(
      context,
      email: emailController.text,
      onSubmitEmail: (email) => _userBloc.resetPassword.add(email),
    );
  }

  Widget _finalConfirmationPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: <Widget>[
          Divider(
            color: Colors.black54,
          ),
          _legalDocuments(),
          Padding(
            padding: EdgeInsets.only(bottom: 16),
          ),
          _legalCheckbox(),
        ],
      ),
    );
  }

  Widget _legalDocuments() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Flexible(
              child: RichText(
            text: TextSpan(
                style: Theme.of(context).textTheme.subtitle1,
                children: [
                  TextSpan(
                      text:
                          'In order to use FireFit, you must read and agree to the following:\n\n'),
                  TextSpan(
                    text: 'Privacy Policy\n\n',
                    style: TextStyle(
                      inherit: true,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _openURL(AppConfig.PRIVACY_POLICY_URL),
                  ),
                  TextSpan(
                    text: 'Terms & Conditions\n\n',
                    style: TextStyle(
                      inherit: true,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap =
                          () => _openURL(AppConfig.TERMS_AND_CONDITIONS_URL),
                  ),
                  TextSpan(
                    text: 'End user license agreement (EULA)',
                    style: TextStyle(
                      inherit: true,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _openURL(AppConfig.EULA_URL),
                  ),
                  TextSpan(
                      text:
                          "\nThis means I will not post any objectionable content or engage in any abusive behavior",
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2
                          .copyWith(color: Colors.grey)),
                ]),
          )),
        ]);
  }

  _legalCheckbox() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            'Click the checkbox to confirm you have read and understood the above',
            textAlign: TextAlign.center,
          ),
        ),
        Checkbox(
          value: hasReadDocuments,
          onChanged: (newVal) {
            setState(() => hasReadDocuments = newVal);
          },
          activeColor: Colors.blue,
        ),
      ],
    );
  }

  _openURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      toast("Failed to open! - please visit FireFit.com to view documents");
    }
  }
}
