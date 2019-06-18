import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {

  static Database _database;

  static final LocalDatabase _singleton = new LocalDatabase._internal();

  factory LocalDatabase() {
    return _singleton;
  }

  LocalDatabase._internal() {
    initDb().then((resDatabase) {
      _database = resDatabase;
    });
  }

  Future<Database> get db async {
    if(_database != null)
      return _database;
    _database = await initDb() ;
    return _database;
  }

  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), "mira_mira.db");
    Database theDB = await openDatabase(path, version: 3, onCreate: _onCreate, onUpgrade: _onUpgrade);
    return theDB;
  }


  void _onCreate(Database db, int version) async {
    _onUpgrade(db, 0, version);
  }


  void _onUpgrade(Database db, int versionFrom, int versionTo) async {
    for(int i =versionFrom; i < versionTo; i++){
      int nextVersion = i + 1;
      await _applyMigration(db, nextVersion);
    }
  }

  Future<void> _applyMigration(Database db, int version) async {
    if(version == 1){
      await db.execute("CREATE TABLE outfit (outfit_id INTEGER PRIMARY KEY, poster_user_id TEXT, image_url_1 TEXT, image_url_2 TEXT, image_url_3 TEXT, title TEXT, description TEXT, style TEXT, outfit_created_at DATETIME, likes_count INTEGER, dislikes_count INTEGER, is_saved TINYINT, comments_count INTEGER, user_impression INTEGER DEFAULT 0)");
      await db.execute("CREATE TABLE user (user_id STRING PRIMARY KEY, name TEXT, username TEXT, bio TEXT, profile_pic_url TEXT, date_of_birth DATETIME, gender_is_male TINYINT, is_subscribed  TINYINT, boosts INTEGER, subscription_end_date DATETIME, user_created_at DATETIME, is_current_user TINYINT DEFAULT 0, last_seen_notification_at DATETIME, number_of_followers INTEGER, number_of_following INTEGER, number_of_outfits INTEGER, number_of_likes INTEGER, number_of_new_notifications INTEGER, is_following TINYINT DEFAULT 0)");
      await db.execute("CREATE TABLE outfit_search (search_outfit_id INTERGER, search_outfit_mode STRING, UNIQUE(search_outfit_id, search_outfit_mode) ON CONFLICT REPLACE)");
      await db.execute("CREATE TABLE user_search (search_user_id STRING, search_user_mode STRING, UNIQUE(search_user_id, search_user_mode) ON CONFLICT REPLACE)");
      await db.execute("CREATE TABLE comment (comment_id INTEGER PRIMARY KEY, commenter_user_id TEXT, comment_body TEXT, comment_likes_count INTEGER, comment_is_liked TINYINT DEFAULT 0, comment_created_at DATETIME)");
      await db.execute("CREATE TABLE notification (notification_id INTEGER PRIMARY KEY, notification_type TEXT, notification_created_at DATETIME, notification_ref_user_id TEXT, notification_ref_outfit_id INTEGER, notification_ref_comment_id INTEGER)");
      await db.execute("CREATE TABLE save (save_id INTEGER PRIMARY KEY, save_outfit_id INTEGER, save_user_id TEXT, save_created_at DATETIME)");
    }
    if(version == 2){
      await db.execute("ALTER TABLE user ADD COLUMN has_new_feed_outfits TINYINT DEFAULT 0");
    }
    if(version == 3){
      await db.execute("ALTER TABLE user ADD COLUMN has_new_followers TINYINT DEFAULT 0");
    }
  }

}