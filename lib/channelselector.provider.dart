import 'package:flutter/material.dart';

class ToneGen extends ChangeNotifier {
  int _selectedChannel = 0;
 final int _frequency = 5000;
  int _burstdurations = 5;

  int get selectedChannel => _selectedChannel;
  int get frequency => _frequency;
  int get burstdurations => _burstdurations;
  set selectedChannel(int newValue) {
    _selectedChannel = newValue;
    notifyListeners();
  }
  set burstdurations(int newValue) {
    _burstdurations = newValue;
    notifyListeners();
  }
}
