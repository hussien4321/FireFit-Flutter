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
    if(_database != null){
      return _database;
    }
    _database = await initDb();
    return _database;
  }

  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), "mira_mira.db");
    Database theDB = await openDatabase(path, version: 8, onCreate: _onCreate, onUpgrade: _onUpgrade, onDowngrade: _onDowngrade);
    return theDB;
  }


  Future<void> _onCreate(Database db, int version) async {
    await _onUpgrade(db, 0, version);
  }


  Future<void> _onUpgrade(Database db, int versionFrom, int versionTo) async {
    int startVersion = versionFrom + 1;
    startVersion = skipUnnecessaryVersions(startVersion) - 1;
    for(int i = startVersion; i <= versionTo; i++){
      int nextVersion = i + 1;
      await _applyMigration(db, nextVersion);
    }
  }

  skipUnnecessaryVersions(int startVersion) {
    switch (startVersion) {
      case 1:
      case 2:
      case 3:
      case 4:
        return 5;
      default:
        return startVersion;
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
    if(version == 2){
      await db.execute("ALTER TABLE comment ADD COLUMN comment_reply_to INTEGER");
    }
    if(version == 3){
      await db.execute("ALTER TABLE comment ADD COLUMN comment_replies_count INTEGER DEFAULT 0");
    }
    if(version == 4){
      await db.execute("ALTER TABLE outfit ADD COLUMN hidden_rating REAL DEFAULT 3");
    }
    if(version == 5) {
      await _deleteAll(db);
    }
    if(version == 6){
      await db.execute("CREATE TABLE outfit (outfit_id INTEGER PRIMARY KEY, poster_user_id TEXT, image_url_1 TEXT, image_url_2 TEXT, image_url_3 TEXT, title TEXT, description TEXT, style TEXT, outfit_created_at DATETIME, ratings_count INTEGER DEFAULT 0, average_rating REAL DEFAULT 0, is_saved TINYINT, comments_count INTEGER, user_rating INTEGER DEFAULT 0, hidden_rating REAL DEFAULT 3)");
      await db.execute("CREATE TABLE user (user_id STRING PRIMARY KEY, name TEXT, username TEXT, bio TEXT, country_code TEXT, profile_pic_url TEXT, date_of_birth DATETIME, gender_is_male TINYINT, is_subscribed  TINYINT, boosts INTEGER, subscription_end_date DATETIME, user_created_at DATETIME, is_current_user TINYINT DEFAULT 0, number_of_followers INTEGER, number_of_following INTEGER, number_of_outfits INTEGER, number_of_flames INTEGER, number_of_new_notifications INTEGER, number_of_lookbooks INTEGER, number_of_lookbook_outfits INTEGER, is_following TINYINT DEFAULT 0, follow_created_at DATETIME, has_new_feed_outfits TINYINT DEFAULT 0)");
      await db.execute("CREATE TABLE outfit_search (search_outfit_id INTERGER, search_outfit_mode STRING, UNIQUE(search_outfit_id, search_outfit_mode) ON CONFLICT REPLACE)");
      await db.execute("CREATE TABLE user_search (search_user_id STRING, search_user_mode STRING, UNIQUE(search_user_id, search_user_mode) ON CONFLICT REPLACE)");
      await db.execute("CREATE TABLE comment (comment_id INTEGER PRIMARY KEY, commenter_user_id TEXT, comment_body TEXT, comment_likes_count INTEGER, comment_is_liked TINYINT DEFAULT 0, comment_reply_to INTEGER, comment_replies_count INTEGER DEFAULT 0, comment_created_at DATETIME)");
      await db.execute("CREATE TABLE notification (notification_id INTEGER PRIMARY KEY, notification_type TEXT, notification_created_at DATETIME, notification_ref_user_id TEXT, notification_ref_outfit_id INTEGER, notification_ref_comment_id INTEGER, notification_is_seen TINYINT DEFAULT 0)");
      await db.execute("CREATE TABLE lookbook (lookbook_id INTEGER PRIMARY KEY, lookbook_name TEXT, lookbook_description TEXT, lookbook_user_id TEXT, number_of_outfits INTEGER DEFAULT 0, lookbook_created_at DATETIME)");
      await db.execute("CREATE TABLE save (save_id INTEGER PRIMARY KEY, save_outfit_id INTEGER, save_lookbook_id INTEGER, save_created_at DATETIME)");
    }
    if(version == 7){
      try {
        await db.execute("ALTER TABLE user ADD COLUMN posts_on_day INTEGER DEFAULT 0");
        await db.execute("ALTER TABLE user ADD COLUMN last_upload_date DATETIME");
      } on DatabaseException catch (_) {

      }
    }
    if(version == 8) {
      try {
        await db.execute("ALTER TABLE user ADD COLUMN has_new_upload TINYINT DEFAULT 0");
      } on DatabaseException catch (_) {

      }
    }
  }
  Future<void> _deleteAll(Database db) async {
    await db.execute("DROP TABLE IF EXISTS outfit");
    await db.execute("DROP TABLE IF EXISTS user");
    await db.execute("DROP TABLE IF EXISTS outfit_search");
    await db.execute("DROP TABLE IF EXISTS user_search");
    await db.execute("DROP TABLE IF EXISTS comment");
    await db.execute("DROP TABLE IF EXISTS notification");
    await db.execute("DROP TABLE IF EXISTS lookbook");
    await db.execute("DROP TABLE IF EXISTS save");
  }
  void _onDowngrade(Database db, int versionFrom, int versionTo) async {
    if(versionTo == 1){
      await _deleteAll(db);
      await _applyMigration(db, versionTo);
    }
  }

}