class User {


  String userId;
  String name;
  String username;
  String bio;
  String profilePicUrl;
  bool genderIsMale;
  DateTime dateOfBirth;
  bool isSubscribed;
  int boosts;
  DateTime subscriptionEndDate;
  DateTime createdAt;
  DateTime lastSeenNotificationAt;
  int numberOfFollowers, numberOfFollowing, numberOfOutfits, numberOfLikes, numberOfNewNotifications;
  bool isFollowing;

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
    bio = map['bio'];
    profilePicUrl = map['profile_pic_url'];
    dateOfBirth = DateTime.parse(map['date_of_birth']);
    genderIsMale = map['gender_is_male'] != 0;
    isSubscribed = map['is_subscribed'] != 0;
    if(isSubscribed){
      subscriptionEndDate = DateTime.parse(map['subscription_end_date']);
    }
    boosts = map['boosts'];
    createdAt = DateTime.parse(map['user_created_at']);
    lastSeenNotificationAt = DateTime.parse(map['last_seen_notification_at']);
    numberOfFollowers = map['number_of_followers'];
    numberOfFollowing = map['number_of_following'];
    numberOfOutfits = map['number_of_outfits'];
    numberOfLikes = map['number_of_likes'];
    numberOfNewNotifications = map['number_of_new_notifications'];
    isFollowing = map['is_following'] == 1;
  } 

  Map<String, dynamic> toJson() => {
    'user_id' : userId, 
    'name' : name,
    'username': username,
    'bio': bio,
    'profile_pic_url' : profilePicUrl,
    'date_of_birth' : dateOfBirth?.toIso8601String(), 
    'gender_is_male' : genderIsMale ? 1 : 0, 
    'is_subscribed' : isSubscribed ? 1 : 0, 
    'boosts' : boosts, 
    'subscription_end_date' : subscriptionEndDate?.toIso8601String(), 
    'user_created_at' : createdAt?.toIso8601String(), 
    'last_seen_notification_at' : lastSeenNotificationAt?.toIso8601String(),
    'number_of_followers' : numberOfFollowers,
    'number_of_following' : numberOfFollowing,
    'number_of_outfits' : numberOfOutfits,
    'number_of_likes' : numberOfLikes,
    'number_of_new_notifications' : numberOfNewNotifications,
    'is_following' : isFollowing ? 1 : 0,
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