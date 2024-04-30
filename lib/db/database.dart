import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';


// class DatabaseProvider {
//   static Database? _database;

//   DatabaseProvider._privateConstructor();

//   static final DatabaseProvider db = DatabaseProvider._privateConstructor();

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await initDB();
//     return _database!;
//   }

//   Future<void> deleteDatabase(String path) async {
//   // Get the database path
//   var databasesPath = await getDatabasesPath();
//   String path = join(databasesPath, 'People_Q.db');

//   // Delete the database
//   await deleteDatabase(path);
// }

//   initDB() async {
//     var dbPath = await getDatabasesPath();
//     String path = join(dbPath, "People_Q.db");
//     return await openDatabase(path, version: 1, onOpen: (db) {}, onCreate: (Database db, int version) async {
//       await db.execute("CREATE TABLE users("
//           "id INTEGER PRIMARY KEY AUTOINCREMENT,"
//           "name TEXT NOT NULL,"
//           "email TEXT UNIQUE NOT NULL,"
//           "phoneNumber TEXT NOT NULL,"
//           "birthday DATE NOT NULL"
//           "password TEXT NOT NULL"
//           ")");
//       await db.execute("CREATE TABLE contacts("
//           "id INTEGER PRIMARY KEY AUTOINCREMENT,"
//           "userId INTEGER NOT NULL,"
//           "name TEXT NOT NULL,"
//           "birthday TEXT NOT NULL,"
//           "picturePath TEXT NOT NULL,"
//           "phoneNumber TEXT NOT NULL,"
//           "bio TEXT NOT NULL,"
//           "timesInteractedWith INTEGER DEFAULT 0,"
//           "FOREIGN KEY(userId) REFERENCES users(id) ON DELETE CASCADE"
//           ")");
//       await db.execute("CREATE TABLE events("
//           "eventId INTEGER PRIMARY KEY AUTOINCREMENT,"
//           "contactId INTEGER NOT NULL,"
//           "eventDate TEXT NOT NULL,"
//           "description TEXT NOT NULL,"
//           "FOREIGN KEY(contactId) REFERENCES contacts(id) ON DELETE CASCADE"
//           ")");
//     });
//   }

//     // Method for initializing an in-memory test database
//   Future<void> initializeTestDB() async {
//     // Close the existing database to avoid conflicts
//     if (_database != null) {
//       await _database!.close();
//     }
//     // Setting up an in-memory database for testing
//     _database = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath, options: OpenDatabaseOptions(
//       version: 1,
//       onCreate: (Database db, int version) async {
//       await db.execute("CREATE TABLE contacts("
//           "id INTEGER PRIMARY KEY AUTOINCREMENT,"
//           "name TEXT,"
//           "birthday TEXT,"
//           "picturePath TEXT,"
//           "phoneNumber TEXT,"
//           "bio TEXT,"
//           "timesInteractedWith INTEGER DEFAULT 0"
//           ")");
//       await db.execute("CREATE TABLE events("
//           "eventId INTEGER PRIMARY KEY AUTOINCREMENT,"
//           "contactId INTEGER,"
//           "eventDate TEXT,"
//           "description TEXT,"
//           "FOREIGN KEY(contactId) REFERENCES contacts(id)"
//           ")");
//       // Create tables exactly like your initDB method or as needed for testing
//       }
//     ));
//   }
// }
