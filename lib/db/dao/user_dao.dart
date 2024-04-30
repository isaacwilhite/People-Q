// import 'package:sqflite/sqflite.dart';
import '../models/user.dart';
import '../database.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

// class UserDao {
//   Future<int> insertUser(User user) async {
//     final db = await DatabaseProvider.db.database;
//     final hashedPassword = _hashPassword(user.password);
//     final userMap = user.toMap();
//     userMap['password'] = hashedPassword;
//     return await db.insert('users', userMap, conflictAlgorithm: ConflictAlgorithm.replace);
//   }

//   Future<List<User>> getUsers() async {
//     final db = await DatabaseProvider.db.database;
//     final List<Map<String, dynamic>> maps = await db.query('users');
//     return List.generate(maps.length, (i) {
//       return User.fromMap(maps[i]);
//     });
//   }

//   Future<void> updateUser(User user) async {
//     final db = await DatabaseProvider.db.database;
//     final hashedPassword = _hashPassword(user.password);
//     final userMap = user.toMap();
//     userMap['password'] = hashedPassword;
//     await db.update(
//       'users',
//       userMap,
//       where: 'id = ?',
//       whereArgs: [user.id],
//     );
//   }

//   Future<void> deleteUser(int id) async {
//     final db = await DatabaseProvider.db.database;
//     await db.delete(
//       'users',
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }

//   String _hashPassword(String password) {
//     var bytes = utf8.encode(password);
//     var digest = sha256.convert(bytes);
//     return digest.toString();
//   }

//   Future<bool> userExists() async {
//     final db = await DatabaseProvider.db.database;
//     final List<Map<String, dynamic>> result = await db.query('users');
//     return result.isNotEmpty;
//   }
// }

