import 'package:flutter/material.dart';

class DateNavigator extends StatefulWidget {
  @override
  _DateNavigatorState createState() => _DateNavigatorState();
}

class _DateNavigatorState extends State<DateNavigator> {
  final PageController _pageController = PageController(initialPage: 7);
  final DateTime _today = DateTime.now();

  List<DateTime> getDates() {
    return List.generate(14, (index) => _today.subtract(Duration(days: 7 - index)));
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> dates = getDates();

    return Scaffold(
      appBar: AppBar(
        title: Text('Date Navigator'),
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            Navigator.pushNamed(context, '/home');
          },
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          return Center(
            child: Text(
              "${dates[index].day}-${dates[index].month}-${dates[index].year}",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}
