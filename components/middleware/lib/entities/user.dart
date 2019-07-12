import 'package:middleware/middleware.dart';

class User {

  String userId;
  String name;
  String username;
  String bio;
  String countryCode;
  String profilePicUrl;
  bool genderIsMale;
  DateTime dateOfBirth;
  bool isSubscribed;
  int boosts;
  DateTime subscriptionEndDate;
  bool hasNewFeedOutfits;
  DateTime createdAt;
  int numberOfFollowers, numberOfFollowing, numberOfOutfits, numberOfFlames, numberOfNewNotifications;
  bool isFollowing;
  DateTime followCreatedAt;
  SearchUser searchUser;

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

  bool get hasFullData => numberOfFollowers != null;

  User.fromMap(Map<String, dynamic> map){
    userId = map['user_id'].toString();
    name = map['name'];
    username = map['username'];
    bio = map['bio'];
    countryCode = map['country_code'];
    profilePicUrl = map['profile_pic_url'];
    dateOfBirth = DateTime.parse(map['date_of_birth']);
    genderIsMale = map['gender_is_male'] != 0;
    isSubscribed = map['is_subscribed'] != 0;
    if(isSubscribed){
      subscriptionEndDate = DateTime.parse(map['subscription_end_date']);
    }
    boosts = map['boosts'];
    createdAt = DateTime.parse(map['user_created_at']);
    hasNewFeedOutfits = map['has_new_feed_outfits'] == 1;
    numberOfFollowers = map['number_of_followers'];
    numberOfFollowing = map['number_of_following'];
    numberOfOutfits = map['number_of_outfits'];
    numberOfFlames = map['number_of_flames'] == null ? 0 : map['number_of_flames'];
    numberOfNewNotifications = map['number_of_new_notifications'];
    isFollowing = map['is_following'] == 1;
    followCreatedAt = map['follow_created_at'] == null ? null : DateTime.parse(map['follow_created_at']);
    searchUser = SearchUser.fromMap(map);
  } 

  Map<String, dynamic> toJson() => {
    'user_id' : userId, 
    'name' : name,
    'username': username,
    'bio': bio,
    'country_code' : countryCode,
    'profile_pic_url' : profilePicUrl,
    'date_of_birth' : dateOfBirth?.toIso8601String(), 
    'gender_is_male' : genderIsMale ? 1 : 0, 
    'is_subscribed' : isSubscribed ? 1 : 0, 
    'boosts' : boosts, 
    'subscription_end_date' : subscriptionEndDate?.toIso8601String(), 
    'user_created_at' : createdAt?.toIso8601String(), 
    'has_new_feed_outfits' :hasNewFeedOutfits? 1:0,
    'number_of_followers' : numberOfFollowers,
    'number_of_following' : numberOfFollowing,
    'number_of_outfits' : numberOfOutfits,
    'number_of_flames' : numberOfFlames,
    'number_of_new_notifications' : numberOfNewNotifications,
    'follow_created_at' : followCreatedAt?.toIso8601String(),
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