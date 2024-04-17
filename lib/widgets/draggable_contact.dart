import 'package:flutter/material.dart';


class DraggableContactWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onDragToEdge;

  DraggableContactWidget({required this.child, required this.onDragToEdge});

  @override
  _DraggableContactWidgetState createState() => _DraggableContactWidgetState();
}

class _DraggableContactWidgetState extends State<DraggableContactWidget> {
  Offset _dragOffset = Offset.zero; 

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
      
      },
      onPanUpdate: (details) {
        setState(() {
          _dragOffset += details.delta;
        });
        
        final screenSize = MediaQuery.of(context).size;
        if (_dragOffset.dx > screenSize.width - 100) { 
          widget.onDragToEdge();
        }
      },
      onPanEnd: (details) {
        
        setState(() {
          _dragOffset = Offset.zero;
        });
      },
      child: widget.child,
    );
  }
}