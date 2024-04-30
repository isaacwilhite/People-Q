import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/models/contact.dart';
import '../db/models/event.dart';
import '../db/dao/event_dao.dart';
import '../db/dao/contact_dao.dart';
import './bubble.dart';

// class DayView extends StatelessWidget {
//   final DateTime date;

//   DayView({required this.date});

//   @override
//   Widget build(BuildContext context) {
//     return DragTarget<Contact>(
//       onAcceptWithDetails: (contact) {
//         _showEventDetailsModal(context, contact as Contact, date);
//       },
//       builder: (context, candidateData, rejectedData) {
//         return Container(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             children: <Widget>[
//               Text(DateFormat("EEEE, MMMM d, yyyy").format(date), style: Theme.of(context).textTheme.titleLarge),
              
//             ],
//           ),
//         );
//       },
//     );
//   }
// void _showEventDetailsModal(BuildContext context, Contact contact, date) {
//   String description = ''; 

//   showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: Text('Add Event'),
//         content: TextField(
//           onChanged: (value) => description = value,
//           decoration: InputDecoration(hintText: "Event Description"),
//         ),
//         actions: <Widget>[
//           TextButton(
//             child: Text('Cancel'),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//           TextButton(
//             child: Text('Add'),
//             onPressed: () async {
//               Event newEvent = Event(
//                 eventDate: date,
//                 description: description,
//                 contactId: contact.id,
//               );
//               await EventDao().insertEvent(newEvent);
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       );
//     },
//   );
// }
// }
//   _showAddEventDialog(BuildContext context, Contact contact, DateTime date) {
//   TextEditingController descriptionController = TextEditingController();

//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: Text('Add Event'),
//       content: TextField(
//         controller: descriptionController,
//         decoration: InputDecoration(hintText: "Event Description"),
//       ),
//       actions: <Widget>[
//         TextButton(
//           child: Text('Cancel'),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         TextButton(
//           child: Text('Add'),
//           onPressed: () async {
//   // Ensure EventDao.insertEvent method accepts the necessary parameters
//   await EventDao().insertEvent(Event(
//     contactId: contact.id,
//     eventDate: DateFormat('yyyy-MM-dd').format(date), // Format date as string
//     description: descriptionController.text,
//   ));
//   Navigator.of(context).pop();
//           },
//         ),
//       ],
//     ),
//   );
// }

// }

  // @override
  // Widget build(BuildContext context) {
  //   // Use DateFormat to format the date as a string in 'yyyy-MM-dd' format
  //   String formattedDate = DateFormat('yyyy-MM-dd').format(date);

  //   return Center(
  //     child: FutureBuilder<List<Contact>>(
  //       // Use getContactsForEventDate to get contacts for events on this date
  //       future: EventDao().getContactsForEventDate(formattedDate),
  //       builder: (context, snapshot) {
  //         if (snapshot.connectionState == ConnectionState.waiting) {
  //           return CircularProgressIndicator();
  //         } else if (snapshot.hasError) {
  //           return Text("Error: ${snapshot.error}");
  //         } else if (snapshot.data == null || snapshot.data!.isEmpty) {
  //           return Text("No events for this day");
  //         } else {
  //           // Now, snapshot.data contains a list of Contact objects
  //           return ListView.builder(
  //             itemCount: snapshot.data!.length,
  //             itemBuilder: (context, index) {
  //               // Get each contact from the snapshot
  //               Contact contact = snapshot.data![index];
  //               // Use ContactTile to display each contact
  //               return ContactTile(contact: contact);
  //             },
  //           );
  //         }
  //       },
  //     ),
  //   );
  // }