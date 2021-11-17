class SearchUser {

  String userId, searchMode;

  SearchUser({
    this.userId,
    this.searchMode,
  });

  SearchUser.fromMap(Map<String, dynamic> map){
    userId = map['search_user_id'];
    searchMode = map['search_user_mode'];
  } 

  Map<String, dynamic> toJson() => {
    'search_user_id' : userId, 
    'search_user_mode' : searchMode,
  };

}