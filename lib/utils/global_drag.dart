import 'package:flutter/material.dart';

class GlobalDragHandler {
  static final GlobalDragHandler _instance = GlobalDragHandler._internal();
  factory GlobalDragHandler() => _instance;

  GlobalDragHandler._internal();

  final PageController pageController = PageController(initialPage: 8);
  Offset? _dragPosition;
  BuildContext? _context;
  bool _isDragging = false;

  void handleDragUpdate(DragUpdateDetails details) {
    _dragPosition = details.globalPosition;
    _handlePageNavigation();
  }

  void _handlePageNavigation() {
    if (_dragPosition != null && _context != null) {
      final screenSize = MediaQuery.of(_context!).size;
      final edgeMargin = 80.0;

      if (_dragPosition!.dx > screenSize.width - edgeMargin) {
        if (!_isDragging) {
          _isDragging = true;
          pageController.nextPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.ease,
          ).then((_) => _isDragging = false);
        }
      } else if (_dragPosition!.dx < edgeMargin) {
        if (!_isDragging) {
          _isDragging = true;
          pageController.previousPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.ease,
          ).then((_) => _isDragging = false);
        }
      }
    }
  }

  void setContext(BuildContext context) {
    _context = context;
  }

  void clearContext() {
    _context = null;
    _dragPosition = null;
    _isDragging = false;
  }
}