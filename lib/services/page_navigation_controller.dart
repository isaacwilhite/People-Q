
import 'package:flutter/material.dart';

class PageNavigationController with ChangeNotifier {
  final PageController _pageController = PageController();

  PageController get controller => _pageController;

  void toPage(int page) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(page,
          duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  void nextPage() {
    if (_pageController.hasClients) {
      _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
    else {
      print('no clients');
    }
  }

  void previousPage() {
    if (_pageController.hasClients) {
      _pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }
}

