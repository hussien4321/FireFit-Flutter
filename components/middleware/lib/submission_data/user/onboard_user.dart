class OnboardUser {

  String email;
  String name;
  String username;
  bool isUsernameTaken;
  String profilePicUrl;
  String countryCode;
  DateTime dateOfBirth;
  bool genderIsMale;

  OnboardUser({
    this.name,
    this.username = '',
    this.email,
    this.isUsernameTaken,
    this.profilePicUrl,
    this.dateOfBirth,
    this.genderIsMale = false,
    this.countryCode = 'US',
  });

  bool isComplete() {
    return name != null && username != null && profilePicUrl != null && genderIsMale != null && dateOfBirth != null && email != null && countryCode != null
    && countryCode.length > 0 && username.length > 0 && name.length > 0 && profilePicUrl.length > 0  && email.length > 0  && isUsernameTaken == false;
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