import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_functions/cloud_functions.dart';

bool catchExceptionWithBool(dynamic exception, FirebaseAnalytics analytics) {
  catchException(exception, analytics);
  return false;
}

int catchExceptionWithInt(dynamic exception, FirebaseAnalytics analytics) {
  catchException(exception, analytics);
  return -1;
}

catchException(dynamic exception, FirebaseAnalytics analytics) {
  if(exception != null && exception is CloudFunctionsException){
    print('code:${exception.code}, message:${exception.message}, details:${exception.details}');
    analytics.logEvent(
      name: "crash_firebase",
      parameters: {
        "code" : exception?.code,
        "message": exception?.message,
      }
    );
  }
}