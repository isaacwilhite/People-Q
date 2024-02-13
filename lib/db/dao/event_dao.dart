import 'package:sqflite/sqflite.dart';
import '../models/event.dart';
import '../database.dart';

class EventDao {
  Future<void> insertEvent(Event event) async{
    final db = await DatabaseProvider.db.database;
    await db.insert(
      'events',
      event.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
    Future<List<Event>> getEvents() async {
    final db = await DatabaseProvider.db.database;
    final List<Map<String, dynamic>> maps = await db.query('events');
    return List.generate(maps.length, (i) {
      return Event.fromMap(maps[i]);
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