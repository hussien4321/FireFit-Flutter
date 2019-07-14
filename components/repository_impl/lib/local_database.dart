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
    Database theDB = await openDatabase(path, version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade, onDowngrade: _onDowngrade);
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
      await db.execute("CREATE TABLE outfit (outfit_id INTEGER PRIMARY KEY, poster_user_id TEXT, image_url_1 TEXT, image_url_2 TEXT, image_url_3 TEXT, title TEXT, description TEXT, style TEXT, outfit_created_at DATETIME, ratings_count INTEGER DEFAULT 0, average_rating REAL DEFAULT 0, is_saved TINYINT, comments_count INTEGER, user_rating INTEGER DEFAULT 0)");
      await db.execute("CREATE TABLE user (user_id STRING PRIMARY KEY, name TEXT, username TEXT, bio TEXT, country_code TEXT, profile_pic_url TEXT, date_of_birth DATETIME, gender_is_male TINYINT, is_subscribed  TINYINT, boosts INTEGER, subscription_end_date DATETIME, user_created_at DATETIME, is_current_user TINYINT DEFAULT 0, number_of_followers INTEGER, number_of_following INTEGER, number_of_outfits INTEGER, number_of_flames INTEGER, number_of_new_notifications INTEGER, number_of_lookbooks INTEGER, number_of_lookbook_outfits INTEGER, is_following TINYINT DEFAULT 0, follow_created_at DATETIME, has_new_feed_outfits TINYINT DEFAULT 0)");
      await db.execute("CREATE TABLE outfit_search (search_outfit_id INTERGER, search_outfit_mode STRING, UNIQUE(search_outfit_id, search_outfit_mode) ON CONFLICT REPLACE)");
      await db.execute("CREATE TABLE user_search (search_user_id STRING, search_user_mode STRING, UNIQUE(search_user_id, search_user_mode) ON CONFLICT REPLACE)");
      await db.execute("CREATE TABLE comment (comment_id INTEGER PRIMARY KEY, commenter_user_id TEXT, comment_body TEXT, comment_likes_count INTEGER, comment_is_liked TINYINT DEFAULT 0, comment_created_at DATETIME)");
      await db.execute("CREATE TABLE notification (notification_id INTEGER PRIMARY KEY, notification_type TEXT, notification_created_at DATETIME, notification_ref_user_id TEXT, notification_ref_outfit_id INTEGER, notification_ref_comment_id INTEGER, notification_is_seen TINYINT DEFAULT 0)");
      await db.execute("CREATE TABLE lookbook (lookbook_id INTEGER PRIMARY KEY, lookbook_name TEXT, lookbook_description TEXT, lookbook_user_id TEXT, number_of_outfits INTEGER DEFAULT 0, lookbook_created_at DATETIME)");
      await db.execute("CREATE TABLE save (save_id INTEGER PRIMARY KEY, save_outfit_id INTEGER, save_lookbook_id INTEGER, save_created_at DATETIME)");
    }
  }

  void _onDowngrade(Database db, int versionFrom, int versionTo) async {
    if(versionTo == 1){
      await db.execute("DROP TABLE IF EXISTS outfit");
      await db.execute("DROP TABLE IF EXISTS user");
      await db.execute("DROP TABLE IF EXISTS outfit_search");
      await db.execute("DROP TABLE IF EXISTS user_search");
      await db.execute("DROP TABLE IF EXISTS comment");
      await db.execute("DROP TABLE IF EXISTS notification");
      await db.execute("DROP TABLE IF EXISTS lookbook");
      await db.execute("DROP TABLE IF EXISTS save");
      await _applyMigration(db, versionTo);
    }
  }

}