import 'package:streamqflite/streamqflite.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
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
    Database theDB = await openDatabase(path, version: 4, onCreate: _onCreate, onUpgrade: _onUpgrade);
    return theDB;
  }


  void _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE outfit (outfit_id INTEGER PRIMARY KEY, poster_user_id TEXT, image_url_1 TEXT, image_url_2 TEXT, image_url_3 TEXT, title TEXT, description TEXT, style TEXT, outfit_created_at DATETIME, likes_count INTEGER, comments_count INTEGER)");
  }


  void _onUpgrade(Database db, int versionFrom, int versionTo) async {
    for(int i =versionFrom; i < versionTo; i++){
      int nextVersion = i + 1;
      await _applyMigration(db, nextVersion);
    }
  }

  Future<void> _applyMigration(Database db, int version) async {
    if(version == 3){
      await db.execute("CREATE TABLE user (user_id INTEGER PRIMARY KEY, name TEXT, profile_pic_url TEXT, date_of_birth DATETIME, gender_is_male TINYINT, is_subscribed  TINYINT, boosts INTEGER, subscription_end_date DATETIME, user_created_at DATETIME)");
    }
    if(version == 4){
      await db.execute("DROP TABLE user");
      await db.execute("CREATE TABLE user (user_id STRING PRIMARY KEY, name TEXT, profile_pic_url TEXT, date_of_birth DATETIME, gender_is_male TINYINT, is_subscribed  TINYINT, boosts INTEGER, subscription_end_date DATETIME, user_created_at DATETIME)");

    }
  }

}