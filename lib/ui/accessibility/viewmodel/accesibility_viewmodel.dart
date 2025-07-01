import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilityViewModel extends ChangeNotifier {
  bool _isHighContrast = false;

  bool get isHighContrast => _isHighContrast;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isHighContrast = prefs.getBool('accessibility_mode') ?? false;
    notifyListeners();
  }

  Future<void> toggleHighContrast(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    _isHighContrast = enabled;
    await prefs.setBool('accessibility_mode', enabled);
    notifyListeners();
  }
}
