import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilityViewModel extends ChangeNotifier {
  bool _isHighContrast = false;
  bool _isLargeText = false;
  bool _isTtsEnabled = false;
  bool _isAutoReadEnabled = false;

  bool get isHighContrast => _isHighContrast;
  bool get isLargeText => _isLargeText;
  bool get isTtsEnabled => _isTtsEnabled;
  bool get isAutoReadEnabled => _isAutoReadEnabled;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isHighContrast = prefs.getBool('accessibility_mode') ?? false;
    _isLargeText = prefs.getBool('large_text') ?? false;
    _isTtsEnabled = prefs.getBool('tts_enabled') ?? false;
    _isAutoReadEnabled = prefs.getBool('auto_read_enabled') ?? false;
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

  Future<void> toggleTts(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    _isTtsEnabled = enabled;
    await prefs.setBool('tts_enabled', enabled);
    notifyListeners();
  }

  Future<void> toggleAutoRead(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    _isAutoReadEnabled = enabled;
    await prefs.setBool('auto_read_enabled', enabled);
    notifyListeners();
  }

  /// TEMA COMPLETO CHE SI APPLICA AUTOMATICAMENTE A TUTTA L'APP
  ThemeData getTheme() {
    // Colori base
    final primaryColor = _isHighContrast ? Colors.yellow : Colors.deepOrange;
    final backgroundColor = _isHighContrast ? Colors.black : Colors.white;
    final textColor = _isHighContrast ? Colors.white : Colors.black;
    final cardColor = _isHighContrast ? Colors.grey[900]! : Colors.grey[100]!;
    final surfaceColor = _isHighContrast ? Colors.grey[800]! : Colors.white;

    // Moltiplicatore per le dimensioni del testo
    final textScaleFactor = _isLargeText ? 1.25 : 1.0;

    return ThemeData(
      // Tema di base
      brightness: _isHighContrast ? Brightness.dark : Brightness.light,

      // Schema colori che viene applicato OVUNQUE automaticamente
      colorScheme: ColorScheme(
        brightness: _isHighContrast ? Brightness.dark : Brightness.light,
        primary: primaryColor,
        onPrimary: _isHighContrast ? Colors.black : Colors.white,
        secondary: primaryColor,
        onSecondary: _isHighContrast ? Colors.black : Colors.white,
        error: Colors.red,
        onError: Colors.white,
        surface: surfaceColor,
        onSurface: textColor,
      ),

      // Tema per tutti i testi dell'app
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

      // Tema AppBar - si applica a TUTTE le AppBar automaticamente
      appBarTheme: AppBarTheme(
        backgroundColor: _isHighContrast ? Colors.black : Colors.deepOrange,
        foregroundColor: _isHighContrast ? Colors.white : Colors.black,
        titleTextStyle: TextStyle(
          fontSize: 24 * textScaleFactor,
          fontWeight: FontWeight.bold,
          color: _isHighContrast ? Colors.white : Colors.black,
        ),
        iconTheme: IconThemeData(
          color: _isHighContrast ? Colors.white : Colors.black,
          size: 24 * textScaleFactor,
        ),
        elevation: 2,
        centerTitle: true,
      ),

      // Tema per tutti i pulsanti ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: _isHighContrast ? Colors.black : Colors.white,
          textStyle: TextStyle(
            fontSize: 16 * textScaleFactor,
            fontWeight: FontWeight.bold,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 16 * textScaleFactor,
            vertical: 12 * textScaleFactor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Tema per tutti i pulsanti OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 2),
          textStyle: TextStyle(
            fontSize: 16 * textScaleFactor,
            fontWeight: FontWeight.bold,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 16 * textScaleFactor,
            vertical: 12 * textScaleFactor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Tema per tutte le Card
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: _isHighContrast ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: _isHighContrast
              ? const BorderSide(color: Colors.yellow, width: 2)
              : BorderSide.none,
        ),
        margin: const EdgeInsets.all(8),
      ),

      // Tema per tutti i ListTile
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
      ),

      // Tema per tutti gli Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(primaryColor),
        trackColor: WidgetStateProperty.all(primaryColor.withOpacity(0.3)),
      ),

      // Tema per tutti i TextField
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
      ),

      // Tema per tutte le icone
      iconTheme: IconThemeData(
        color: primaryColor,
        size: 24 * textScaleFactor,
      ),

      // Colore di sfondo per tutti gli Scaffold
      scaffoldBackgroundColor: backgroundColor,

      // Tema per tutti i Dialog
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
          borderRadius: BorderRadius.circular(12),
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
    );
  }
}