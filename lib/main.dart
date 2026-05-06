import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'telemetry_service.dart';
import 'theme_provider.dart';
import 'calibration_service.dart';
import 'mission_control_page.dart';
import 'charts_page.dart';
import 'table_page.dart';
import 'settings_page.dart';
import 'calibration_page.dart';
import 'help_page.dart';
import 'manual_data_dialog.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TelemetryService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CalibrationService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'Drone Monitoring',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeProvider.seedColor,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeProvider.seedColor,
          brightness: Brightness.dark,
        ),
      ),
      home: const MainLayout(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const MissionControlPage(),
    const ChartsPage(),
    const TablePage(),
    const CalibrationPage(),
    const SettingsPage(),
    const HelpPage(),
  ];

  final List<String> _pageNames = [
    'Mission Control',
    'Graphiques',
    'Tableau',
    'Calibration',
    'Paramètres',
    'Aide',
  ];

  final List<IconData> _pageIcons = [
    Icons.dashboard,
    Icons.show_chart,
    Icons.table_chart,
    Icons.settings_input_component,
    Icons.settings,
    Icons.help_outline,
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final telemetryService = Provider.of<TelemetryService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("Drone Monitoring - ${_pageNames[_currentIndex]}"),
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? Colors.grey[900] 
            : Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'theme') {
                themeProvider.toggleTheme();
              } else if (value == 'clear') {
                _showClearDialog(context, telemetryService);
              } else if (value == 'manual') {
                showDialog(
                  context: context,
                  builder: (context) => const ManualDataDialog(),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'theme',
                child: Row(
                  children: [
                    Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                    const SizedBox(width: 8),
                    Text(themeProvider.isDarkMode ? "Mode Clair" : "Mode Sombre"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'manual',
                child: Row(
                  children: [
                    Icon(Icons.add_chart),
                    SizedBox(width: 8),
                    Text("Donnée Manuelle"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.red),
                    SizedBox(width: 8),
                    Text("Effacer l'historique", style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: List.generate(_pageNames.length, (index) {
          return NavigationDestination(
            icon: Icon(_pageIcons[index]),
            label: _pageNames[index],
          );
        }),
      ),
    );
  }

  void _showClearDialog(BuildContext context, TelemetryService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer le nettoyage"),
        content: const Text("Voulez-vous vraiment supprimer toutes les données de l'historique ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              service.clearHistory();
              Navigator.pop(context);
            },
            child: const Text("Nettoyer"),
          ),
        ],
      ),
    );
  }
}
