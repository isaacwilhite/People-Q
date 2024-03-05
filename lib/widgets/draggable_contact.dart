import 'package:flutter/material.dart';


class DraggableContactWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onDragToEdge;

  DraggableContactWidget({required this.child, required this.onDragToEdge});

  @override
  _DraggableContactWidgetState createState() => _DraggableContactWidgetState();
}

class _DraggableContactWidgetState extends State<DraggableContactWidget> {
  Offset _dragOffset = Offset.zero; // Tracks the position of the drag

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        // Initialize drag position
      },
      onPanUpdate: (details) {
        setState(() {
          _dragOffset += details.delta;
        });
        // Check if drag is near the edge of the screen
        final screenSize = MediaQuery.of(context).size;
        if (_dragOffset.dx > screenSize.width - 100) { // Threshold - 100px from the edge
          widget.onDragToEdge();
        }
      },
      onPanEnd: (details) {
        // Reset drag position or handle the end of the drag
        setState(() {
          _dragOffset = Offset.zero;
        });
      },
      child: widget.child,
    );
  }
}