import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:excel/excel.dart' as excel_lib;
import 'data_model.dart';

class TelemetryService extends ChangeNotifier {
  TelemetryData? currentData;
  List<TelemetryData> history = [];
  Timer? _timer;
  int? scrubbedIndex; // Index survolé sur le graphique

  void setScrubbedIndex(int? index) {
    scrubbedIndex = index;
    notifyListeners();
  }

  // Renvoie la donnée survolée (historique) OU la donnée en direct
  TelemetryData? get displayData {
    if (scrubbedIndex != null &&
        scrubbedIndex! >= 0 &&
        scrubbedIndex! < history.length) {
      return history[scrubbedIndex!];
    }
    return currentData;
  }

  String serverUrl =
      "http://localhost:5000"; // Remplace par l'IP/port de ton serveur (ex: http://192.168.1.15:5000)

  bool isConnected = false;
  String errorMessage = "";
  int failedAttempts = 0;

  TelemetryService() {
    startFetching();
  }

  /// Construit les headers HTTP adaptés selon l'URL du serveur.
  /// - localtunnel (loca.lt) : exige un header spécial pour contourner la page de confirmation
  /// - Tous les serveurs : on se présente comme un client JSON
  Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    // Bypass localtunnel confirmation page
    if (serverUrl.contains('loca.lt')) {
      headers['bypass-tunnel-reminder'] = 'true';
    }
    return headers;
  }

  void setServerUrl(String url) {
    var cleaned = url.trim();
    if (!cleaned.startsWith('http://') && !cleaned.startsWith('https://')) {
      cleaned = 'http://$cleaned';
    }
    serverUrl = cleaned.replaceAll(RegExp(r'/$'), ''); // Retire le slash final
    failedAttempts = 0;
    errorMessage = "";
    notifyListeners();
    fetchTelemetry(); // Lance immédiatement une tentative de connexion
  }

  void startFetching() {
    // Interrogation toutes les 1 seconde
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      await fetchTelemetry();
    });
  }

  Future<void> fetchTelemetry() async {
    try {
      final url = Uri.parse("$serverUrl/latest-data");
      final response = await http
          .get(url, headers: _buildHeaders())
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () {
              throw TimeoutException("Connexion au serveur expirée");
            },
          );

      if (response.statusCode == 200) {
        // Vérifie qu'on a bien du JSON (localtunnel renvoie parfois du HTML)
        final contentType = response.headers['content-type'] ?? '';
        if (!contentType.contains('application/json') &&
            !contentType.contains('json')) {
          // Essayons quand même de décoder — certains serveurs n'envoient pas le bon Content-Type
          if (response.body.trim().startsWith('<')) {
            isConnected = false;
            errorMessage =
                "Le serveur a retourne du HTML au lieu de JSON.\n"
                "Pour loca.lt : visitez l'URL dans un navigateur d'abord.";
            failedAttempts++;
            notifyListeners();
            return;
          }
        }

        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Vérifier que ce n'est pas un message d'erreur
        if (jsonData.containsKey('error') || jsonData.containsKey('message')) {
          isConnected = false;
          errorMessage =
              jsonData['error'] ?? jsonData['message'] ?? "Pas de donnees";
          notifyListeners();
          return;
        }

        final newData = TelemetryData.fromJson(jsonData);
        currentData = newData;
        history.add(newData);
        // Limiter l'historique à 100 points pour les graphiques
        if (history.length > 100) history.removeAt(0);

        isConnected = true;
        errorMessage = "";
        failedAttempts = 0;
        notifyListeners();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        isConnected = false;
        errorMessage = "Acces refuse (${response.statusCode}). Vérifiez l'URL.";
        failedAttempts++;
        notifyListeners();
      } else {
        isConnected = false;
        errorMessage = "Erreur serveur ${response.statusCode}";
        failedAttempts++;
        notifyListeners();
      }
    } on TimeoutException {
      isConnected = false;
      errorMessage = "Connexion expiree (timeout 8s)";
      failedAttempts++;
      notifyListeners();
    } on FormatException {
      isConnected = false;
      errorMessage = "Reponse invalide (pas du JSON). Verifiez l'URL.";
      failedAttempts++;
      notifyListeners();
    } catch (e) {
      isConnected = false;
      final msg = e.toString();
      // Messages d'erreur plus parlants
      if (msg.contains('SocketException') ||
          msg.contains('Connection refused')) {
        errorMessage =
            "Serveur injoignable. Verifiez l'URL et que le serveur tourne.";
      } else if (msg.contains('HandshakeException') ||
          msg.contains('CERTIFICATE')) {
        errorMessage = "Erreur SSL/HTTPS. Essayez avec http:// a la place.";
      } else {
        errorMessage = msg.length > 90 ? '${msg.substring(0, 90)}...' : msg;
      }
      failedAttempts++;
      notifyListeners();

      if (kDebugMode) {
        print("Erreur de connexion au serveur: $e");
      }
    }
  }

  // Récupère un aperçu du serveur
  Future<Map<String, dynamic>?> getServerHealth() async {
    try {
      final response = await http
          .get(Uri.parse("$serverUrl/health"), headers: _buildHeaders())
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      if (kDebugMode) print("Health check failed: $e");
    }
    return null;
  }

  void clearHistory() {
    history.clear();
    scrubbedIndex = null;
    currentData = null;
    notifyListeners();
  }

  void injectData(TelemetryData data) {
    currentData = data;
    history.add(data);
    if (history.length > 500) history.removeAt(0);
    notifyListeners();
  }

  // --- Fonction pour extraire proprement la valeur d'une cellule Excel ---
  String _getCellValueString(excel_lib.CellValue? cell) {
    if (cell == null) return '';
    if (cell is excel_lib.DoubleCellValue) return cell.value.toString();
    if (cell is excel_lib.IntCellValue) return cell.value.toString();
    if (cell is excel_lib.TextCellValue) return cell.value.toString();
    return cell.toString(); // Fallback
  }

  // --- NOUVELLE FONCTION : Importation Excel depuis la mémoire ---
  Future<void> importExcelBytes(List<int> bytes) async {
    try {
      final excelFile = excel_lib.Excel.decodeBytes(bytes);

      for (var table in excelFile.tables.keys) {
        final sheet = excelFile.tables[table];
        if (sheet == null) continue;

        // Passer la première ligne (headers)
        final rows = sheet.rows.skip(1).toList();
        for (var row in rows) {
          try {
            if (row.length < 12) continue;

            final data = TelemetryData(
              timestamp:
                  DateTime.tryParse(_getCellValueString(row[0]?.value)) ??
                  DateTime.now(),
              altitude:
                  double.tryParse(_getCellValueString(row[1]?.value)) ?? 0.0,
              speed: double.tryParse(_getCellValueString(row[2]?.value)) ?? 0.0,
              temperature:
                  double.tryParse(_getCellValueString(row[3]?.value)) ?? 0.0,
              battery:
                  double.tryParse(_getCellValueString(row[4]?.value)) ?? 0.0,
              pitch: double.tryParse(_getCellValueString(row[5]?.value)) ?? 0.0,
              roll: double.tryParse(_getCellValueString(row[6]?.value)) ?? 0.0,
              yaw: double.tryParse(_getCellValueString(row[7]?.value)) ?? 0.0,
              accelX:
                  double.tryParse(_getCellValueString(row[8]?.value)) ?? 0.0,
              accelY:
                  double.tryParse(_getCellValueString(row[9]?.value)) ?? 0.0,
              accelZ:
                  double.tryParse(_getCellValueString(row[10]?.value)) ?? 0.0,
              pressure:
                  double.tryParse(_getCellValueString(row[11]?.value)) ??
                  1013.25,
            );
            history.add(data);
          } catch (e) {
            if (kDebugMode) print("Erreur importation ligne: $e");
          }
        }
      }

      if (history.isNotEmpty) {
        currentData = history.last;
        isConnected = true;
        errorMessage = "";
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("Erreur import Excel: $e");
      errorMessage =
          "Format Excel invalide. Assurez-vous que c'est un vrai .xlsx";
      notifyListeners();
      throw Exception("Format Excel (.xlsx) invalide ou corrompu.");
    }
  }

  // --- NOUVELLE FONCTION : Importation CSV depuis la mémoire ---
  Future<void> importCSVBytes(List<int> bytes) async {
    try {
      // Décodage du fichier CSV en texte (avec contournement des caractères corrompus comme le BOM)
      final csvString = utf8.decode(bytes, allowMalformed: true);
      final lines = csvString.split('\n'); // Sépare par ligne

      for (var i = 1; i < lines.length; i++) {
        if (lines[i].trim().isEmpty) continue;
        try {
          final fields = lines[i].split(',');
          if (fields.length < 12) continue;

          final data = TelemetryData(
            timestamp: DateTime.tryParse(fields[0]) ?? DateTime.now(),
            altitude: double.tryParse(fields[1]) ?? 0.0,
            speed: double.tryParse(fields[2]) ?? 0.0,
            temperature: double.tryParse(fields[3]) ?? 0.0,
            battery: double.tryParse(fields[4]) ?? 0.0,
            pitch: double.tryParse(fields[5]) ?? 0.0,
            roll: double.tryParse(fields[6]) ?? 0.0,
            yaw: double.tryParse(fields[7]) ?? 0.0,
            accelX: double.tryParse(fields[8]) ?? 0.0,
            accelY: double.tryParse(fields[9]) ?? 0.0,
            accelZ: double.tryParse(fields[10]) ?? 0.0,
            pressure: double.tryParse(fields[11]) ?? 1013.25,
          );
          history.add(data);
        } catch (e) {
          if (kDebugMode) print("Erreur import ligne CSV: $e");
        }
      }

      if (history.isNotEmpty) {
        currentData = history.last;
        isConnected = true;
        errorMessage = "";
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("Erreur import CSV: $e");
      errorMessage = "Format CSV invalide.";
      notifyListeners();
      throw Exception("Erreur de lecture du fichier CSV.");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
