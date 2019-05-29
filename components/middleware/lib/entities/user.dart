class User {


  String userId;
  String name;
  String username;
  String profilePicUrl;
  bool genderIsMale;
  DateTime dateOfBirth;
  bool isSubscribed;
  int boosts;
  DateTime subscriptionEndDate;
  DateTime createdAt;


  User({
    this.userId,
    this.name,
    this.username,
    this.profilePicUrl,
    this.genderIsMale,
    this.dateOfBirth,
    this.isSubscribed,
    this.boosts,
    this.subscriptionEndDate,
    this.createdAt,
  });



  User.fromMap(Map<String, dynamic> map){
    userId = map['user_id'].toString();
    name = map['name'];
    username = map['username'];
    profilePicUrl = map['profile_pic_url'];
    dateOfBirth = DateTime.parse(map['date_of_birth']);
    genderIsMale = map['gender_is_male'] != 0;
    isSubscribed = map['is_subscribed'] != 0;
    if(isSubscribed){
      subscriptionEndDate = DateTime.parse(map['subscription_end_date']);
    }
    boosts = map['boosts'];
    createdAt = DateTime.parse(map['user_created_at']);
  } 

  Map<String, dynamic> toJson({bool cache = false}) => {
    'user_id' : userId, 
    'name' : name,
    'username': username,
    'profile_pic_url' : profilePicUrl,
    'date_of_birth' : cache ? dateOfBirth?.toIso8601String() : dateOfBirth, 
    'gender_is_male' : genderIsMale ? 1 : 0, 
    'is_subscribed' : isSubscribed ? 1 : 0, 
    'boosts' : boosts, 
    'subscription_end_date' : cache ? subscriptionEndDate?.toIso8601String() : subscriptionEndDate, 
    'user_created_at' : cache ? createdAt?.toIso8601String() : createdAt, 
  };

  String get ageRange {
    final factor = 10;
    
    int roundedDownAge = (_age / factor).floor() * factor;
    return "${roundedDownAge}-${roundedDownAge+factor}";
  }

  int get _age {
    DateTime dateMarker = DateTime.now();
    int years = 0;
    while(dateMarker.isAfter(dateOfBirth)){
      dateMarker = DateTime( dateMarker.year-1, dateMarker.month, dateMarker.day);
      years++;
    }
    return years;
  }
}