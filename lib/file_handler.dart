import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart' as excel_lib;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'data_model.dart';

class FileHandler {
  /// Exporte l'historique en fichier Excel (.xlsx)
  static Future<File?> exportToExcel(List<TelemetryData> history, {String? filename}) async {
    try {
      final excel = excel_lib.Excel.createExcel();
      final sheet = excel['Sheet1'];

      // En-têtes
      final headers = [
        excel_lib.TextCellValue('Timestamp'),
        excel_lib.TextCellValue('Altitude (m)'),
        excel_lib.TextCellValue('Vitesse (m/s)'),
        excel_lib.TextCellValue('Température (°C)'),
        excel_lib.TextCellValue('Batterie (%)'),
        excel_lib.TextCellValue('Pitch (°)'),
        excel_lib.TextCellValue('Roll (°)'),
        excel_lib.TextCellValue('Yaw (°)'),
        excel_lib.TextCellValue('AccelX (m/s²)'),
        excel_lib.TextCellValue('AccelY (m/s²)'),
        excel_lib.TextCellValue('AccelZ (m/s²)'),
        excel_lib.TextCellValue('Pression (hPa)'),
        excel_lib.TextCellValue('Accélération (m/s²)'),
        excel_lib.TextCellValue('Alertes'),
      ];
      sheet.appendRow(headers);

      // Données
      for (var data in history) {
        final row = [
          excel_lib.TextCellValue(data.timestamp.toIso8601String()),
          excel_lib.DoubleCellValue(data.altitude),
          excel_lib.DoubleCellValue(data.speed),
          excel_lib.DoubleCellValue(data.temperature),
          excel_lib.DoubleCellValue(data.battery),
          excel_lib.DoubleCellValue(data.pitch),
          excel_lib.DoubleCellValue(data.roll),
          excel_lib.DoubleCellValue(data.yaw),
          excel_lib.DoubleCellValue(data.accelX),
          excel_lib.DoubleCellValue(data.accelY),
          excel_lib.DoubleCellValue(data.accelZ),
          excel_lib.DoubleCellValue(data.pressure),
          excel_lib.DoubleCellValue(data.acceleration),
          excel_lib.TextCellValue(data.alerts.join('; ')),
        ];
        sheet.appendRow(row);
      }

      final bytes = excel.encode();
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final file = File('${dir.path}/${filename ?? "telemetry_$timestamp.xlsx"}');
      await file.writeAsBytes(bytes!);
      
      return file;
    } catch (e) {
      throw Exception("Erreur export Excel: $e");
    }
  }

  /// Exporte l'historique en CSV
  static Future<File?> exportToCSV(List<TelemetryData> history, {String? filename}) async {
    try {
      final buffer = StringBuffer();
      
      // En-têtes
      buffer.writeln(
        'Timestamp,Altitude (m),Vitesse (m/s),Température (°C),Batterie (%),'
        'Pitch (°),Roll (°),Yaw (°),AccelX (m/s²),AccelY (m/s²),AccelZ (m/s²),'
        'Pression (hPa),Accélération (m/s²),Alertes'
      );

      // Données
      for (var data in history) {
        buffer.writeln(
          '${data.timestamp.toIso8601String()},'
          '${data.altitude},'
          '${data.speed},'
          '${data.temperature},'
          '${data.battery},'
          '${data.pitch},'
          '${data.roll},'
          '${data.yaw},'
          '${data.accelX},'
          '${data.accelY},'
          '${data.accelZ},'
          '${data.pressure},'
          '${data.acceleration},'
          '"${data.alerts.join('; ')}"'
        );
      }

      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final file = File('${dir.path}/${filename ?? "telemetry_$timestamp.csv"}');
      await file.writeAsString(buffer.toString());
      
      return file;
    } catch (e) {
      throw Exception("Erreur export CSV: $e");
    }
  }

  /// Exporte l'historique en JSON
  static Future<File?> exportToJSON(List<TelemetryData> history, {String? filename}) async {
    try {
      final jsonData = history.map((data) {
        return {
          'timestamp': data.timestamp.toIso8601String(),
          'altitude': data.altitude,
          'speed': data.speed,
          'temperature': data.temperature,
          'battery': data.battery,
          'pitch': data.pitch,
          'roll': data.roll,
          'yaw': data.yaw,
          'accelX': data.accelX,
          'accelY': data.accelY,
          'accelZ': data.accelZ,
          'pressure': data.pressure,
          'acceleration': data.acceleration,
          'alerts': data.alerts,
        };
      }).toList();

      final jsonString = jsonEncode(jsonData);
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final file = File('${dir.path}/${filename ?? "telemetry_$timestamp.json"}');
      await file.writeAsString(jsonString);
      
      return file;
    } catch (e) {
      throw Exception("Erreur export JSON: $e");
    }
  }

  /// Partage un fichier via les applications natives
  static Future<void> shareFile(File file) async {
    try {
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Données de télémétrie du drone',
      );
      if (result.status == ShareResultStatus.success) {
        // Succès
      }
    } catch (e) {
      throw Exception("Erreur partage: $e");
    }
  }

  /// Importe un fichier Excel et retourne les données
  static Future<List<TelemetryData>> importFromExcelBytes(List<int> bytes) async {
    try {
      final excelFile = excel_lib.Excel.decodeBytes(bytes);
      final data = <TelemetryData>[];

      for (var table in excelFile.tables.keys) {
        final sheet = excelFile.tables[table];
        if (sheet == null) continue;

        final rows = sheet.rows.skip(1).toList();
        for (var row in rows) {
          try {
            if (row.isEmpty) continue;

            final telemetryData = TelemetryData(
              timestamp: DateTime.tryParse(_getCellValueString(row.length > 0 ? row[0]?.value : null)) ?? DateTime.now(),
              altitude: double.tryParse(_getCellValueString(row.length > 1 ? row[1]?.value : null)) ?? 0.0,
              speed: double.tryParse(_getCellValueString(row.length > 2 ? row[2]?.value : null)) ?? 0.0,
              temperature: double.tryParse(_getCellValueString(row.length > 3 ? row[3]?.value : null)) ?? 0.0,
              battery: double.tryParse(_getCellValueString(row.length > 4 ? row[4]?.value : null)) ?? 0.0,
              pitch: double.tryParse(_getCellValueString(row.length > 5 ? row[5]?.value : null)) ?? 0.0,
              roll: double.tryParse(_getCellValueString(row.length > 6 ? row[6]?.value : null)) ?? 0.0,
              yaw: double.tryParse(_getCellValueString(row.length > 7 ? row[7]?.value : null)) ?? 0.0,
              accelX: double.tryParse(_getCellValueString(row.length > 8 ? row[8]?.value : null)) ?? 0.0,
              accelY: double.tryParse(_getCellValueString(row.length > 9 ? row[9]?.value : null)) ?? 0.0,
              accelZ: double.tryParse(_getCellValueString(row.length > 10 ? row[10]?.value : null)) ?? 0.0,
              pressure: double.tryParse(_getCellValueString(row.length > 11 ? row[11]?.value : null)) ?? 1013.25,
              acceleration: double.tryParse(_getCellValueString(row.length > 12 ? row[12]?.value : null)) ?? 0.0,
            );
            data.add(telemetryData);
          } catch (e) {
            // Ignorer les erreurs de ligne
          }
        }
      }

      return data;
    } catch (e) {
      throw Exception("Erreur import Excel: $e");
    }
  }

  /// Importe un fichier CSV et retourne les données
  static Future<List<TelemetryData>> importFromCSVBytes(List<int> bytes) async {
    try {
      final csvString = utf8.decode(bytes, allowMalformed: true);
      final lines = csvString.split('\n');
      final data = <TelemetryData>[];

      for (var i = 1; i < lines.length; i++) {
        if (lines[i].trim().isEmpty) continue;
        try {
          final fields = lines[i].split(',');
          if (fields.isEmpty) continue;

          final telemetryData = TelemetryData(
            timestamp: DateTime.tryParse(fields.length > 0 ? fields[0] : '') ?? DateTime.now(),
            altitude: double.tryParse(fields.length > 1 ? fields[1] : '') ?? 0.0,
            speed: double.tryParse(fields.length > 2 ? fields[2] : '') ?? 0.0,
            temperature: double.tryParse(fields.length > 3 ? fields[3] : '') ?? 0.0,
            battery: double.tryParse(fields.length > 4 ? fields[4] : '') ?? 0.0,
            pitch: double.tryParse(fields.length > 5 ? fields[5] : '') ?? 0.0,
            roll: double.tryParse(fields.length > 6 ? fields[6] : '') ?? 0.0,
            yaw: double.tryParse(fields.length > 7 ? fields[7] : '') ?? 0.0,
            accelX: double.tryParse(fields.length > 8 ? fields[8] : '') ?? 0.0,
            accelY: double.tryParse(fields.length > 9 ? fields[9] : '') ?? 0.0,
            accelZ: double.tryParse(fields.length > 10 ? fields[10] : '') ?? 0.0,
            pressure: double.tryParse(fields.length > 11 ? fields[11] : '') ?? 1013.25,
            acceleration: double.tryParse(fields.length > 12 ? fields[12] : '') ?? 0.0,
          );
          data.add(telemetryData);
        } catch (e) {
          // Ignorer les erreurs de ligne
        }
      }

      return data;
    } catch (e) {
      throw Exception("Erreur import CSV: $e");
    }
  }

  /// Importe un fichier JSON et retourne les données
  static Future<List<TelemetryData>> importFromJSONBytes(List<int> bytes) async {
    try {
      final jsonString = utf8.decode(bytes, allowMalformed: true);
      final jsonData = jsonDecode(jsonString);
      final data = <TelemetryData>[];

      if (jsonData is List) {
        for (var item in jsonData) {
          try {
            data.add(TelemetryData.fromJson(item as Map<String, dynamic>));
          } catch (e) {
            // Ignorer les erreurs d'item
          }
        }
      } else if (jsonData is Map<String, dynamic>) {
        data.add(TelemetryData.fromJson(jsonData));
      }

      return data;
    } catch (e) {
      throw Exception("Erreur import JSON: $e");
    }
  }

  /// Génère un rapport HTML avec graphiques et statistiques
  static Future<File?> generateHTMLReport(
    List<TelemetryData> history, {
    String? filename,
  }) async {
    try {
      if (history.isEmpty) return null;

      // Calcul des statistiques
      final altitudes = history.map((d) => d.altitude).toList();
      final speeds = history.map((d) => d.speed).toList();
      final temps = history.map((d) => d.temperature).toList();
      final batteries = history.map((d) => d.battery).toList();

      final avgAltitude = altitudes.reduce((a, b) => a + b) / altitudes.length;
      final maxAltitude = altitudes.reduce((a, b) => a > b ? a : b);
      final avgSpeed = speeds.reduce((a, b) => a + b) / speeds.length;
      final maxSpeed = speeds.reduce((a, b) => a > b ? a : b);
      final avgTemp = temps.reduce((a, b) => a + b) / temps.length;
      final minBattery = batteries.reduce((a, b) => a < b ? a : b);

      final html = '''
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rapport Télémétrie Drone</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background: #f5f5f5;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            text-align: center;
            border-bottom: 3px solid #007bff;
            padding-bottom: 10px;
        }
        h2 {
            color: #555;
            margin-top: 30px;
            border-left: 4px solid #007bff;
            padding-left: 10px;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin: 20px 0;
        }
        .stat-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .stat-card.alt { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); }
        .stat-card.spd { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); }
        .stat-card.tmp { background: linear-gradient(135deg, #fa709a 0%, #fee140 100%); }
        .stat-card.bat { background: linear-gradient(135deg, #30cfd0 0%, #330867 100%); }
        .stat-label { font-size: 0.9em; opacity: 0.9; }
        .stat-value { font-size: 1.8em; font-weight: bold; margin-top: 10px; }
        .chart-container {
            position: relative;
            height: 300px;
            margin: 30px 0;
            background: #f9f9f9;
            border-radius: 8px;
            padding: 15px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background: #007bff;
            color: white;
            font-weight: bold;
        }
        tr:hover { background: #f5f5f5; }
        .footer {
            text-align: center;
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #ddd;
            color: #888;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📊 Rapport de Télémétrie Drone</h1>
        
        <div style="text-align: center; color: #666; margin: 10px 0;">
            <p>Généré le: ${DateTime.now().toLocal()}</p>
            <p>Nombre de mesures: ${history.length}</p>
            <p>Durée: ${(history.last.timestamp.difference(history.first.timestamp).inSeconds)} secondes</p>
        </div>

        <h2>📈 Statistiques Principales</h2>
        <div class="stats-grid">
            <div class="stat-card alt">
                <div class="stat-label">Altitude Moyenne</div>
                <div class="stat-value">${avgAltitude.toStringAsFixed(1)} m</div>
            </div>
            <div class="stat-card alt">
                <div class="stat-label">Altitude Maximale</div>
                <div class="stat-value">${maxAltitude.toStringAsFixed(1)} m</div>
            </div>
            <div class="stat-card spd">
                <div class="stat-label">Vitesse Moyenne</div>
                <div class="stat-value">${avgSpeed.toStringAsFixed(1)} m/s</div>
            </div>
            <div class="stat-card spd">
                <div class="stat-label">Vitesse Maximale</div>
                <div class="stat-value">${maxSpeed.toStringAsFixed(1)} m/s</div>
            </div>
            <div class="stat-card tmp">
                <div class="stat-label">Température Moyenne</div>
                <div class="stat-value">${avgTemp.toStringAsFixed(1)} °C</div>
            </div>
            <div class="stat-card bat">
                <div class="stat-label">Batterie Minimale</div>
                <div class="stat-value">${minBattery.toStringAsFixed(0)} %</div>
            </div>
        </div>

        <h2>📋 Données Détaillées</h2>
        <table>
            <tr>
                <th>Timestamp</th>
                <th>Altitude (m)</th>
                <th>Vitesse (m/s)</th>
                <th>Température (°C)</th>
                <th>Batterie (%)</th>
            </tr>
            ${history.take(20).map((d) => '''
            <tr>
                <td>${d.timestamp}</td>
                <td>${d.altitude.toStringAsFixed(2)}</td>
                <td>${d.speed.toStringAsFixed(2)}</td>
                <td>${d.temperature.toStringAsFixed(1)}</td>
                <td>${d.battery.toStringAsFixed(0)}</td>
            </tr>
            ''').join('')}
        </table>
        ${history.length > 20 ? '<p style="text-align: center; color: #999;">... et ${history.length - 20} mesures supplémentaires</p>' : ''}

        <div class="footer">
            <p>Rapport généré automatiquement par Drone Monitoring</p>
        </div>
    </div>
</body>
</html>
      ''';

      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final file = File('${dir.path}/${filename ?? "rapport_$timestamp.html"}');
      await file.writeAsString(html);

      return file;
    } catch (e) {
      throw Exception("Erreur génération rapport: $e");
    }
  }

  static String _getCellValueString(dynamic cellValue) {
    if (cellValue == null) return '';
    if (cellValue is excel_lib.DoubleCellValue) return cellValue.value.toString();
    if (cellValue is excel_lib.IntCellValue) return cellValue.value.toString();
    if (cellValue is excel_lib.TextCellValue) return cellValue.value.toString();
    return cellValue.toString();
  }
}
