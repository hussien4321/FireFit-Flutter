class OnboardUser {

  String email;
  String name;
  String username;
  bool isUsernameTaken, isUsernameLongEnough;
  String profilePicUrl;
  String countryCode;
  DateTime dateOfBirth;
  bool hasConfirmedAge, hasReadDocuments;
  bool hasAcceptedEULA;
  bool genderIsMale;

  OnboardUser({
    this.name,
    this.username = '',
    this.email,
    this.isUsernameTaken,
    this.isUsernameLongEnough = false,
    this.profilePicUrl,
    this.dateOfBirth,
    this.genderIsMale = false,
    this.hasConfirmedAge = false,
    this.hasReadDocuments = false,
    this.hasAcceptedEULA = false,
    this.countryCode = 'US',
  });

  bool isComplete() {
    return name != null && username != null && profilePicUrl != null && genderIsMale != null && dateOfBirth != null && email != null && countryCode != null
    && countryCode.length > 0 && username.length > 0 && name.length > 0 && profilePicUrl.length > 0  && email.length > 0  && isUsernameTaken == false && isUsernameLongEnough && hasConfirmedAge && hasReadDocuments && hasAcceptedEULA;
  }

  Map<String, dynamic> toJson() => {
      'name': name,
      'username': username,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'gender_is_male': genderIsMale,
      'country_code': countryCode,
      'email': email,
  };

}