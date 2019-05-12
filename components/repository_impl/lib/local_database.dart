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
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "mira_mira.db");
    Database theDB = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDB;
  }

  

  void _onCreate(Database db, int version) async {
    // print("Running SQL Command ${Outfit.toSqlCreate()}");
    // await db.execute("CREATE TABLE users (${Outfit.toSqlCreate()})");
    // await db.execute("CREATE TABLE posts (${Outfit.toSqlCreate()})");
    // await db.execute("CREATE TABLE clothes");
    // await db.execute("CREATE TABLE posts");
    // await db.execute("CREATE TABLE conversations");
    // await db.execute("CREATE TABLE messages");
    // await db.execute("CREATE TABLE outfits");
    // await db.execute("CREATE TABLE daily_outfits");
    // await db.execute("CREATE TABLE notifications");
    // await db.execute("CREATE TABLE alerts");
  }

}