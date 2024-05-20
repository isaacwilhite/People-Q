import 'dart:math';
import 'package:flutter/material.dart';
import 'package:people_q/db/models/contact.dart';
import 'package:people_q/widgets/contact_details.dart';

class ContactsPage extends StatelessWidget {
  final Future<List<Contact>>? contactsFuture;
  final Function(Contact) onContactDropped;
  final PageController pageController;

  ContactsPage({
    required this.contactsFuture,
    required this.onContactDropped,
    required this.pageController,
  });

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
                      height: MediaQuery.of(context).size.height * 2, // Allow scrolling
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

    double xOffset = 0;
    double yOffset = 0;
    double rowHeight = 0;
    double totalRowWidth = 0;
    double horizontalMargin = 20.0; // Margin from screen edges
    List<Widget> rowBubbles = [];

    for (var contact in contacts) {
      double size = random.nextDouble() * 60 + 80; // Radius range 60 to 120
      double radius = size / 2;

      if (xOffset + size > screenWidth - 2 * horizontalMargin) {
        // Center the row
        double startX = (screenWidth - totalRowWidth) / 2 + horizontalMargin;
        for (var bubble in rowBubbles) {
          Positioned positionedBubble = bubble as Positioned;
          bubbles.add(Positioned(
            top: positionedBubble.top,
            left: positionedBubble.left! + startX,
            child: positionedBubble.child!,
          ));
        }

        // Move to the next row
        rowBubbles.clear();
        xOffset = 0;
        yOffset += rowHeight + 40; // Add spacing between rows
        rowHeight = 0;
        totalRowWidth = 0;
      }

      if (yOffset + size > screenHeight * 2) {
        // If the screen is filled, stop adding more bubbles
        break;
      }

      rowHeight = max(rowHeight, size);
      totalRowWidth += size + 40; // Include spacing between bubbles

      double topVariation = random.nextDouble() * (rowHeight / 2); // Variation in vertical placement
      double top = yOffset + topVariation;
      double left = xOffset + random.nextDouble() * (screenWidth / 4 - size);

      // Ensure the bubble doesn't touch the edges
      left = max(horizontalMargin, left);
      left = min(screenWidth - horizontalMargin - size, left);

      xOffset += size + 40; // Move xOffset for the next bubble

      String imageUrl = 'https://image-bucket4c010-dev.s3.us-east-2.amazonaws.com/public/${contact.picturePath}';

       rowBubbles.add(
        Positioned(
          top: top,
          left: left,
          child: Draggable<Contact>(
            data: contact,
            feedback: Material(
              color: Colors.transparent,
              child: CircleAvatar(
                radius: radius,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: contact.picturePath.isNotEmpty ? NetworkImage(imageUrl) : null,
                child: contact.picturePath.isEmpty ? Icon(Icons.person, size: radius) : null,
              ),
            ),
            childWhenDragging: Container(),
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
                radius: radius,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: contact.picturePath.isNotEmpty ? NetworkImage(imageUrl) : null,
                child: contact.picturePath.isEmpty ? Icon(Icons.person, size: radius) : null,
              ),
            ),
            onDragStarted: () {
              print('Dragging ${contact.name}');
            },
            onDragUpdate: (details) {
              final screenSize = MediaQuery.of(context).size;
              final edgeMargin = 80.0;

              if (details.globalPosition.dx > screenSize.width - edgeMargin) {
                if (pageController.page == 0) {
                  pageController.jumpToPage(8); // Navigate to today's date
                } else {
                  pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                }
              } else if (details.globalPosition.dx < edgeMargin) {
                pageController.previousPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              }
            },
            onDragEnd: (details) {
              // Triggered when the drag ends, handle the logic if needed.
            },
          ),
        ),
      );
    }
    // Center the last row
    double startX = (screenWidth - totalRowWidth) / 2 + horizontalMargin;
    for (var bubble in rowBubbles) {
      Positioned positionedBubble = bubble as Positioned;
      bubbles.add(Positioned(
        top: positionedBubble.top,
        left: positionedBubble.left! + startX,
        child: positionedBubble.child!,
      ));
    }

    return bubbles;
  }
}
