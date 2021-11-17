import 'package:meta/meta.dart';
import '../../../middleware/middleware.dart';

class LogInForm {
  LogInFields fields;
  LogInMethod method;

  LogInForm({
    @required this.fields,
    @required this.method
  });
}

class LogInFields{
  String email;
  String password;
  String passwordConfirmation;
  String facebookToken;
  String twitterToken;
  String twitterTokenSecret;
  String googleIdToken;
  String googleAccessToken;

  LogInFields({
    this.email,
    this.password,
    this.passwordConfirmation,
    this.facebookToken,
    this.twitterToken,
    this.twitterTokenSecret,
    this.googleIdToken,
    this.googleAccessToken,
  });
}