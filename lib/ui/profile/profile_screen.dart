import 'package:flutter/material.dart';
import 'package:pro/ui/profile/viemodel/profile_viewmodel.dart';
import 'package:provider/provider.dart';

import '../accessibility/tts/tts_page_wrapper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Map<String, String> badgeDescriptions = {
    "lock": "Privacy Online",
    "compass": "Navigazione",
    "target": "Obiettivi",
    "eyes": "Osservatore",
    "banned": "Anti-Phishing",
    "floppy_disk": "Backup",
    "private_detective": "Investigatore",
    "key": "Sicurezza informatica",
    "earth": "Globale",
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
    final badgeCount = vm.user?.badges.values.where((v) => v).length ?? 0;
    final badgeTotal = badgeKeys.length;
    final progress = badgeTotal == 0 ? 0.0 : badgeCount / badgeTotal;

    return TtsPageWrapper(
        pageTitle: "Sezione Profilo personale",
        pageDescription: "Quanti badge hai ottenuto? Scoprilo subito",
        autoReadTexts: [
        "In questa schermata troverai tutti i tuoi badge",
        "Il tuo progresso in percentuale",
        "Le sezioni relative al supporto, accessibilità ed il logout",
        ],

        child: Scaffold(
        backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text(
          "WebAware",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: _showOptionsMenu,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.deepOrange,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        currentIndex: 0, // sei nella home
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
            case 1:
              Navigator.pushNamed(context, '/quiz');
              break;
            case 2:
              Navigator.pushNamed(context, '/simulation');
              break;
            case 3:
              Navigator.pushNamed(context, '/extra');
              break;
            case 4:
              Navigator.pushNamed(context, '/emergency');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Info'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quiz'),
          BottomNavigationBarItem(icon: Icon(Icons.videogame_asset), label: 'Simulazioni'),
          BottomNavigationBarItem(icon: Icon(Icons.visibility), label: 'Extra'),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Emerg.'),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.user == null
          ? const Center(child: Text("Errore nel caricamento del profilo"))
          : Column(
        children: [
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 60,
            backgroundImage: const AssetImage("assets/fox_logo.png"),
          ),
          const SizedBox(height: 16),
          Text(
            vm.user!.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  color: Colors.green,
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(height: 8),
                Text(
                  "$badgeCount/$badgeTotal badge sbloccati (${(progress * 100).round()}%)",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "I tuoi badge",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              padding: const EdgeInsets.all(8),
              children: badgeKeys.map((key) {
                final unlocked = vm.user!.badges[key] == true;
                return GestureDetector(
                  onTap: () => _showDescription(context, badgeDescriptions[key] ?? key),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/$key.png",
                          width: 64,
                          height: 64,
                          color: unlocked ? null : Colors.grey,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          badgeDescriptions[key] ?? key,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: unlocked ? Colors.black : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ));
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.support),
            title: const Text("Supporto"),
            onTap: () => Navigator.pushNamed(context, '/support'),
          ),
          ListTile(
            leading: const Icon(Icons.accessibility),
            title: const Text("Accessibilità"),
            onTap: () => Navigator.pushNamed(context, '/accessibility'),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () async {
              await context.read<ProfileViewModel>().logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
    );
  }

  void _showDescription(BuildContext context, String desc) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(desc), duration: const Duration(seconds: 2)),
    );
  }
}
