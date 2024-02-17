import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../lib/db/dao/event_dao.dart';
import '../lib/db/models/event.dart';
import '../lib/db/database.dart';

void main() {

  sqfliteFfiInit();
  group('EventDao Tests', () {
    late EventDao eventDao;

    setUp(() async {
      databaseFactory = databaseFactoryFfi;
      // Initialize your database and ContactDao
      // This might involve creating an in-memory SQLite database for testing
      eventDao = EventDao();
      // Assuming you have a method to get your database ready for testing
      await DatabaseProvider.db.initializeTestDB();
    });

    test('insert and retrieve event', () async {
      final event = Event(
        contactId: 1,
        eventDate: '1990-01-01',
        description: 'Birthday',
      );

      // Insert the contact
      await eventDao.insertEvent(event);

      // Retrieve all contacts
      final events = await eventDao.getEvents();
      for (Event event in events) {
        print('ID: ${event.eventId}, Contact Id: ${event.contactId}, Event Date: ${event.eventDate}, '
          'Description: ${event.description}');
  }

      // Verify the inserted contact is in the database
      expect(events.isNotEmpty, true);
      expect(events.first.eventDate, '1990-01-01');
      // Add more assertions as needed to validate your data
    });

    // Write more tests for update and delete operations
  });
}