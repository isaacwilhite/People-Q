import 'package:flutter/material.dart';
import 'package:people_q/db/models/contact.dart';
import 'package:people_q/utils/global_drag_state.dart';  // Ensure this is correctly imported

class CustomPageView extends StatefulWidget {
  final PageController controller;
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;

  CustomPageView({
    required this.controller,
    required this.itemBuilder,
    required this.itemCount,
  });

  @override
  _CustomPageViewState createState() => _CustomPageViewState();
}

class _CustomPageViewState extends State<CustomPageView> {
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: widget.controller,
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return Stack(
          children: [
            widget.itemBuilder(context, index),
            if (globalDragState.draggingContact != null)
              Positioned.fill(
                child: DragTarget<Contact>(
                  onWillAccept: (data) => true,
                  onAccept: (data) {
                    // Handle the drop event here
                  },
                  builder: (context, accepted, rejected) {
                    return Container();
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
