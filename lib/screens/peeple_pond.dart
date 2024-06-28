import 'dart:math';
import 'package:flutter/material.dart';
import 'package:people_q/db/models/contact.dart';
import 'package:people_q/widgets/contact_details.dart';
import 'package:people_q/utils/global_drag.dart';  // Import the global drag handler

class ContactsPage extends StatefulWidget {
  final Future<List<Contact>>? contactsFuture;
  final Function(Contact) onContactDropped;
  final PageController pageController;

  ContactsPage({
    required this.contactsFuture,
    required this.onContactDropped,
    required this.pageController,
  });

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final GlobalDragHandler _globalDragHandler = GlobalDragHandler();

  @override
  void initState() {
    super.initState();
    _globalDragHandler.setContext(context);
  }

  @override
  void dispose() {
    _globalDragHandler.clearContext();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Peeple Pond',
              style: TextStyle(
                fontSize: 36, // Set the desired font size
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Contact>>(
        future: widget.contactsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching contacts'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No contacts found'));
          } else {
            return GestureDetector(
              onHorizontalDragUpdate: _globalDragHandler.handleDragUpdate,
              child: Container(
                padding: EdgeInsets.all(8.0),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 2,
                        child: Stack(
                          children: _buildContactBubbles(context, snapshot.data!),
                        ),
                      ),
                    ),
                  ],
                ),
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
    double horizontalMargin = 5.0; // Margin from screen edges
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
          child: _buildDraggableContact(context, contact, radius, imageUrl),
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

 Widget _buildDraggableContact(BuildContext context, Contact contact, double radius, String imageUrl) {
  return LongPressDraggable<Contact>(
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
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (BuildContext context) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.85,
              maxChildSize: 0.95,
              minChildSize: 0.3,
              builder: (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: ContactDetailsPage(contact: contact),
                  ),
                );
              },
            );
          },
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
        _globalDragHandler.setContext(context);
      },
      onDragUpdate: (details) {
        _globalDragHandler.handleDragUpdate(details);
      },
      onDragEnd: (details) {
        _globalDragHandler.clearContext();
      },
    );
  }
}
