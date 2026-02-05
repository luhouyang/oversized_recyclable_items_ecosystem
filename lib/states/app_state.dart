import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  bool isNavBarCollapsed = false;
  int bottomNavIndex = 0;

  void setNavBarCollapsed(bool val) {
    isNavBarCollapsed = val;
    notifyListeners();
  }

  void setBottomNavIndex(int idx) {
    bottomNavIndex = idx;
    notifyListeners();
  }
}