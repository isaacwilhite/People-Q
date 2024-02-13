import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseProvider {
  static Database? _database;

  DatabaseProvider._();

  static final DatabaseProvider db = DatabaseProvider._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<void> deleteDatabase(String path) async {
  // Get the database path
  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'People_Q.db');

  // Delete the database
  await deleteDatabase(path);
}

  initDB() async {
    var dbPath = await getDatabasesPath();
    String path = join(dbPath, "People_Q.db");
    return await openDatabase(path, version: 1, onOpen: (db) {}, onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE contacts("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "name TEXT,"
          "birthday TEXT,"
          "picturePath TEXT,"
          "phoneNumber TEXT,"
          "bio TEXT,"
          "timesInteractedWith INTEGER DEFAULT 0"
          ")");
      await db.execute("CREATE TABLE events("
          "eventId INTEGER PRIMARY KEY AUTOINCREMENT,"
          "contactId INTEGER,"
          "eventDate TEXT,"
          "description TEXT,"
          "FOREIGN KEY(contactId) REFERENCES contacts(id)"
          ")");
    });
  }
}
