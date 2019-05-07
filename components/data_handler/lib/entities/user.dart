class User {

  String name;
  String profilePic;
  bool genderIsMale;
  DateTime dateOfBirth;

  User({
    this.name,
    this.profilePic,
    this.genderIsMale,
    this.dateOfBirth,
  });

  int get age {
    DateTime dateMarker = DateTime.now();
    int years = 0;
    while(dateMarker.isAfter(dateOfBirth)){
      dateMarker = DateTime( dateMarker.year-1, dateMarker.month, dateMarker.day);
      years++;
    }
    return years;
  }
}