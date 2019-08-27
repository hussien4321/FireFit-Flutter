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
  bool hasNewUpload;
  DateTime createdAt;
  int numberOfFollowers, numberOfFollowing, numberOfOutfits, numberOfFlames, numberOfNewNotifications;
  int numberOfLookbooks, numberOfLookbookOutfits;
  bool isFollowing;
  int postsOnDay;
  DateTime lastUploadDate;
  DateTime followCreatedAt;
  DateTime blockCreatedAt;
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
    this.hasNewUpload,
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
    numberOfLookbooks =  map['number_of_lookbooks'] == null ? 0 : map['number_of_lookbooks'];
    numberOfLookbookOutfits =  map['number_of_lookbook_outfits'] == null ? 0 : map['number_of_lookbook_outfits'];
    isFollowing = map['is_following'] == 1;
    followCreatedAt = map['follow_created_at'] == null ? null : DateTime.parse(map['follow_created_at']);
    blockCreatedAt = map['block_created_at'] == null ? null : DateTime.parse(map['block_created_at']);
    postsOnDay = map['posts_on_day'] == null ? 0 : map['posts_on_day'];
    lastUploadDate = map['last_upload_date'] == null ? null : DateTime.parse(map['last_upload_date']);
    hasNewUpload = map['has_new_upload'] == 1;
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
    'number_of_lookbooks' : numberOfLookbooks,
    'number_of_lookbook_outfits' : numberOfLookbookOutfits,
    'follow_created_at' : followCreatedAt?.toIso8601String(),
    'block_created_at': blockCreatedAt?.toIso8601String(),
    'posts_on_day' : postsOnDay,
    'last_upload_date' : lastUploadDate?.toIso8601String(),
    'has_new_upload' : hasNewUpload ? 1 : 0,
    'is_following' : isFollowing ? 1 : 0,
  };

  String get ageRange {
    final factor = 6;
    
    int roundedDownAge = (_age / factor).floor() * factor;
    return "${roundedDownAge}-${roundedDownAge+factor-1}";
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