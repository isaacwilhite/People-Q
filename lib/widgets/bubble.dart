import 'package:flutter/material.dart';
import '../db/models/contact.dart';
import '../screens/week_view_screen.dart';
import '../services/page_navigation_controller.dart';


class ContactTile extends StatelessWidget {
  final Contact contact;
  final PageController pageController;
  final Function(DragUpdateDetails) onDragUpdate;

  ContactTile({Key? key, required this.contact, required this.pageController, required this.onDragUpdate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<Contact>(
      data: contact,
      feedback: Material(
        child: SizedBox(width: 200, height: 60, child: ContactTile(contact: contact, pageController: pageController, onDragUpdate: onDragUpdate,)),
        elevation: 4.0,
      ),
      onDragUpdate: onDragUpdate,
      child: ListTile(
        leading: CircleAvatar(
          child: Text(contact.name[0]), // Assuming 'name' is a field in your Contact model
        ),
        title: Text(contact.name),
        subtitle: Text(contact.phoneNumber),
      ),
    );
  }
}

// class CustomDraggableTile extends StatefulWidget {
//   final Contact contact;

//   const CustomDraggableTile({Key? key, required this.contact}) : super(key: key);

//   @override
//   _CustomDraggableTileState createState() => _CustomDraggableTileState();
// }

// class _CustomDraggableTileState extends State<CustomDraggableTile> {
//   OverlayEntry? _floatingTile;
//   final LayerLink _layerLink = LayerLink();
//   Offset _offset = Offset.zero;

//   void _showFloatingTile(BuildContext context, Offset startPosition) {
//     _floatingTile = OverlayEntry(
//       builder: (context) {
//         return Positioned(
//           left: startPosition.dx + _offset.dx - 75,
//           top: startPosition.dy + _offset.dy - 25,
//           child: CompositedTransformFollower(
//             link: _layerLink,
//             showWhenUnlinked: false,
//             offset: _offset,
//             child: Material(
//               elevation: 6,
//               child: SizedBox(
//                 width: 150,
//                 height: 50,
//                 child: Card(
//                   child: ListTile(
//                     leading: Icon(Icons.person),
//                     title: Text(widget.contact.name),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );

//     Overlay.of(context)!.insert(_floatingTile!);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CompositedTransformTarget(
//       link: _layerLink,
//       child: GestureDetector(
//         onLongPressStart: (details) {
//           _offset = Offset.zero; // Reset offset
//           _showFloatingTile(context, details.globalPosition);
//         },
//         onPanUpdate: (details) {
//           setState(() {
//             _offset += details.delta;
//           });
//           // Update the position dynamically
//           _floatingTile?.markNeedsBuild();
//         },
//         onPanEnd: (details) {
//           _removeFloatingTile();
//         },
//         child: Card(
//           child: ListTile(
//             leading: Icon(Icons.person),
//             title: Text(widget.contact.name),
//           ),
//         ),
//       ),
//     );
//   }

//   void _removeFloatingTile() {
//     _floatingTile?.remove();
//     _floatingTile = null;
//   }
// }






// class ContactTile extends StatefulWidget {
//   final Contact contact;

//   const ContactTile({Key? key, required this.contact}) : super(key: key);

//   @override
//   _ContactTileState createState() => _ContactTileState();
// }

// class _ContactTileState extends State<ContactTile> {
//   Offset _dragOffset = Offset.zero; // To track the drag position

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onPanUpdate: (details) {
//         setState(() {
//           _dragOffset += details.delta;
//         });
//           print('dragging');
//         // Implement edge detection logic here
//         final screenSize = MediaQuery.of(context).size;
//         if (_dragOffset.dx > screenSize.width - 100) { // Example edge detection logic
//           // Trigger navigation or other action
//           print("navigate to week view");
//           Navigator.push(context, MaterialPageRoute(builder: (context) => WeekView()));
//         }
//       },
//       onPanEnd: (details) {
//         // Reset the drag offset to prevent accidental triggers when starting a new drag
//         setState(() {
//           _dragOffset = Offset.zero;
//         });
//       },
//       child: LongPressDraggable<Contact>(
//         data: widget.contact,
//         feedback: Material(
//           child: SizedBox(
//             width: 300,
//             height: 75,
//             child: Card(
//               child: ListTile(
//                 leading: Icon(Icons.person),
//                 title: Text(widget.contact.name),
//               ),
//             ),
//           ),
//           elevation: 4.0,
//         ),
//         child: Card(
//           child: ListTile(
//             leading: Icon(Icons.person),
//             title: Text(widget.contact.name),
//           ),
//         ),
//         childWhenDragging: Container(),
//       ),
//     );
//   }
// }
