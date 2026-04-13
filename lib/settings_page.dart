import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const List<Color> _availableColors = [
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.redAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.pinkAccent,
    Colors.cyanAccent,
    Colors.tealAccent,
    Colors.indigoAccent,
    Colors.deepOrangeAccent,
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thème ──
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Thème", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => themeProvider.setTheme(ThemeMode.light),
                            icon: const Icon(Icons.light_mode),
                            label: const Text("Clair"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !isDark ? Colors.blueAccent : Colors.grey[700],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => themeProvider.setTheme(ThemeMode.dark),
                            icon: const Icon(Icons.dark_mode),
                            label: const Text("Sombre"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? Colors.blueAccent : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Couleur d'accent ──
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Couleur d'accent", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 5,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: _availableColors.map((color) {
                        final isSelected = themeProvider.seedColor == color;
                        return GestureDetector(
                          onTap: () => themeProvider.setSeedColor(color),
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 3)
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: isSelected ? 12 : 6,
                                ),
                              ],
                            ),
                            child: isSelected
                                ? const Center(child: Icon(Icons.check, color: Colors.white))
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Décimales ──
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Précision décimale", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Chip(
                          label: Text("${themeProvider.decimalPlaces}"),
                          backgroundColor: themeProvider.seedColor.withValues(alpha: 0.2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      value: themeProvider.decimalPlaces.toDouble(),
                      min: 1,
                      max: 6,
                      divisions: 5,
                      label: "${themeProvider.decimalPlaces}",
                      onChanged: (value) => themeProvider.setDecimalPlaces(value.toInt()),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Les données seront affichées avec ${themeProvider.decimalPlaces} décimales",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── À propos ──
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("À propos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const Text(
                      "Drone Monitoring v1.0\n\n"
                      "Application de suivi en temps réel des données de télémétrie de drone.\n\n"
                      "Fonctionnalités:\n"
                      "• Réception de données en direct\n"
                      "• Insertion de données manuelles\n"
                      "• Graphiques temps réel\n"
                      "• Export/Import Excel\n"
                      "• Import CSV\n"
                      "• Visualisation multi-axes",
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
