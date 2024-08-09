import 'package:intl/intl.dart';
import '../models/event.dart';
import '../models/contact.dart';
import '../database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class EventDao {
final String apiUrl = "https://ahqampwcz1.execute-api.us-east-2.amazonaws.com/dev";
  Future<void> insertEvent(Event event) async {
    print(jsonEncode({
        'contactId': event.contactId,
        'eventDate': event.eventDate,
        'description': event.description,
      }));
    var response = await http.post(
      Uri.parse("$apiUrl/events"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'contactId': event.contactId,
        'eventDate': event.eventDate,
        'description': event.description,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to insert event");
    }
  }

}