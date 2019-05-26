import 'package:streamqflite/streamqflite.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:middleware/middleware.dart';

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
    Database theDB = await openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
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
      await db.execute("CREATE TABLE outfit (outfit_id INTEGER PRIMARY KEY, poster_user_id TEXT, image_url_1 TEXT, image_url_2 TEXT, image_url_3 TEXT, title TEXT, description TEXT, style TEXT, outfit_created_at DATETIME, likes_count INTEGER, comments_count INTEGER)");
      await db.execute("CREATE TABLE user (user_id STRING PRIMARY KEY, name TEXT, profile_pic_url TEXT, date_of_birth DATETIME, gender_is_male TINYINT, is_subscribed  TINYINT, boosts INTEGER, subscription_end_date DATETIME, user_created_at DATETIME)");
    }
    if(version == 2){
      await db.execute("ALTER TABLE user ADD COLUMN username TEXT AFTER name");
    }
  }

}