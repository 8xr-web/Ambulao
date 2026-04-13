import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  final String _greeting = 'Hello World!';
  String get greeting => _greeting;

  bool _isExpanded = false;
  bool get isExpanded => _isExpanded;

  void toggleExpanded() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }
}
