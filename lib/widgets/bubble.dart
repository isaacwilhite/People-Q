import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:people_q/db/models/contact.dart';

class ContactBubble extends StatefulWidget {
  final Contact contact;
  final double initialSize;
  final Function(Contact) onTap;

  ContactBubble({required this.contact, required this.initialSize, required this.onTap});

  @override
  _ContactBubbleState createState() => _ContactBubbleState();
}

class _ContactBubbleState extends State<ContactBubble> {
  late double size;
  late double top;
  late double left;

  @override
  void initState() {
    super.initState();
    size = widget.initialSize;
    final random = Random();
    top = random.nextDouble() * 300;
    left = random.nextDouble() * 300;
    _startAnimation();
  }

  void _startAnimation() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        final random = Random();
        size = 40 + random.nextDouble() * 40;
        top = random.nextDouble() * 300;
        left = random.nextDouble() * 300;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 1000),
      top: top,
      left: left,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 1000),
        width: size,
        height: size,
        child: GestureDetector(
          onTap: () => widget.onTap(widget.contact),
          child: CircleAvatar(
            radius: size / 2,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: widget.contact.picturePath.isNotEmpty
                ? NetworkImage(widget.contact.picturePath)
                : null,
            child: widget.contact.picturePath.isEmpty
                ? Icon(Icons.person, size: size / 2)
                : null,
          ),
        ),
      ),
    );
  }
}