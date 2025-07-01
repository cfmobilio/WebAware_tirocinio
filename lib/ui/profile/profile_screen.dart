import 'package:flutter/material.dart';
import 'package:pro/ui/profile/viemodel/profile_viewmodel.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Map<String, String> badgeDescriptions = {
    "lock": "Badge: Privacy Online",
    "compass": "Badge Navigazione",
    "target": "Badge Obiettivi",
    "eyes": "Badge Osservatore",
    "banned": "Badge Anti-Phishing",
    "floppy_disk": "Badge Backup",
    "private_detective": "Badge Investigatore",
    "key": "Badge: Sicurezza informatica",
    "earth": "Badge Globale",
  };

  final List<String> badgeKeys = [
    "lock",
    "compass",
    "target",
    "eyes",
    "banned",
    "floppy_disk",
    "private_detective",
    "key",
    "earth"
  ];

  @override
  void initState() {
    super.initState();
    context.read<ProfileViewModel>().loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profilo"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await vm.logout();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              } else {
                Navigator.pushNamed(context, '/$value');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'support', child: Text("Supporto")),
              const PopupMenuItem(value: 'accessibility', child: Text("Accessibilità")),
              const PopupMenuItem(value: 'logout', child: Text("Logout")),
            ],
          )
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.user == null
          ? const Center(child: Text("Errore nel caricamento del profilo"))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: const AssetImage("assets/fox_logo.png"),
            ),
            const SizedBox(height: 8),
            Text(vm.user!.name, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: vm.user!.badges.values.where((v) => v).length / badgeKeys.length,
              minHeight: 10,
            ),
            const SizedBox(height: 8),
            Text(
              "${vm.user!.badges.values.where((v) => v).length}/${badgeKeys.length} badge sbloccati",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                children: badgeKeys.map((key) {
                  final unlocked = vm.user!.badges[key] == true;
                  return GestureDetector(
                    onTap: () => _showDescription(context, badgeDescriptions[key] ?? key),
                    child: Opacity(
                      opacity: unlocked ? 1.0 : 0.3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/$key.png", width: 48, height: 48),
                          Text(key, style: const TextStyle(fontSize: 12))
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showDescription(BuildContext context, String desc) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(desc), duration: const Duration(seconds: 2)),
    );
  }
}
