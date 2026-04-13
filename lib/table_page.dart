import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'telemetry_service.dart';
import 'data_model.dart';
import 'theme_provider.dart';

class TablePage extends StatelessWidget {
  const TablePage({super.key});

  Future<Directory> _getExportDirectory() async {
    if (Platform.isWindows) {
      // Sur Windows, utiliser le dossier utilisateur/Downloads ou Documents
      final home = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'] ?? '';
      final downloadsPath = '$home\\Downloads';
      final dir = Directory(downloadsPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir;
    } else {
      // Sur Android et autres, utiliser getApplicationDocumentsDirectory
      return await getApplicationDocumentsDirectory();
    }
  }

  Future<void> _exportToExcel(BuildContext context, List<TelemetryData> history) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Telemetry'];
      excel.delete('Sheet1');

      List<String> headers = [
        "Temps", "Altitude (m)", "Vitesse (m/s)", "Temp (°C)", "Batterie (V)", 
        "Pitch", "Roll", "Yaw", "Accel X", "Accel Y", "Accel Z", "Pression (hPa)"
      ];
      sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());

      for (var data in history) {
        sheetObject.appendRow([
          TextCellValue(data.timestamp.toIso8601String()),
          DoubleCellValue(data.altitude),
          DoubleCellValue(data.speed),
          DoubleCellValue(data.temperature),
          DoubleCellValue(data.battery),
          DoubleCellValue(data.pitch),
          DoubleCellValue(data.roll),
          DoubleCellValue(data.yaw),
          DoubleCellValue(data.accelX),
          DoubleCellValue(data.accelY),
          DoubleCellValue(data.accelZ),
          DoubleCellValue(data.pressure),
        ]);
      }

      final fileBytes = excel.save();
      if (fileBytes == null) throw Exception("Erreur de génération Excel");

      final directory = await _getExportDirectory();
      final fileName = 'telemetrie_drone_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final separator = Platform.isWindows ? '\\' : '/';
      final filePath = '${directory.path}$separator$fileName';
      
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      if (context.mounted) {
        String message = Platform.isWindows
            ? "Fichier sauvegardé dans le dossier Téléchargements:\n$fileName"
            : "Fichier sauvegardé:\n$fileName\n\nDossier: ${directory.path}";
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de l'export: $e")),
        );
      }
    }
  }

  Future<void> _importExcel(BuildContext context) async {
    try {
      final directory = await _getExportDirectory();
      final files = directory.listSync();
      
      List<String> excelFiles = [];
      for (var file in files) {
        if (file.path.endsWith('.xlsx') || file.path.endsWith('.xls') || file.path.endsWith('.csv')) {
          excelFiles.add(file.path);
        }
      }
      
      if (excelFiles.isEmpty) {
        if (context.mounted) {
          String message = Platform.isWindows
              ? "Aucun fichier Excel/CSV trouvé dans le dossier Téléchargements"
              : "Aucun fichier à importer trouvé dans les documents";
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
        return;
      }

      // Montrer les fichiers disponibles
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Sélectionner un fichier"),
            content: SizedBox(
              width: 400,
              height: 300,
              child: ListView.builder(
                itemCount: excelFiles.length,
                itemBuilder: (context, index) {
                  final separator = Platform.isWindows ? '\\' : '/';
                  final fileName = excelFiles[index].split(separator).last;
                  return ListTile(
                    title: Text(fileName),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await _performImport(context, excelFiles[index]);
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Annuler"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la recherche: $e")),
        );
      }
    }
  }

  Future<void> _performImport(BuildContext context, String filePath) async {
    try {
      final service = Provider.of<TelemetryService>(context, listen: false);
      
      // --- MODIFICATION ICI ---
      // On lit le fichier physiquement pour récupérer ses octets en mémoire
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      
      if (filePath.toLowerCase().endsWith('.csv')) {
        await service.importCSVBytes(bytes); // Appel de la nouvelle fonction
      } else {
        await service.importExcelBytes(bytes); // Appel de la nouvelle fonction
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fichier importé avec succès!")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de l'import: $e")),
        );
      }
    }
  }

  void _clearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text("Êtes-vous sûr de vouloir supprimer toutes les données ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
          TextButton(
            onPressed: () {
              Provider.of<TelemetryService>(context, listen: false).clearHistory();
              Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Historique supprimé")),
                );
              }
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Consumer<TelemetryService>(
      builder: (context, service, child) {
        final history = service.history.reversed.toList();

        if (history.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.table_chart, size: 60, color: Colors.grey[700]),
                const SizedBox(height: 12),
                const Text("Aucune donnee disponible.", style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          );
        }

        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                // ── Stats ──
                Container(
                  color: isDark ? const Color(0xFF161B22) : Colors.grey[100],
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _stat("Points",   history.length.toString(),               Colors.blueAccent),
                      _stat("Alt max",  "${history.map((d) => d.altitude).reduce((a, b) => a > b ? a : b).toStringAsFixed(2)} m", Colors.green),
                      _stat("Vit max",  "${history.map((d) => d.speed).reduce((a, b) => a > b ? a : b).toStringAsFixed(2)} m/s",  Colors.orangeAccent),
                      _stat("Bat min",  "${history.map((d) => d.battery).reduce((a, b) => a < b ? a : b).toStringAsFixed(2)} V",  Colors.greenAccent),
                    ],
                  ),
                ),

                // ── Table ──
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(isDark ? const Color(0xFF1C2330) : Colors.grey[300]),
                      dataRowColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? Colors.blueAccent.withValues(alpha: 0.1)
                            : (isDark ? const Color(0xFF0D1117) : Colors.white),
                      ),
                      columns: [
                        DataColumn(label: Text('Temps',         style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black))),
                        const DataColumn(label: Text('Altitude',      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent))),
                        const DataColumn(label: Text('Vitesse',       style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange))),
                        const DataColumn(label: Text('Temp',          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent))),
                        const DataColumn(label: Text('Batterie',      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent))),
                        const DataColumn(label: Text('Pitch',         style: TextStyle(fontWeight: FontWeight.bold, color: Colors.lightBlue))),
                        const DataColumn(label: Text('Roll',          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purpleAccent))),
                        const DataColumn(label: Text('Yaw',           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.cyan))),
                        const DataColumn(label: Text('Accel X',       style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent))),
                        const DataColumn(label: Text('Accel Y',       style: TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent))),
                        const DataColumn(label: Text('Accel Z',       style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent))),
                        const DataColumn(label: Text('Pression',      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.tealAccent))),
                      ],
                      rows: history.map((data) {
                        final t = data.timestamp;
                        final time = "${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}:${t.second.toString().padLeft(2,'0')}";
                        final batColor = data.battery > 11 ? Colors.greenAccent : (data.battery > 10 ? Colors.yellowAccent : Colors.redAccent);
                        final decimals = Provider.of<ThemeProvider>(context, listen: false).decimalPlaces;
                        return DataRow(cells: [
                          DataCell(Text(time,                                                                style: TextStyle(fontSize: 11, color: isDark ? Colors.grey : Colors.grey[800]))),
                          DataCell(Text("${data.altitude.toStringAsFixed(decimals)} m",                style: const TextStyle(fontSize: 11, color: Colors.blueAccent))),
                          DataCell(Text("${data.speed.toStringAsFixed(decimals)} m/s",                 style: const TextStyle(fontSize: 11, color: Colors.orange))),
                          DataCell(Text("${data.temperature.toStringAsFixed(decimals)} C",             style: const TextStyle(fontSize: 11, color: Colors.redAccent))),
                          DataCell(Text("${data.battery.toStringAsFixed(decimals)} V",                 style: TextStyle(fontSize: 11, color: batColor))),
                          DataCell(Text("${data.pitch.toStringAsFixed(decimals)} deg",                 style: const TextStyle(fontSize: 11, color: Colors.lightBlue))),
                          DataCell(Text("${data.roll.toStringAsFixed(decimals)} deg",                  style: const TextStyle(fontSize: 11, color: Colors.purpleAccent))),
                          DataCell(Text("${data.yaw.toStringAsFixed(decimals)} deg",                   style: const TextStyle(fontSize: 11, color: Colors.cyan))),
                          DataCell(Text("${data.accelX.toStringAsFixed(decimals)} m/s2",               style: const TextStyle(fontSize: 11, color: Colors.redAccent))),
                          DataCell(Text("${data.accelY.toStringAsFixed(decimals)} m/s2",               style: const TextStyle(fontSize: 11, color: Colors.greenAccent))),
                          DataCell(Text("${data.accelZ.toStringAsFixed(decimals)} m/s2",               style: const TextStyle(fontSize: 11, color: Colors.blueAccent))),
                          DataCell(Text("${data.pressure.toStringAsFixed(decimals)} hPa",              style: const TextStyle(fontSize: 11, color: Colors.tealAccent))),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton.small(
                onPressed: () => _clearHistory(context),
                backgroundColor: Colors.red,
                tooltip: "Supprimer les données",
                child: const Icon(Icons.delete_sweep),
              ),
              const SizedBox(height: 12),
              FloatingActionButton.small(
                onPressed: () => _importExcel(context),
                backgroundColor: Colors.blueAccent,
                tooltip: "Importer Excel",
                child: const Icon(Icons.upload_file),
              ),
              const SizedBox(height: 12),
              FloatingActionButton.extended(
                onPressed: () => _exportToExcel(context, service.history),
                label: const Text("Télécharger Excel"),
                icon: const Icon(Icons.download),
                backgroundColor: Colors.green,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Column(children: [
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
    ]);
  }
}