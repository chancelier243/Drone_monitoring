import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'data_model.dart';

/// Mode de connexion pour le module de télémétrie 3DR
enum ConnectionMode { serial, udp, tcp }

/// Information sur un module 3DR détecté
class ThreeDRDevice {
  final String portName;
  final String description;
  final int vendorId;
  final int deviceId;
  final String productName;
  
  ThreeDRDevice({
    required this.portName,
    required this.description,
    required this.vendorId,
    required this.deviceId,
    required this.productName,
  });
  
  @override
  String toString() => '$productName ($portName)';
}

/// Service pour communiquer avec le module de télémétrie radio FPV 3DR
/// Supporte le protocole MAVLink et la communication série réelle
class ThreeDRService extends ChangeNotifier {
  TelemetryData? currentData;
  List<TelemetryData> history = [];
  
  bool isConnected = false;
  String errorMessage = "";
  int failedAttempts = 0;
  
  // Paramètres de connexion
  String devicePort = "";
  int baudRate = 57600; // Standard pour MAVLink
  String remoteHost = "192.168.1.1";
  int remotePort = 14550;
  
  ConnectionMode connectionMode = ConnectionMode.serial;
  
  // Ports et modules détectés
  List<ThreeDRDevice> availableDevices = [];
  ThreeDRDevice? selectedDevice;
  
  // Communication série réelle
  SerialPort? _serialPort;
  SerialPortReader? _reader;
  StreamSubscription? _subscription;
  
  // Communication UDP/TCP
  RawDatagramSocket? _udpSocket;
  StreamSubscription<RawSocketEvent>? _udpSubscription;
  
  Timer? _healthCheckTimer;
  DateTime? _lastDataTime;
  
  int? scrubbedIndex;
  
  // Compteur de paquets pour débug
  int _packetCount = 0;

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

  /// Obtenir la liste des ports sériels disponibles
  List<String> getAvailablePorts() {
    try {
      return SerialPort.availablePorts;
    } catch (e) {
      if (kDebugMode) print("Erreur obtention ports: $e");
      return [];
    }
  }

  /// Détecter les modules 3DR connectés
  Future<List<ThreeDRDevice>> detectThreeDRDevices() async {
    availableDevices.clear();
    
    try {
      final ports = getAvailablePorts();
      
      for (final port in ports) {
        try {
          final sp = SerialPort(port);
          
          // Vérifier si c'est un FTDI (module 3DR)
          // Vendors: FTDI (0x0403), CH340 (0x1A86), Silabs (0x10C4)
          if (sp.vendorId == 0x0403 || 
              sp.vendorId == 0x1A86 || 
              sp.vendorId == 0x10C4) {
            
            final device = ThreeDRDevice(
              portName: port,
              description: sp.description ?? 'Inconnu',
              vendorId: sp.vendorId ?? 0,
              deviceId: sp.productId ?? 0,
              productName: _getProductName(sp.vendorId ?? 0, port),
            );
            
            availableDevices.add(device);
            
            if (kDebugMode) {
              print('Détecté: ${device.productName} sur $port');
            }
          }
        } catch (e) {
          if (kDebugMode) print("Erreur vérification port $port: $e");
        }
      }
      
      notifyListeners();
      return availableDevices;
    } catch (e) {
      errorMessage = "Erreur détection modules: $e";
      notifyListeners();
      return [];
    }
  }

  /// Obtenir le nom du produit selon le Vendor ID
  String _getProductName(int vendorId, String port) {
    switch (vendorId) {
      case 0x0403:
        return "3DR Radio Telemetry (FTDI)";
      case 0x1A86:
        return "Module CH340 (Copie 3DR)";
      case 0x10C4:
        return "Module Silicon Labs";
      default:
        return "Module Inconnu ($port)";
    }
  }

  /// Sélectionner un module 3DR
  void selectDevice(ThreeDRDevice device) {
    selectedDevice = device;
    devicePort = device.portName;
    notifyListeners();
  }

  /// Configurer les paramètres de connexion
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

  /// Connecter au module 3DR sélectionné (serial) ou à Mission Planner (UDP/TCP)
  Future<void> connectToThreeDR() async {
    try {
      // Déconnecter les connexions précédentes
      await disconnectFromThreeDR();
      
      if (connectionMode == ConnectionMode.serial) {
        await _connectSerial();
      } else if (connectionMode == ConnectionMode.udp) {
        await _connectUDP();
      } else if (connectionMode == ConnectionMode.tcp) {
        throw Exception("TCP non encore implémenté");
      }
      
      _packetCount = 0;
      notifyListeners();
    } catch (e) {
      isConnected = false;
      errorMessage = "Erreur connexion: $e";
      failedAttempts++;
      
      if (kDebugMode) print("Erreur connexion 3DR: $e");
      
      notifyListeners();
    }
  }

  /// Connecter via port série
  Future<void> _connectSerial() async {
    if (devicePort.isEmpty && selectedDevice == null) {
      throw Exception("Aucun appareil sélectionné");
    }

    final port = selectedDevice?.portName ?? devicePort;
    
    if (port.isEmpty) {
      throw Exception("Port non valide");
    }

    _serialPort = SerialPort(port);
    
    if (!_serialPort!.openReadWrite()) {
      throw Exception("Impossible d'ouvrir le port $port");
    }

    _serialPort!.config.baudRate = baudRate;
    _serialPort!.config.bits = 8;
    _serialPort!.config.stopBits = 1;
    _serialPort!.config.parity = SerialPortParity.none;
    _serialPort!.config.setFlowControl(SerialPortFlowControl.none);

    _reader = SerialPortReader(_serialPort!);
    _subscription = _reader!.stream.listen(
      _onSerialData,
      onError: _onSerialError,
    );

    isConnected = true;
    errorMessage = "";
    failedAttempts = 0;
    
    if (kDebugMode) print("Connecté au port série: $port");
  }

  /// Connecter via UDP (pour Mission Planner)
  Future<void> _connectUDP() async {
    if (remoteHost.isEmpty) {
      throw Exception("Adresse IP vide");
    }

    // Se connecter à Mission Planner (localhost:14550 par défaut)
    _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    
    if (kDebugMode) print("Socket UDP créé sur le port ${_udpSocket!.port}");
    
    // Écouter les données entrantes
    _udpSubscription = _udpSocket!.listen(
      (RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          try {
            final datagram = _udpSocket!.receive();
            if (datagram != null) {
              _onUDPData(datagram.data);
            }
          } catch (e) {
            if (kDebugMode) print("Erreur lecture UDP: $e");
          }
        }
      },
      onError: (error) {
        isConnected = false;
        errorMessage = "Erreur UDP: $error";
        if (kDebugMode) print("Erreur UDP: $error");
        notifyListeners();
      },
      onDone: () {
        isConnected = false;
        if (kDebugMode) print("Socket UDP fermé");
        notifyListeners();
      },
    );

    isConnected = true;
    errorMessage = "";
    failedAttempts = 0;
    _lastDataTime = DateTime.now();
    
    if (kDebugMode) print("Connecté en UDP: $remoteHost:$remotePort");
  }


  /// Gérer les données reçues du port série
  void _onSerialData(Uint8List data) {
    if (!isConnected) return;

    try {
      // Parser les paquets MAVLink
      _parseMAVLinkStream(data);
      _lastDataTime = DateTime.now();
    } catch (e) {
      if (kDebugMode) print("Erreur parsing données: $e");
    }
  }

  /// Gérer les erreurs du port série
  void _onSerialError(dynamic error) {
    isConnected = false;
    errorMessage = "Erreur série: $error";
    
    if (kDebugMode) print("Erreur série 3DR: $error");
    
    notifyListeners();
  }

  /// Gérer les données reçues via UDP
  void _onUDPData(Uint8List data) {
    if (!isConnected) return;

    try {
      // Parser les paquets MAVLink (même format que série)
      _parseMAVLinkStream(data);
      _lastDataTime = DateTime.now();
    } catch (e) {
      if (kDebugMode) print("Erreur parsing UDP: $e");
    }
  }

  /// Parser le flux de données MAVLink
  void _parseMAVLinkStream(Uint8List data) {
    // Chercher le header MAVLink (0xFE)
    for (int i = 0; i < data.length; i++) {
      if (data[i] == 0xFE) {
        // Vérifier qu'on a assez de données pour un en-tête
        if (i + 6 <= data.length) {
          final length = data[i + 1];
          
          // Vérifier qu'on a le paquet complet
          if (i + 6 + length + 2 <= data.length) {
            final packet = data.sublist(i, i + 6 + length + 2);
            final parsed = _parseMAVLinkPacket(packet);
            
            if (parsed != null) {
              currentData = parsed;
              history.add(parsed);
              
              // Limiter l'historique à 300 points
              if (history.length > 300) {
                history.removeAt(0);
              }
              
              _packetCount++;
              notifyListeners();
            }
          }
        }
      }
    }
  }

  /// Parser un paquet MAVLink individuel
  TelemetryData? _parseMAVLinkPacket(Uint8List packet) {
    try {
      if (packet.length < 8 || packet[0] != 0xFE) {
        return null;
      }

      final length = packet[1];
      if (packet.length < 6 + length + 2) {
        return null;
      }

      // ignore unused parameters
      final msgId = packet[5];
      
      // Parser selon le type de message
      switch (msgId) {
        case 30: // ATTITUDE
          return _parseAttitude(packet);
        case 33: // GLOBAL_POSITION_INT
          return _parseGlobalPositionInt(packet);
        case 42: // POWER_STATUS
          return _parsePowerStatus(packet);
        case 24: // GPS_RAW_INT
          return _parseGPSRawInt(packet);
        default:
          return null;
      }
    } catch (e) {
      if (kDebugMode) print("Erreur parsing paquet: $e");
      return null;
    }
  }

  /// Parser message ATTITUDE (msgId 30)
  TelemetryData _parseAttitude(Uint8List packet) {
    double roll = 0, pitch = 0, yaw = 0;
    
    if (packet.length >= 17) {
      try {
        // Offset 6 = payload start
        // Format: F F F (3x float32 radians) + F F F (3x float32 rad/s)
        final data = packet.sublist(6);
        roll = _bytesToFloat32(data, 0);
        pitch = _bytesToFloat32(data, 4);
        yaw = _bytesToFloat32(data, 8);
      } catch (e) {
        if (kDebugMode) print("Erreur parsing ATTITUDE: $e");
      }
    }

    return TelemetryData(
      timestamp: DateTime.now(),
      pitch: pitch * 180 / 3.14159, // Convertir en degrés
      roll: roll * 180 / 3.14159,
      yaw: yaw * 180 / 3.14159,
      altitude: currentData?.altitude ?? 0.0,
      speed: currentData?.speed ?? 0.0,
      battery: currentData?.battery ?? 100.0,
      temperature: currentData?.temperature ?? 25.0,
    );
  }

  /// Parser message GLOBAL_POSITION_INT (msgId 33)
  TelemetryData _parseGlobalPositionInt(Uint8List packet) {
    double altitude = 0, speed = 0;
    
    if (packet.length >= 32) {
      try {
        final data = packet.sublist(6);
        // Uint32 time_boot_ms (offset 0)
        // Int32 lat (offset 4)
        // Int32 lon (offset 8)
        // Int32 alt (offset 12) - altitude in mm
        // Int32 relative_alt (offset 16) - relative altitude in mm
        // Int16 vx (offset 20) - velocity x
        // Int16 vy (offset 22) - velocity y
        // Int16 vz (offset 24) - velocity z
        // Uint16 hdg (offset 26) - heading
        
        altitude = _bytesToInt32(data, 16) / 1000.0; // Relative altitude en mètres
        
        final vx = _bytesToInt16(data, 20) / 100.0;
        final vy = _bytesToInt16(data, 22) / 100.0;
        speed = sqrt((vx * vx + vy * vy).toDouble());
      } catch (e) {
        if (kDebugMode) print("Erreur parsing GLOBAL_POSITION: $e");
      }
    }

    return TelemetryData(
      timestamp: DateTime.now(),
      pitch: currentData?.pitch ?? 0.0,
      roll: currentData?.roll ?? 0.0,
      yaw: currentData?.yaw ?? 0.0,
      altitude: altitude,
      speed: speed,
      battery: currentData?.battery ?? 100.0,
      temperature: currentData?.temperature ?? 25.0,
    );
  }

  /// Parser message POWER_STATUS (msgId 42)
  TelemetryData _parsePowerStatus(Uint8List packet) {
    double battery = 100.0;
    
    if (packet.length >= 12) {
      try {
        final data = packet.sublist(6);
        // Uint16 Vcc (offset 0) - voltage in mV
        // Uint16 Vservo (offset 2)
        // Uint16 flags (offset 4)
        
        final vcc = _bytesToInt16(data, 0);
        battery = (vcc / 1000.0) * 50.0; // Convertir en pourcentage
        battery = battery.clamp(0, 100).toDouble();
      } catch (e) {
        if (kDebugMode) print("Erreur parsing POWER_STATUS: $e");
      }
    }

    return TelemetryData(
      timestamp: DateTime.now(),
      pitch: currentData?.pitch ?? 0.0,
      roll: currentData?.roll ?? 0.0,
      yaw: currentData?.yaw ?? 0.0,
      altitude: currentData?.altitude ?? 0.0,
      speed: currentData?.speed ?? 0.0,
      battery: battery,
      temperature: currentData?.temperature ?? 25.0,
    );
  }

  /// Parser message GPS_RAW_INT (msgId 24)
  TelemetryData _parseGPSRawInt(Uint8List packet) {
    return TelemetryData(
      timestamp: DateTime.now(),
      pitch: currentData?.pitch ?? 0.0,
      roll: currentData?.roll ?? 0.0,
      yaw: currentData?.yaw ?? 0.0,
      altitude: currentData?.altitude ?? 0.0,
      speed: currentData?.speed ?? 0.0,
      battery: currentData?.battery ?? 100.0,
      temperature: currentData?.temperature ?? 25.0,
    );
  }

  /// Convertir bytes en float32 (little-endian)
  double _bytesToFloat32(Uint8List bytes, int offset) {
    final buffer = Uint8List.fromList(bytes.sublist(offset, offset + 4));
    return buffer.buffer.asFloat32List()[0];
  }

  /// Convertir bytes en int32 (little-endian)
  int _bytesToInt32(Uint8List bytes, int offset) {
    final buffer = Uint8List.fromList(bytes.sublist(offset, offset + 4));
    return buffer.buffer.asInt32List()[0];
  }

  /// Convertir bytes en int16 (little-endian)
  int _bytesToInt16(Uint8List bytes, int offset) {
    final buffer = Uint8List.fromList(bytes.sublist(offset, offset + 2));
    return buffer.buffer.asInt16List()[0];
  }

  /// Vérifier la santé de la connexion
  void _initializeHealthCheck() {
    _healthCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkConnectionHealth();
    });
  }

  void _checkConnectionHealth() {
    final now = DateTime.now();
    if (isConnected && _lastDataTime != null) {
      final timeSinceLastData = now.difference(_lastDataTime!);
      if (timeSinceLastData.inSeconds > 10) {
        isConnected = false;
        errorMessage =
            "Pas de données reçues depuis ${timeSinceLastData.inSeconds}s";
        notifyListeners();
      }
    }
  }

  /// Déconnecter du module 3DR (série, UDP, etc.)
  Future<void> disconnectFromThreeDR() async {
    try {
      // Fermer la connexion série
      _subscription?.cancel();
      _reader = null;
      
      if (_serialPort != null) {
        _serialPort!.close();
        _serialPort = null;
      }
      
      // Fermer la connexion UDP
      _udpSubscription?.cancel();
      _udpSocket?.close();
      _udpSocket = null;
      
      isConnected = false;
      errorMessage = "";
      
      if (kDebugMode) print("Déconnecté du module 3DR");
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("Erreur déconnexion: $e");
    }
  }

  /// Obtenir les stats de connexion
  String getConnectionStats() {
    return 'Paquets: $_packetCount | Port: ${selectedDevice?.portName ?? devicePort}';
  }

  @override
  void dispose() {
    _healthCheckTimer?.cancel();
    _subscription?.cancel();
    disconnectFromThreeDR();
    super.dispose();
  }
}
