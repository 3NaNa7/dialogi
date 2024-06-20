import 'package:flutter/material.dart';

class UsersMuteList with ChangeNotifier {
  bool _isUserAdded = true;

  bool get isUserAdded => _isUserAdded;
  void userAdded(value) {
    _isUserAdded = value;
    notifyListeners();
  }
}
