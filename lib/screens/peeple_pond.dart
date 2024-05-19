import 'dart:math';
import 'package:flutter/material.dart';
import 'package:people_q/db/models/contact.dart';
import 'package:people_q/widgets/contact_details.dart';

class ContactsPage extends StatelessWidget {
  final Future<List<Contact>>? contactsFuture;

  ContactsPage({required this.contactsFuture});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
      ),
      body: FutureBuilder<List<Contact>>(
        future: contactsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching contacts'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No contacts found'));
          } else {
            return Container(
              padding: EdgeInsets.all(8.0),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Stack(
                        children: _buildContactBubbles(context, snapshot.data!),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  List<Widget> _buildContactBubbles(BuildContext context, List<Contact> contacts) {
    final List<Widget> bubbles = [];
    final random = Random();
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    List<Map<String, double>> positions = [];

    for (var contact in contacts) {
      double size = random.nextDouble() * 60 + 50; // Increase the size range (80 to 160)
      double top, left;
      bool hasOverlap;

      do {
        hasOverlap = false;
        top = random.nextDouble() * (screenHeight - size);
        left = random.nextDouble() * (screenWidth - size);

        for (var position in positions) {
          double dx = position['left']! - left;
          double dy = position['top']! - top;
          double distance = sqrt(dx * dx + dy * dy);

          if (distance < (position['size']! / 2 + size / 2 + 10)) { // 10 is the minimum spacing between bubbles
            hasOverlap = true;
            break;
          }
        }
      } while (hasOverlap);

      positions.add({'left': left, 'top': top, 'size': size});

      String imageUrl = 'https://image-bucket4c010-dev.s3.us-east-2.amazonaws.com/public/${contact.picturePath}';

      bubbles.add(
        Positioned(
          top: top,
          left: left,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactDetailsPage(contact: contact),
                ),
              );
            },
            child: CircleAvatar(
              radius: size / 2,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: contact.picturePath.isNotEmpty ? NetworkImage(imageUrl) : null,
              child: contact.picturePath.isEmpty ? Icon(Icons.person, size: size / 2) : null,
            ),
          ),
        ),
      );
    }
    return bubbles;
  }
}
