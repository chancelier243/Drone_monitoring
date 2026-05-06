# 🔌 Guide d'Activation - Vraie Communication 3DR

## 📌 Vue d'ensemble

Par défaut, le module 3DR fonctionne en **mode simulation** pour permettre des tests sans matériel.

Ce guide explique comment activer la **vraie communication** avec un module 3DR réel.

## 🎯 Étapes d'Activation

### Étape 1: Installer les dépendances

Choisissez **une** des options selon votre plateforme:

#### Option A: Port Série USB (Recommandé pour Windows/Linux/Mac)
```bash
cd /path/to/drone_monitoring
flutter pub add flutter_libserialport
```

#### Option B: Communication USB (Recommandé pour Android)
```bash
flutter pub add usb_serial
```

#### Option C: Communication Réseau (Déjà intégré)
Pas de dépendance supplémentaire nécessaire!

### Étape 2: Décommenter les imports

Ouvrez `lib/three_dr_service.dart` et décommentez les imports selon votre choix:

```dart
// Pour Option A (flutter_libserialport):
// import 'dart:typed_data';
// import 'package:flutter_libserialport/flutter_libserialport.dart';

// Pour Option B (usb_serial):
// import 'package:usb_serial/usb_serial.dart';

// Pour Option C (UDP/TCP):
// import 'dart:io';  // Déjà présent
```

### Étape 3: Implémenter la vraie connexion

Remplacez la méthode `connectToThreeDR()` dans `lib/three_dr_service.dart`:

#### Pour Option A: Port Série USB

```dart
Future<void> connectToThreeDR() async {
  try {
    if (connectionMode == ConnectionMode.serial) {
      // Importer d'abord:
      // import 'package:flutter_libserialport/flutter_libserialport.dart';
      
      final port = SerialPort(devicePort);
      port.openReadWrite();
      port.config.baudRate = baudRate;
      port.config.bits = 8;
      port.config.stopBits = 1;
      port.config.parity = UartParity.none;
      port.config.setFlowControl(flowControl: SerialPortFlowControl.none);
      
      isConnected = true;
      errorMessage = "";
      failedAttempts = 0;
      notifyListeners();
      
      // Démarrer la boucle de lecture
      final reader = SerialPortReader(port);
      reader.stream.listen((data) {
        if (isConnected) {
          final newData = _parseMAVLinkPacket(Uint8List.fromList(data));
          if (newData != null) {
            currentData = newData;
            history.add(newData);
            if (history.length > 300) history.removeAt(0);
            _lastDataTime = DateTime.now();
            notifyListeners();
          }
        }
      }, onError: (error) {
        isConnected = false;
        errorMessage = "Erreur lecture série: $error";
        notifyListeners();
      });
      
    } else if (connectionMode == ConnectionMode.udp) {
      // Implementation UDP
      _setupUDPConnection();
    }
  } catch (e) {
    isConnected = false;
    errorMessage = "Erreur: $e";
    failedAttempts++;
    notifyListeners();
  }
}

// Méthode helper pour UDP
Future<void> _setupUDPConnection() async {
  try {
    import 'dart:io';
    
    _udpSocket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      0,
    );
    
    _udpSocket!.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read && isConnected) {
        final datagram = _udpSocket!.receive();
        if (datagram != null) {
          final newData = _parseMAVLinkPacket(
            Uint8List.fromList(datagram.data)
          );
          if (newData != null) {
            currentData = newData;
            history.add(newData);
            if (history.length > 300) history.removeAt(0);
            _lastDataTime = DateTime.now();
            notifyListeners();
          }
        }
      }
    });
    
    isConnected = true;
    errorMessage = "";
    failedAttempts = 0;
    notifyListeners();
  } catch (e) {
    isConnected = false;
    errorMessage = "Erreur UDP: $e";
    failedAttempts++;
    notifyListeners();
  }
}
```

#### Pour Option B: Communication USB (Android)

```dart
Future<void> connectToThreeDR() async {
  try {
    import 'package:usb_serial/usb_serial.dart';
    
    List<UsbDevice> devices = await UsbSerial.listDevices();
    
    UsbDevice? targetDevice;
    for (var device in devices) {
      // Chercher FTDI (0x0403) ou CH340 (0x1A86)
      if ((device.vendorId == 0x0403 || device.vendorId == 0x1A86) &&
          (device.pid == 0x6015 || device.pid == 0x7523 || device.pid == 0xFFFF)) {
        targetDevice = device;
        break;
      }
    }
    
    if (targetDevice == null) {
      throw Exception("Module 3DR non détecté sur USB");
    }
    
    await targetDevice.create(
      usbFs: await UsbSerial.getUSBFileSystemRoot(),
    );
    
    _usbPort = await targetDevice.open();
    
    if (_usbPort == null) {
      throw Exception("Impossible d'ouvrir le port USB");
    }
    
    await _usbPort!.setDTR(true);
    await _usbPort!.setRTS(true);
    await _usbPort!.setPortParameters(
      baudRate: baudRate,
      dataBits: 8,
      stopBits: 1,
      parity: UsbPort.PARITY_NONE,
    );
    
    _usbPort!.inputStream?.listen((packet) {
      if (isConnected) {
        final newData = _parseMAVLinkPacket(Uint8List.fromList(packet));
        if (newData != null) {
          currentData = newData;
          history.add(newData);
          if (history.length > 300) history.removeAt(0);
          _lastDataTime = DateTime.now();
          notifyListeners();
        }
      }
    });
    
    isConnected = true;
    errorMessage = "";
    failedAttempts = 0;
    notifyListeners();
  } catch (e) {
    isConnected = false;
    errorMessage = "Erreur USB: $e";
    failedAttempts++;
    notifyListeners();
  }
}
```

#### Pour Option C: UDP/TCP (Déjà partiellement implémenté)

```dart
// UDP est déjà partiellement supporté, activez-le simplement
Future<void> connectToThreeDR() async {
  try {
    if (connectionMode == ConnectionMode.udp) {
      _socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        0,
      );
      
      _socket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = _socket!.receive();
          if (datagram != null) {
            _processMAVLinkData(Uint8List.fromList(datagram.data));
          }
        }
      });
      
      isConnected = true;
      errorMessage = "";
      failedAttempts = 0;
      notifyListeners();
    }
  } catch (e) {
    isConnected = false;
    errorMessage = "Erreur connexion: $e";
    failedAttempts++;
    notifyListeners();
  }
}

void _processMAVLinkData(Uint8List data) {
  final newData = _parseMAVLinkPacket(data);
  if (newData != null) {
    currentData = newData;
    history.add(newData);
    if (history.length > 300) history.removeAt(0);
    _lastDataTime = DateTime.now();
    notifyListeners();
  }
}
```

### Étape 4: Ajouter les variables d'instance

Ajoutez à la classe `ThreeDRService`:

```dart
// Pour port série
// import 'package:flutter_libserialport/flutter_libserialport.dart';
SerialPort? _serialPort;

// Pour USB
// import 'package:usb_serial/usb_serial.dart';
UsbPort? _usbPort;

// Pour UDP/TCP
import 'dart:io';
RawDatagramSocket? _socket;
RawSocket? _tcpSocket;
```

### Étape 5: Mettre à jour dispose()

```dart
@override
void dispose() {
  _healthCheckTimer?.cancel();
  
  // Nettoyer les connexions
  if (connectionMode == ConnectionMode.serial && _serialPort != null) {
    _serialPort!.close();
  } else if (connectionMode == ConnectionMode.udp && _socket != null) {
    _socket!.close();
  } else if (connectionMode == ConnectionMode.tcp && _tcpSocket != null) {
    _tcpSocket!.close();
  }
  
  // Pour USB
  _usbPort?.close();
  
  super.dispose();
}
```

## 🧪 Tests de Connexion

### Test 1: Vérifier les ports disponibles

```dart
import 'package:flutter_libserialport/flutter_libserialport.dart';

void listSerialPorts() {
  final ports = SerialPort.getAvailablePorts();
  print('Ports disponibles:');
  for (var port in ports) {
    print('  - $port');
  }
}
```

### Test 2: Tester la lecture du port

```dart
void testSerialRead() {
  final port = SerialPort('/dev/ttyUSB0');
  port.openReadWrite();
  
  final reader = SerialPortReader(port);
  int count = 0;
  reader.stream.listen((data) {
    print('Paquet $count: ${data.length} bytes');
    count++;
  });
}
```

### Test 3: Tester avec MAVProxy

```bash
# Linux/Mac
mavproxy.py --master=/dev/ttyUSB0 --baudrate=57600

# Puis sur un autre terminal
python3 -c "import socket; s=socket.socket(); s.bind(('127.0.0.1', 14550)); print('Connecté sur 14550')"
```

## 🔍 Dépannage

### Problème: Port série non trouvé

**Solutions**:
```bash
# Linux
ls -la /dev/tty* | grep USB

# Windows
# Vérifier Device Manager → Ports (COM & LPT)

# Mac
ls -la /dev/tty.*
```

### Problème: Permission refusée

```bash
# Linux
sudo chmod 666 /dev/ttyUSB0
# OU ajouter l'utilisateur au groupe dialout:
sudo usermod -a -G dialout $USER
# (nécessite de se reconnecter)
```

### Problème: Module 3DR non détecté

1. Vérifier que le module est bien alimenté (LED rouge)
2. Vérifier le câble USB
3. Installer les drivers FTDI:
   - **Windows**: https://ftdichip.com/drivers/
   - **Mac**: Installé automatiquement
   - **Linux**: `sudo apt install libftdi-dev`

### Problème: Pas de données reçues

1. Vérifier le débit: doit être 57600 baud
2. Vérifier la fréquence radio (900 MHz vs 433 MHz)
3. Vérifier l'alimentation du module
4. Essayer un autre câble USB

## 📊 Monitoring

Ajoutez dans la page de configuration:

```dart
// Afficher les stats de connexion
if (telemetryService.dataSource == DataSource.threeDR)
  Text('Paquets reçus: ${telemetryService.threeDRService.history.length}'),
  Text('Dernier paquet: ${telemetryService.threeDRService._lastDataTime}'),
```

## ✅ Checklist de Déploiement

- [ ] Dépendances installées
- [ ] Imports décommentés
- [ ] Méthodes implémentées
- [ ] Variables d'instance ajoutées
- [ ] dispose() mis à jour
- [ ] Tests locaux réussis
- [ ] Module 3DR détecté
- [ ] Données reçues correctement
- [ ] Historique enregistré
- [ ] UI mis à jour en temps réel

## 📞 Support

Pour problèmes spécifiques:

1. **flutter_libserialport**: https://github.com/chinmaygarde/flutter_libserialport
2. **usb_serial**: https://github.com/felHR85/usb_serial
3. **3DR/MAVLink**: https://3drobotics.com
4. **ArduPilot**: https://ardupilot.org

---

**Version**: 1.0
**Dernière mise à jour**: Mai 2026
