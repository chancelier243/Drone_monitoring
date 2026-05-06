import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'data_model.dart';

/// Service pour communiquer avec le module de télémétrie radio FPV 3DR
/// Supporte le protocole MAVLink et la communication UDP/Série
class ThreeDRService extends ChangeNotifier {
  TelemetryData? currentData;
  List<TelemetryData> history = [];
  
  bool isConnected = false;
  String errorMessage = "";
  int failedAttempts = 0;
  
  // Paramètres de connexion
  String devicePort = "/dev/ttyUSB0"; // Linux/Mac
  int baudRate = 57600; // Standard pour MAVLink
  String remoteHost = "192.168.1.1"; // IP du module 3DR
  int remotePort = 14550; // Port UDP standard MAVLink
  
  // Mode de connexion
  enum ConnectionMode { serial, udp, tcp }
  ConnectionMode connectionMode = ConnectionMode.udp;
  
  Timer? _healthCheckTimer;
  DateTime? _lastDataTime;
  
  int? scrubbedIndex; // Index survolé sur le graphique

  void setScrubbedIndex(int? index) {
    scrubbedIndex = index;
    notifyListeners();
  }

  TelemetryData? get displayData {
    if (scrubbedIndex != null &&
        scrubbedIndex! >= 0 &&
        scrubbedIndex! < history.length) {
      return history[scrubbedIndex!];
    }
    return currentData;
  }

  ThreeDRService() {
    _initializeHealthCheck();
  }

  /// Initialize the health check timer
  void _initializeHealthCheck() {
    _healthCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkConnectionHealth();
    });
  }

  /// Check connection health and attempt reconnection if needed
  void _checkConnectionHealth() {
    final now = DateTime.now();
    if (_lastDataTime != null) {
      final timeSinceLastData = now.difference(_lastDataTime!);
      if (timeSinceLastData.inSeconds > 10) {
        isConnected = false;
        errorMessage = "Pas de données reçues depuis ${timeSinceLastData.inSeconds}s";
        notifyListeners();
      }
    }
  }

  /// Configure connection parameters
  void configureConnection({
    required ConnectionMode mode,
    String? port,
    int? baud,
    String? host,
    int? remPort,
  }) {
    connectionMode = mode;
    if (port != null) devicePort = port;
    if (baud != null) baudRate = baud;
    if (host != null) remoteHost = host;
    if (remPort != null) remotePort = remPort;
    
    failedAttempts = 0;
    errorMessage = "";
    notifyListeners();
  }

  /// Start connection to 3DR module
  Future<void> connectToThreeDR() async {
    try {
      isConnected = true;
      errorMessage = "";
      failedAttempts = 0;
      notifyListeners();
      
      // Ici, la connexion réelle dépend de la plateforme et du mode
      // Pour une implémentation complète, utiliser des plugins comme:
      // - usb_serial (pour port série)
      // - udp (pour UDP)
      // Pour l'instant, on simule une connexion réussie
      
      await _simulateMAVLinkData();
    } catch (e) {
      isConnected = false;
      errorMessage = "Erreur de connexion 3DR: $e";
      failedAttempts++;
      notifyListeners();
    }
  }

  /// Disconnect from 3DR module
  Future<void> disconnectFromThreeDR() async {
    isConnected = false;
    errorMessage = "";
    notifyListeners();
  }

  /// Parse MAVLink protocol packet
  /// Format: "$100<LENGTH><SEQ><SYSID><COMPID><MSGID><PAYLOAD><CRC>"
  TelemetryData? _parseMAVLinkPacket(Uint8List packet) {
    try {
      if (packet.isEmpty || packet[0] != 0xFE) {
        return null; // Invalid MAVLink header
      }

      // Basic MAVLink frame parsing
      final length = packet[1];
      final msgId = packet[5];

      // Parse different MAVLink message types
      switch (msgId) {
        case 33: // GLOBAL_POSITION_INT
          return _parseGlobalPositionInt(packet);
        case 30: // ATTITUDE
          return _parseAttitude(packet);
        case 42: // POWER_STATUS
          return _parsePowerStatus(packet);
        default:
          return null;
      }
    } catch (e) {
      if (kDebugMode) print("MAVLink parse error: $e");
      return null;
    }
  }

  /// Parse ATTITUDE message (msgId 30)
  TelemetryData _parseAttitude(Uint8List packet) {
    // Simplified parsing - adjust based on actual MAVLink format
    double roll = 0.0;
    double pitch = 0.0;
    double yaw = 0.0;

    if (packet.length >= 26) {
      final byteData = packet;
      roll = _bytesToFloat32(byteData, 6);
      pitch = _bytesToFloat32(byteData, 10);
      yaw = _bytesToFloat32(byteData, 14);
    }

    return TelemetryData(
      timestamp: DateTime.now(),
      pitch: pitch,
      roll: roll,
      yaw: yaw,
      altitude: currentData?.altitude ?? 0.0,
      speed: currentData?.speed ?? 0.0,
      battery: currentData?.battery ?? 0.0,
      temperature: currentData?.temperature ?? 0.0,
    );
  }

  /// Parse GLOBAL_POSITION_INT message (msgId 33)
  TelemetryData _parseGlobalPositionInt(Uint8List packet) {
    double altitude = 0.0;
    double speed = 0.0;

    if (packet.length >= 28) {
      final byteData = packet;
      altitude = _bytesToInt32(byteData, 8) / 1000.0; // Convert to meters
      speed = _bytesToInt16(byteData, 20) / 100.0; // Convert to m/s
    }

    return TelemetryData(
      timestamp: DateTime.now(),
      pitch: currentData?.pitch ?? 0.0,
      roll: currentData?.roll ?? 0.0,
      yaw: currentData?.yaw ?? 0.0,
      altitude: altitude,
      speed: speed,
      battery: currentData?.battery ?? 0.0,
      temperature: currentData?.temperature ?? 0.0,
    );
  }

  /// Parse POWER_STATUS message (msgId 42)
  TelemetryData _parsePowerStatus(Uint8List packet) {
    double battery = 0.0;

    if (packet.length >= 8) {
      final byteData = packet;
      battery = _bytesToInt16(byteData, 6) / 1000.0; // Convert to percentage
    }

    return TelemetryData(
      timestamp: DateTime.now(),
      pitch: currentData?.pitch ?? 0.0,
      roll: currentData?.roll ?? 0.0,
      yaw: currentData?.yaw ?? 0.0,
      altitude: currentData?.altitude ?? 0.0,
      speed: currentData?.speed ?? 0.0,
      battery: battery,
      temperature: currentData?.temperature ?? 0.0,
    );
  }

  /// Convert bytes to 32-bit float (little-endian)
  double _bytesToFloat32(Uint8List bytes, int offset) {
    final buffer = Uint8List.fromList(
        bytes.sublist(offset, offset + 4));
    return buffer.buffer.asFloat32List()[0];
  }

  /// Convert bytes to 32-bit int (little-endian)
  int _bytesToInt32(Uint8List bytes, int offset) {
    final buffer = Uint8List.fromList(
        bytes.sublist(offset, offset + 4));
    return buffer.buffer.asInt32List()[0];
  }

  /// Convert bytes to 16-bit int (little-endian)
  int _bytesToInt16(Uint8List bytes, int offset) {
    final buffer = Uint8List.fromList(
        bytes.sublist(offset, offset + 2));
    return buffer.buffer.asInt16List()[0];
  }

  /// Simulate MAVLink data reception (for testing)
  Future<void> _simulateMAVLinkData() async {
    int count = 0;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isConnected) {
        timer.cancel();
        return;
      }

      count++;
      
      // Generate simulated telemetry data
      final newData = TelemetryData(
        timestamp: DateTime.now(),
        pitch: (count % 45).toDouble() - 22.5,
        roll: ((count * 2) % 90).toDouble() - 45.0,
        yaw: ((count * 3) % 360).toDouble(),
        altitude: 50.0 + (count % 100).toDouble(),
        speed: 10.0 + (count % 20).toDouble(),
        battery: 100.0 - ((count * 0.5) % 30),
        temperature: 25.0 + (count % 10).toDouble(),
        pressure: 1013.25,
      );

      currentData = newData;
      history.add(newData);
      
      // Keep last 300 data points
      if (history.length > 300) {
        history.removeAt(0);
      }

      _lastDataTime = DateTime.now();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _healthCheckTimer?.cancel();
    super.dispose();
  }
}
