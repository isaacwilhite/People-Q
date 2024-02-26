import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/day_view.dart';
import '../db/models/contact.dart';
import '../db/models/event.dart';
import '../services/contact_service.dart';
import '../services/event_service.dart';

class WeekView extends StatefulWidget {
  @override
  _WeekViewState createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  PageController _pageController = PageController(initialPage: 0);
  DateTime _startDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemBuilder: (context, index) {
        DateTime date = _startDate.add(Duration(days: index));
        return DayView(date: date); // Your custom widget for each day
      },
      itemCount: 7, // Represents a week
    );
  }
}
