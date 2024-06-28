import 'package:flutter/material.dart';
import 'package:people_q/db/models/contact.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactDetailsPage extends StatelessWidget {
  final Contact contact;

  ContactDetailsPage({required this.contact});

    @override
  Widget build(BuildContext context) {
    String imageUrl = 'https://image-bucket4c010-dev.s3.us-east-2.amazonaws.com/public/${contact.picturePath}';
    String formattedBirthday = DateFormat('MMMM d, yyyy').format(contact.birthday);  // Format the birthday

       return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Q Card', style: TextStyle(color: Colors.black)),
          actions: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.black),
              onPressed: () {
                // Handle edit action
              },
            ),
          ],
        ),
        CircleAvatar(
          radius: 50,
          backgroundImage: contact.picturePath.isNotEmpty ? NetworkImage(imageUrl) : null,
          child: contact.picturePath.isEmpty ? Icon(Icons.person, size: 50) : null,
        ),
        SizedBox(height: 16),
        Text(
          'Birthday: $formattedBirthday',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        SizedBox(height: 8),
        Text(
          contact.name,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          contact.bio,
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                _sendMessage(contact.phoneNumber);
              },
              icon: Icon(Icons.message),
              label: Text('Message'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                _makeCall(contact.phoneNumber);
              },
              icon: Icon(Icons.call),
              label: Text('Call'),
            ),
          ],
        ),
      ],
    );
  }

  void _sendMessage(String phoneNumber) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
    );
    if (await canLaunch(smsUri.toString())) {
      await launch(smsUri.toString());
    } else {
      print('Could not launch $smsUri');
    }
  }

  void _makeCall(String phoneNumber) async {
    final Uri telUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunch(telUri.toString())) {
      await launch(telUri.toString());
    } else {
      print('Could not launch $telUri');
    }
  }
}