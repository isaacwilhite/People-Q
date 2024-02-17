import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../lib/db/dao/contact_dao.dart';
import '../lib/db/models/contact.dart';
import '../lib/db/database.dart';

void main() {

  sqfliteFfiInit();
  group('ContactDao Tests', () {
    late ContactDao contactDao;

    setUp(() async {
      databaseFactory = databaseFactoryFfi;
      // Initialize your database and ContactDao
      // This might involve creating an in-memory SQLite database for testing
      contactDao = ContactDao();
      // Assuming you have a method to get your database ready for testing
      await DatabaseProvider.db.initializeTestDB();
    });

    test('insert and retrieve contact', () async {
      final contact = Contact(
        name: 'Test Name',
        birthday: '1990-01-01',
        picturePath: 'path/to/picture',
        phoneNumber: '1234567890',
        bio: 'Test Bio',
        timesInteractedWith: 0,
      );

      // Insert the contact
      await contactDao.insertContact(contact);

      // Retrieve all contacts
      final contacts = await contactDao.getContacts();
      for (Contact contact in contacts) {
        print('ID: ${contact.id}, Name: ${contact.name}, Birthday: ${contact.birthday}, '
          'Picture Path: ${contact.picturePath}, Phone Number: ${contact.phoneNumber}, '
          'Bio: ${contact.bio}, Times Interacted With: ${contact.timesInteractedWith}');
  }

      // Verify the inserted contact is in the database
      expect(contacts.isNotEmpty, true);
      expect(contacts.first.name, 'Test Name');
      // Add more assertions as needed to validate your data
    });

    test('update contact', () async {
      final contactDao = ContactDao();

  // Insert a contact
      final contact = Contact(
        name: 'John Doe',
        birthday: '1985-01-01',
        picturePath: 'path/to/picture',
        phoneNumber: '555-1234',
        bio: 'Initial bio',
        timesInteractedWith: 1,
      );
      await contactDao.insertContact(contact);
      final contactId = await contactDao.insertContact(contact);
      contact.id = contactId;
  // Update the contact
      contact.name = 'Jane Doe'; // Change a field
      contact.bio = 'Updated bio';
      await contactDao.updateContact(contact);

  // Retrieve all contacts
      final updatedContacts = await contactDao.getContacts();

  // Assert the contact was updated
      final updatedContact = updatedContacts.firstWhere((c) => c.id == contact.id);
      expect(updatedContact.name, 'Jane Doe');
      expect(updatedContact.bio, 'Updated bio');
    });

    test('delete contact', () async {
  final contactDao = ContactDao();

  // Insert a contact
  final contact = Contact(
    name: 'John Doe',
    birthday: '1985-01-01',
    picturePath: 'path/to/picture',
    phoneNumber: '555-1234',
    bio: 'A short bio',
    timesInteractedWith: 1,
  );
  await contactDao.insertContact(contact);
  final contactId = await contactDao.insertContact(contact);
  contact.id = contactId;
  // Delete the contact
  await contactDao.deleteContact(contact.id!);

  // Retrieve all contacts
  final contacts = await contactDao.getContacts();

  // Assert the contact was deleted
  bool contactExists = contacts.any((c) => c.id == contact.id);
  expect(contactExists, false);
});
  });
}