import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _accessibilityMode = false;

  @override
  void initState() {
    super.initState();
    _loadSetting();
  }

  void _loadSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _accessibilityMode = prefs.getBool("accessibility_mode") ?? false;
    });
  }

  void _updateSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("accessibility_mode", value);
    setState(() {
      _accessibilityMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Impostazioni")),
      body: ListTile(
        title: const Text("Modalità Accessibilità"),
        trailing: Switch(
          value: _accessibilityMode,
          onChanged: _updateSetting,
        ),
      ),
    );
  }
}
