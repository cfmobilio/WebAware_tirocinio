import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilityViewModel extends ChangeNotifier {
  bool _isHighContrast = false;
  bool _isLargeText = false;
  bool _isTtsEnabled = false;
  bool _isAutoReadEnabled = false;
  bool _isLoading = false;
  bool _isInitialized = false;

  // Chiavi costanti per SharedPreferences
  static const String _keyHighContrast = 'accessibility_high_contrast';
  static const String _keyLargeText = 'accessibility_large_text';
  static const String _keyTtsEnabled = 'accessibility_tts_enabled';
  static const String _keyAutoRead = 'accessibility_auto_read';

  bool get isHighContrast => _isHighContrast;
  bool get isLargeText => _isLargeText;
  bool get isTtsEnabled => _isTtsEnabled;
  bool get isAutoReadEnabled => _isAutoReadEnabled;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  /// Carica le impostazioni salvate
  Future<void> loadSettings() async {
    if (_isInitialized) return; // Evita caricamenti multipli

    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();

      _isHighContrast = prefs.getBool(_keyHighContrast) ?? false;
      _isLargeText = prefs.getBool(_keyLargeText) ?? false;
      _isTtsEnabled = prefs.getBool(_keyTtsEnabled) ?? false;
      _isAutoReadEnabled = prefs.getBool(_keyAutoRead) ?? false;

      _isInitialized = true;

    } catch (e) {
      return;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveSetting(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleHighContrast(bool enabled) async {
    if (_isHighContrast == enabled) return;

    _isHighContrast = enabled;
    notifyListeners();

    try {
      await _saveSetting(_keyHighContrast, enabled);
    } catch (e) {
      _isHighContrast = !enabled;
      notifyListeners();
    }
  }

  Future<void> toggleLargeText(bool enabled) async {
    if (_isLargeText == enabled) return;

    _isLargeText = enabled;
    notifyListeners();

    try {
      await _saveSetting(_keyLargeText, enabled);
    } catch (e) {
      _isLargeText = !enabled;
      notifyListeners();
    }
  }

  Future<void> toggleTts(bool enabled) async {
    if (_isTtsEnabled == enabled) return;

    _isTtsEnabled = enabled;

    if (!enabled && _isAutoReadEnabled) {
      _isAutoReadEnabled = false;
    }

    notifyListeners();

    try {
      await _saveSetting(_keyTtsEnabled, enabled);

      if (!enabled && _isAutoReadEnabled) {
        await _saveSetting(_keyAutoRead, false);
      }

    } catch (e) {
      _isTtsEnabled = !enabled;
      notifyListeners();
    }
  }

  Future<void> toggleAutoRead(bool enabled) async {
    if (_isAutoReadEnabled == enabled) return;

    if (enabled && !_isTtsEnabled) {
      return;
    }

    _isAutoReadEnabled = enabled;
    notifyListeners();

    try {
      await _saveSetting(_keyAutoRead, enabled);
    } catch (e) {
      // Rollback in caso di errore
      _isAutoReadEnabled = !enabled;
      notifyListeners();
    }
  }

  Future<void> resetAllSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _isHighContrast = false;
      _isLargeText = false;
      _isTtsEnabled = false;
      _isAutoReadEnabled = false;

      await prefs.setBool(_keyHighContrast, false);
      await prefs.setBool(_keyLargeText, false);
      await prefs.setBool(_keyTtsEnabled, false);
      await prefs.setBool(_keyAutoRead, false);

      notifyListeners();
    } catch (e) {
      return;
    }
  }

  Map<String, bool> getSettingsSummary() {
    return {
      'Alto Contrasto': _isHighContrast,
      'Testo Ingrandito': _isLargeText,
      'TTS Abilitato': _isTtsEnabled,
      'Auto-lettura': _isAutoReadEnabled,
    };
  }

  Future<bool> isPreferencesAvailable() async {
    try {
      await SharedPreferences.getInstance();
      return true;
    } catch (e) {
      return false;
    }
  }

  ThemeData getTheme() {
    final primaryColor = _isHighContrast ? Colors.yellow : Colors.deepOrange;
    final backgroundColor = _isHighContrast ? Colors.black : Colors.white;
    final textColor = _isHighContrast ? Colors.white : Colors.black;
    final cardColor = _isHighContrast ? Colors.grey[900]! : Colors.grey[100]!;
    final surfaceColor = _isHighContrast ? Colors.grey[800]! : Colors.white;

    final textScaleFactor = _isLargeText ? 1.3 : 1.0;

    return ThemeData(
      brightness: _isHighContrast ? Brightness.dark : Brightness.light,

      colorScheme: ColorScheme(
        brightness: _isHighContrast ? Brightness.dark : Brightness.light,
        primary: primaryColor,
        onPrimary: _isHighContrast ? Colors.black : Colors.white,
        secondary: primaryColor,
        onSecondary: _isHighContrast ? Colors.black : Colors.white,
        error: _isHighContrast ? Colors.red[400]! : Colors.red,
        onError: Colors.white,
        surface: surfaceColor,
        onSurface: textColor,
        background: backgroundColor,
        onBackground: textColor,
      ),

      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32 * textScaleFactor,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        displayMedium: TextStyle(
          fontSize: 28 * textScaleFactor,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        displaySmall: TextStyle(
          fontSize: 24 * textScaleFactor,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        headlineLarge: TextStyle(
          fontSize: 22 * textScaleFactor,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 20 * textScaleFactor,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        headlineSmall: TextStyle(
          fontSize: 18 * textScaleFactor,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        titleLarge: TextStyle(
          fontSize: 16 * textScaleFactor,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        titleMedium: TextStyle(
          fontSize: 14 * textScaleFactor,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        titleSmall: TextStyle(
          fontSize: 12 * textScaleFactor,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16 * textScaleFactor,
          color: textColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14 * textScaleFactor,
          color: textColor,
        ),
        bodySmall: TextStyle(
          fontSize: 12 * textScaleFactor,
          color: textColor,
        ),
        labelLarge: TextStyle(
          fontSize: 14 * textScaleFactor,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        labelMedium: TextStyle(
          fontSize: 12 * textScaleFactor,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        labelSmall: TextStyle(
          fontSize: 10 * textScaleFactor,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: _isHighContrast ? Colors.black : Colors.deepOrange,
        foregroundColor: _isHighContrast ? Colors.white : Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20 * textScaleFactor,
          fontWeight: FontWeight.bold,
          color: _isHighContrast ? Colors.white : Colors.white,
        ),
        iconTheme: IconThemeData(
          color: _isHighContrast ? Colors.white : Colors.white,
          size: 24 * textScaleFactor,
        ),
        elevation: 2,
        centerTitle: true,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: _isHighContrast ? Colors.black : Colors.white,
          textStyle: TextStyle(
            fontSize: 16 * textScaleFactor,
            fontWeight: FontWeight.bold,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 20 * textScaleFactor,
            vertical: 12 * textScaleFactor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 2),
          textStyle: TextStyle(
            fontSize: 16 * textScaleFactor,
            fontWeight: FontWeight.bold,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 20 * textScaleFactor,
            vertical: 12 * textScaleFactor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: cardColor,
        elevation: _isHighContrast ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: _isHighContrast
              ? BorderSide(color: Colors.yellow, width: 2)
              : BorderSide.none,
        ),
        margin: const EdgeInsets.all(8),
      ),

      listTileTheme: ListTileThemeData(
        textColor: textColor,
        iconColor: primaryColor,
        tileColor: surfaceColor,
        titleTextStyle: TextStyle(
          fontSize: 16 * textScaleFactor,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14 * textScaleFactor,
          color: textColor.withOpacity(0.7),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * textScaleFactor,
          vertical: 8 * textScaleFactor,
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _isHighContrast ? Colors.black : Colors.white;
          }
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.grey.withOpacity(0.5);
        }),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _isHighContrast ? Colors.grey[800] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
        ),
        labelStyle: TextStyle(
          color: textColor,
          fontSize: 14 * textScaleFactor,
        ),
        hintStyle: TextStyle(
          color: textColor.withOpacity(0.6),
          fontSize: 14 * textScaleFactor,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12 * textScaleFactor,
          vertical: 16 * textScaleFactor,
        ),
      ),

      iconTheme: IconThemeData(
        color: primaryColor,
        size: 24 * textScaleFactor,
      ),

      scaffoldBackgroundColor: backgroundColor,

      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        titleTextStyle: TextStyle(
          fontSize: 20 * textScaleFactor,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        contentTextStyle: TextStyle(
          fontSize: 16 * textScaleFactor,
          color: textColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Tema per tutti i BottomSheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),

      // Tema per tutti i Drawer
      drawerTheme: DrawerThemeData(
        backgroundColor: surfaceColor,
      ),

      // Tema per tutti i TabBar
      tabBarTheme: TabBarThemeData(
        labelColor: primaryColor,
        unselectedLabelColor: textColor.withOpacity(0.7),
        labelStyle: TextStyle(
          fontSize: 14 * textScaleFactor,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14 * textScaleFactor,
          fontWeight: FontWeight.normal,
        ),
      ),

      // Tema per tutti i FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: _isHighContrast ? Colors.black : Colors.white,
      ),

      // Tema per tutte le CheckBox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(
          _isHighContrast ? Colors.black : Colors.white,
        ),
      ),

      // Tema per tutti i RadioButton
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return textColor.withOpacity(0.6);
        }),
      ),
    );
  }
}