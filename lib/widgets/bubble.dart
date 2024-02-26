import 'package:flutter/material.dart';
import '../db/models/contact.dart';

class ContactTile extends StatelessWidget {
  final Contact contact;

  const ContactTile({Key? key, required this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        // Display the first letter of the name as a placeholder
        child: Text(contact.name[0]),
        backgroundColor: Colors.blue,
      ),
      title: Text(contact.name),
      subtitle: Text(contact.phoneNumber),
      // Add more details or an onTap action as needed
    );
  }
}