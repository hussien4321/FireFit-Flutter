import '../../../middleware/entities.dart';

class EditUser {

  String userId;
  String name;
  String bio;
  String profilePicUrl;
  String initialProfilePicUrl;

  EditUser({
    this.userId,
    this.name, 
    this.bio,
    this.profilePicUrl,
    this.initialProfilePicUrl,
  });

  bool get hasNewProfilePic => profilePicUrl !=initialProfilePicUrl && profilePicUrl!= null && initialProfilePicUrl != null;

  EditUser.fromUser(User userToUpdate) :
    userId = userToUpdate.userId,
    name = userToUpdate.name,
    bio = userToUpdate.bio,
    profilePicUrl = userToUpdate.profilePicUrl,
    initialProfilePicUrl = userToUpdate.profilePicUrl;

  bool get canBeUpdated => userId!=null && hasName && hasProfilePicUrl;

  bool get hasName => name != null  && name.isNotEmpty;
  bool get hasProfilePicUrl => profilePicUrl != null  && profilePicUrl.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'name' : name, 
    'bio' : bio,
  };
}