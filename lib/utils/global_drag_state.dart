import 'package:flutter/material.dart';
import 'package:people_q/db/models/contact.dart';

class GlobalDragState extends ChangeNotifier {
  Contact? draggingContact;

  void startDragging(Contact contact) {
    draggingContact = contact;
    notifyListeners();
  }

  void stopDragging() {
    draggingContact = null;
    notifyListeners();
  }
}

final globalDragState = GlobalDragState();
