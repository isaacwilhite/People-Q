import 'package:flutter/material.dart';
import 'package:people_q/db/models/contact.dart';

class CustomDraggable extends StatefulWidget {
  final Widget child;
  final Contact data;
  final PageController pageController;
  final Function() onNavigateToToday;

  CustomDraggable({
    required this.child,
    required this.data,
    required this.pageController,
    required this.onNavigateToToday,
  });

  @override
  _CustomDraggableState createState() => _CustomDraggableState();
}

class _CustomDraggableState extends State<CustomDraggable> {
  bool _dragging = false;
  Offset _position = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          _dragging = true;
          _position = details.localPosition;
        });
      },
      onPanUpdate: (details) {
        setState(() {
          _position += details.delta;
        });

        final screenSize = MediaQuery.of(context).size;
        final edgeMargin = 20.0;

        if (_position.dx > screenSize.width - edgeMargin) {
          if (widget.pageController.page == 0) {
            widget.onNavigateToToday();
          } else {
            widget.pageController.nextPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          }
        } else if (_position.dx < edgeMargin) {
          widget.pageController.previousPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        }
      },
      onPanEnd: (details) {
        setState(() {
          _dragging = false;
          _position = Offset.zero;
        });
      },
      child: Draggable<Contact>(
        data: widget.data,
        feedback: Material(
          child: widget.child,
        ),
        childWhenDragging: Container(),
        child: _dragging
            ? Container()
            : Transform.translate(
                offset: _position,
                child: widget.child,
              ),
      ),
    );
  }
}
