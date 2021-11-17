class AppConfig {
  static final String TWITTER_URL = "https://twitter.com/firefit_app";
  static final String PRIVACY_POLICY_URL =
      "https://skilful-tape-240120.firebaseapp.com/privacy-policy.html";
  static final String EULA_URL =
      "https://skilful-tape-240120.firebaseapp.com/eula.html";
  static final String TERMS_AND_CONDITIONS_URL =
      "https://skilful-tape-240120.firebaseapp.com/terms-and-conditions.html";
  static final String COPYRIGHTS_URL =
      "https://skilful-tape-240120.firebaseapp.com/copyrights.html";

  static final int NUMBER_OF_POLL_ATTEMPTS = 20;
  static final int DURATION_PER_POLL_ATTEMPT = 1500;

  static final List<String> MAIN_PAGES = [
    "Inspiration",
    "Fashion Circle",
    "My Wardrobe",
    "Lookbooks",
  ];
  static final List<String> MAIN_PAGES_PATHS = [
    "inspiration",
    "fashion_circle",
    "wardrobe",
    "lookbooks",
  ];
}
