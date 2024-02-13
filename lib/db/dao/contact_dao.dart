import 'package:sqflite/sqflite.dart';
import '../models/contact.dart';
import '../database.dart';

class ContactDao {
  Future<void> insertContact(Contact contact) async {
    final db = await DatabaseProvider.db.database;
    await db.insert(
      'contacts',
      contact.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Contact>> getContacts() async {
    final db = await DatabaseProvider.db.database;
    final List<Map<String, dynamic>> maps = await db.query('contacts');
    return List.generate(maps.length, (i) {
      return Contact.fromMap(maps[i]);
    });
  }

  Future<void> updateContact(Contact contact) async {
    final db = await DatabaseProvider.db.database;
    await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<void> deleteContact(int id) async {
    final db = await DatabaseProvider.db.database;
    await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
