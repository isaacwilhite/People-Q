
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
// import 'package:sqflite/sqflite.dart';
import '../models/contact.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:amplify_flutter/amplify_flutter.dart';

class ContactDAO {
  final String apiUrl = "https://ahqampwcz1.execute-api.us-east-2.amazonaws.com/dev";

  Future<List<Contact>> fetchContacts(String userId) async {
    // print(userId);
    var response = await http.get(Uri.parse("$apiUrl/contacts/$userId"));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Contact> contacts = body.map((dynamic item) => Contact.fromMap(item)).toList();
      return contacts;
    } else {
      throw Exception("Failed to load contacts");
    }
  }

    Future<List<Contact>> fetchContactsByEventDate(String eventDate) async {
    var response = await http.get(Uri.parse("$apiUrl/contactsByEventDate?eventDate=$eventDate"));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Contact> contacts = body.map((dynamic item) => Contact.fromMap(item)).toList();
      return contacts;
    } else {
      throw Exception("Failed to load contacts for event date");
    }
  }

  Future<void> insertContact(Contact contact) async {
    var response = await http.post(
      Uri.parse("$apiUrl/contacts"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'userId': contact.userId,
        'name': contact.name,
        'phoneNumber': contact.phoneNumber,
        'bio': contact.bio,
        'picturePath': contact.picturePath,
        'birthday': contact.birthday.toIso8601String(), // Formatting DateTime here
      }),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to insert contact");
    }
  }
}
