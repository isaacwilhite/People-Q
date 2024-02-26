class DraggableContact extends StatelessWidget {
  final Contact contact;

  DraggableContact({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Draggable<Contact>(
      data: contact,
      child: ContactWidget(contact: contact), // Your contact display widget
      feedback: Material(
        child: ContactWidget(contact: contact), // Widget to show while dragging
        elevation: 4.0,
      ),
      childWhenDragging: Container(), // Optional: Widget to display in place of the contact while it's being dragged
    );
  }
}
