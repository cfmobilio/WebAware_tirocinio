import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilityViewModel extends ChangeNotifier {
  bool _isHighContrast = false;
  bool _isLargeText = false;

  bool get isHighContrast => _isHighContrast;
  bool get isLargeText => _isLargeText;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isHighContrast = prefs.getBool('accessibility_mode') ?? false;
    _isLargeText = prefs.getBool('large_text') ?? false;
    notifyListeners();
  }

  Future<void> toggleHighContrast(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    _isHighContrast = enabled;
    await prefs.setBool('accessibility_mode', enabled);
    notifyListeners();
  }

  Future<void> toggleLargeText(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    _isLargeText = enabled;
    await prefs.setBool('large_text', enabled);
    notifyListeners();
  }
}
