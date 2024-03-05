
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:people_q/db/models/contact.dart';
import 'package:provider/provider.dart';
import '../db/dao/contact_dao.dart';
import '../db/dao/event_dao.dart';
import '../db/models/event.dart';
import 'bubble.dart';
import 'contact_details.dart';


class WeekView extends StatefulWidget {
  @override
  _WeekViewState createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  // final PageController _pageController = PageController();
  final DateTime _today = DateTime.now();
  final DateFormat _dateFormat = DateFormat("EEEE, MMMM d, yyyy");

  @override
  Widget build(BuildContext context) {
    final PageController pageController = Provider.of<PageController>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Week View'),
      ),
      body: PageView.builder(
        controller: pageController,
        itemBuilder: (context, index) {
          DateTime pageDate = _today.add(Duration(days: index));
          return DatePage(date: pageDate);
        },
        itemCount: 7,
      ),
    );
  }
}

class DatePage extends StatelessWidget {
  final DateTime date;

  DatePage({required this.date});

  @override
  Widget build(BuildContext context) {
    final PageController pageController = Provider.of<PageController>(context);
        return DragTarget<Contact>(
          onWillAcceptWithDetails: (contact) => true,
      onAcceptWithDetails: (details) {
        Contact contact = details.data;
        _showEventDetailsModal(context, contact, date);
      },
      builder: (context, candidateData, rejectedData) {
    String dateString = date.toIso8601String();
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat("EEEE, MMMM d, yyyy").format(date)),
      ),
      body: FutureBuilder<List<Contact>>(
        future: getContactsForEventDate(dateString),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {

            return Center(child: Text('Error fetching events'));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(child: Text('No events found for this day'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final contact = snapshot.data![index];
                return GestureDetector(
    onDoubleTap: () {
      print("opening contact");
        _navigateToContactDetailsPage(context, contact);
      },
    child: ContactTile(contact: contact,
    pageController: pageController,
      onDragUpdate: _handleDragUpdate,),
  );
              },
            );
          }
        },
      ),
    );
      }
        );
  }
    void _navigateToContactDetailsPage(BuildContext context, Contact contact) {
  // Assuming you have a ContactDetailsPage that takes a Contact object
  Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => ContactDetailsPage(contact: contact),
  ));
}
void _handleDragUpdate(DragUpdateDetails details,) {
  // Accessing PageNavigationController from Provider
  final pageController = Provider.of<PageController>(context, listen: false);
  final screenSize = MediaQuery.of(context).size;
  final positionFromRightEdge = screenSize.width - details.globalPosition.dx;
  final positionFromLeftEdge = details.globalPosition.dx;
  if (!pageController.hasClients) return;

  if (positionFromRightEdge < 50.0) {
    pageController.nextPage( duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  } 
  // else if (positionFromLeftEdge < 50.0) {
  //   pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  // }
}
}

void _showEventDetailsModal(BuildContext context, Contact contact, date) {
  String description = ''; // To capture the user input

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Add Event'),
        content: TextField(
          onChanged: (value) => description = value,
          decoration: InputDecoration(hintText: "Event Description"),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Add'),
            onPressed: () async {
              // Assuming Event class has a constructor that takes date, description, and contactId
              Event newEvent = Event(
                eventDate: date, // Format the date as needed
                description: description,
                contactId: contact.id, // Assuming 'contact' has an 'id' field
              );
              await EventDao().insertEvent(newEvent);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}