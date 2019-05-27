class OnboardUser {

  bool isEmailVerified;
  String email;
  String name;
  String username;
  bool isUsernameTaken;
  String profilePicUrl;
  DateTime dateOfBirth;
  bool genderIsMale;

  OnboardUser({
    this.isEmailVerified,
    this.name,
    this.username,
    this.email,
    this.isUsernameTaken,
    this.profilePicUrl,
    this.dateOfBirth,
    this.genderIsMale = false,
  });

  bool isComplete() {
    return name != null && username != null && profilePicUrl != null && isEmailVerified != null && genderIsMale != null && dateOfBirth != null && email != null &&
    username.length > 0 && name.length > 0 && profilePicUrl.length > 0  && email.length > 0  && isUsernameTaken == false && isEmailVerified == true;
  }

  Map<String, dynamic> toJson() => {
      'name': name,
      'username': username,
      'profile_pic_url': profilePicUrl,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'gender_is_male': genderIsMale,
      'email': email,
  };

}