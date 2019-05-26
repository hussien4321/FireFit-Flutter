class OnboardUser {
  
  String username;
  bool isUsernameTaken;
  String displayName;
  String profilePic;
  bool genderIsMale;
  DateTime birthday;
  bool wantedClothesGenderIsMale;
  String wantedClothesCategory;
  String tradeLocation;
  String tradeLocationCity;
  bool emailVerified;
  String emailAddress;

  OnboardUser({
    this.username,
    this.isUsernameTaken,
    this.displayName,
    this.profilePic,
    this.genderIsMale,
    this.birthday,
    this.wantedClothesGenderIsMale,
    this.wantedClothesCategory,
    this.tradeLocation,
    this.tradeLocationCity,
    this.emailAddress,
    this.emailVerified
  });

  bool isComplete() {
    return username != null && displayName != null && profilePic != null && tradeLocation != null && tradeLocationCity != null &&
    username.length > 0 && displayName.length > 0 && profilePic.length > 0  && tradeLocation.length > 0  && tradeLocationCity.length > 0 && 
    genderIsMale != null && birthday != null && wantedClothesCategory != null && isUsernameTaken == true;
  }

  Map<String, dynamic> toJson() => {  
      'userData' : {
        'username': username,
        'displayName': displayName,
        'profilePic': profilePic,
      },
      'genderIsMale': genderIsMale,
      'birthday': birthday.toIso8601String(),
      'wantedClothesGenderIsMale': wantedClothesGenderIsMale == null ? genderIsMale : wantedClothesGenderIsMale,
      'wantedClothesCategories': wantedClothesCategory ==null ? [] : [wantedClothesCategory],
      'hasClothesPreferences': wantedClothesCategory == null ? false : true,
      'tradeLocation': tradeLocation,
      'tradeLocationCity': tradeLocationCity,
  };

}