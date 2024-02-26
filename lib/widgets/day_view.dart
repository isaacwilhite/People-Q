import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/models/contact.dart'

class DayView extends StatelessWidget {
  final DateTime date;

  DayView({required this.date});

  @override
Widget build(BuildContext context) {
    return DragTarget<Contact>(
      onWillAcceptWithDetails: (data) => true,
      onAcceptWithDetails: (data) {
        // Handle the accepted contact, such as creating an event
      },
      builder: (context, candidateData, rejectedData) {
        return Center(
          child: Text(DateFormat('yyyy-MM-dd').format(date)),
          // Optionally, display events/contacts for this day
        );
      },
    );
  }
}
