import 'package:flutter/material.dart';
import 'package:people_q/db/models/contact.dart';

class ContactDetailsPage extends StatelessWidget {
  final Contact contact;

  ContactDetailsPage({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contact.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: contact.picturePath.isNotEmpty ? NetworkImage('https://image-bucket4c010-dev.s3.us-east-2.amazonaws.com/public/${contact.picturePath}') : null,
              child: contact.picturePath.isEmpty ? Icon(Icons.person, size: 50) : null,
            ),
            SizedBox(height: 16),
            Text('Name: ${contact.name}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            Text('Phone: ${contact.phoneNumber}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            Text('Bio: ${contact.bio}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            Text('Birthday: ${contact.birthday.toLocal()}'.split(' ')[0], style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
