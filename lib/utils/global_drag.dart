import 'package:flutter/material.dart';
import '../db/models/contact.dart';


class GlobalDragState extends ChangeNotifier {
  bool _isDragging = false;
  Contact? _draggedContact;

  bool get isDragging => _isDragging;
  Contact? get draggedContact => _draggedContact;

  void startDrag(Contact contact) {
    _draggedContact = contact;
    _isDragging = true;
    notifyListeners();
  }

  void endDrag() {
    _draggedContact = null;
    _isDragging = false;
    notifyListeners();
  }
}
