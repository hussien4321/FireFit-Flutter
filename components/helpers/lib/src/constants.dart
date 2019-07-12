class AppConfig {
  static final int NUMBER_OF_POLL_ATTEMPTS = 20;
  static final int DURATION_PER_POLL_ATTEMPT = 1500;  

  static final List<String> MAIN_PAGES = [
    "INSPIRATION",
    "FASHION CIRCLE",
    "WARDROBE",
    "LOOKBOOKS",
  ];
  static final List<String> MAIN_PAGES_PATHS = [
    "/explore",
    "/fashion_circle",
    "/wardrobe",
    "/lookbooks",
  ];
}
