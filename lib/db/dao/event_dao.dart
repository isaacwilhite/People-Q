import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../models/event.dart';
import '../models/contact.dart';
import '../database.dart';

class EventDao {
  Future<void> insertEvent(Event event) async{
    final db = await DatabaseProvider.db.database;
    final map = event.toMap();

  await db.insert('events', map, conflictAlgorithm: ConflictAlgorithm.replace);
}
    Future<List<Event>> getEvents() async {
    final db = await DatabaseProvider.db.database;
    final List<Map<String, dynamic>> maps = await db.query('events');
    return List.generate(maps.length, (i) {
      return Event.fromMap(maps[i]);
    });
  }

  Future<List<Event>> getEventsByContact(int contactId) async {
  final db = await DatabaseProvider.db.database;
  final List<Map<String, dynamic>> maps = await db.query(
    'events',
    where: 'contactId = ?',
    whereArgs: [contactId],
  );

  

  return List.generate(maps.length, (i) {
    return Event.fromMap(maps[i]);
  });
}

  Future<List<Contact>> getContactsFoEventDate(String date) async {
    final db = await DatabaseProvider.db.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT contacts.* FROM contacts '
      'JOIN events ON contacts.id = events.contactId '
      'WHERE events.eventDate = ?',
      [date] // Ensure the date is in the correct format ('YYYY-MM-DD')
    );
    return List.generate(maps.length, (i) {
      return Contact.fromMap(maps[i]);
    });
  }

  Future<void> updateEvent(Event event) async {
    final db = await DatabaseProvider.db.database;
    await db.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.eventId],
    );
  }

  Future<void> deleteEvent(int eventId) async {
    final db = await DatabaseProvider.db.database;
    await db.delete(
      'events',
      where: 'eventId = ?',
      whereArgs: [eventId],
    );
  }
}