
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:sqflite/sqflite.dart';
import '../models/contact.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:amplify_flutter/amplify_flutter.dart';

class ContactDAO {
  final String apiUrl = "https://ahqampwcz1.execute-api.us-east-2.amazonaws.com/dev";

  Future<List<Contact>> fetchContacts(String userId) async {
    var response = await http.get(Uri.parse("$apiUrl/contacts?userId=$userId"));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Contact> contacts = body.map((dynamic item) => Contact.fromMap(item)).toList();
      return contacts;
    } else {
      throw Exception("Failed to load contacts");
    }
  }

  Future<void> insertContact(Contact contact) async {
    var response = await http.post(
      Uri.parse("$apiUrl/contacts"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(contact.toMap()), // Assuming Contact has a toJson method
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to insert contact");
    }
    print(jsonEncode(contact.toMap()));
  }
}



// class ContactDao {
//   Future<int> insertContact(Contact contact) async {

// }

//   Future<List<Contact>> getContacts() async {
//     final db = await DatabaseProvider.db.database;
//     final List<Map<String, dynamic>> maps = await db.query('contacts');
//     return List.generate(maps.length, (i) {
//       return Contact.fromMap(maps[i]);
//     });
//   }

//   Future<void> updateContact(Contact contact) async {
//     final db = await DatabaseProvider.db.database;
//     await db.update(
//       'contacts',
//       contact.toMap(),
//       where: 'id = ?',
//       whereArgs: [contact.id],
//     );
//   }

//   Future<void> deleteContact(int id) async {
//     final db = await DatabaseProvider.db.database;
//     await db.delete(
//       'contacts',
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }
// }

//   Future<List<Contact>> getContactsForEventDate(String date) async {
//     final db = await DatabaseProvider.db.database;
//     final List<Map<String, dynamic>> maps = await db.rawQuery(
//       'SELECT contacts.* FROM contacts '
//       'JOIN events ON contacts.id = events.contactId '
//       'WHERE events.eventDate = ?',
//       [date] // Ensure the date is in the correct format ('YYYY-MM-DD')
//     );
//     return List.generate(maps.length, (i) {
//       return Contact.fromMap(maps[i]);
//     });
//   }
