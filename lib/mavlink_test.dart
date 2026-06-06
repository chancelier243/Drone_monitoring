/// Test et diagnostic du flux de données 3DR
/// Utilisez ce fichier pour déboguer les problèmes de réception MAVLink

import 'dart:typed_data';

/// Teste le parsing MAVLink basique
void testMAVLinkParsing() {
  print('=== TEST PARSING MAVLink ===\n');
  
  // Exemple de paquet MAVLink ATTITUDE (msgId 30)
  // Format: FE LEN SEQ SYS COMP MSG [DATA...] CK1 CK2
  final attitudePacket = Uint8List.fromList([
    0xFE, // Header
    0x1C, // Longueur (28 bytes de payload)
    0x01, // Numéro de séquence
    0x01, // ID système
    0x01, // ID composant
    0x1E, // Message ID (30 = ATTITUDE)
    // Payload (28 bytes)
    0x00, 0x00, 0x00, 0x00, // time_boot_ms (4 bytes)
    0x00, 0x00, 0x80, 0x3F, // roll (1.0 radians = 57.3°)
    0x00, 0x00, 0x00, 0x3F, // pitch (0.5 radians = 28.6°)
    0x00, 0x00, 0x00, 0x00, // yaw (0 radians = 0°)
    0x00, 0x00, 0x00, 0x00, // rollspeed
    0x00, 0x00, 0x00, 0x00, // pitchspeed
    0x00, 0x00, 0x00, 0x00, // yawspeed
    0xAA, 0xBB, // Checksums (pas validés ici)
  ]);
  
  print('Paquet ATTITUDE test créé');
  print('Longueur: ${attitudePacket.length} bytes');
  print('Header (0xFE): ${attitudePacket[0] == 0xFE ? '✓' : '✗'}');
  print('Message ID (30): ${attitudePacket[5]}');
  print('');
  
  // Exemple de paquet GLOBAL_POSITION_INT (msgId 33)
  final positionPacket = Uint8List.fromList([
    0xFE, // Header
    0x1C, // Longueur
    0x02, // Séquence
    0x01, 0x01,
    0x21, // Message ID (33 = GLOBAL_POSITION_INT)
    0x00, 0x00, 0x00, 0x00, // time_boot_ms
    0x00, 0x00, 0x00, 0x00, // lat
    0x00, 0x00, 0x00, 0x00, // lon
    0xE8, 0x03, 0x00, 0x00, // alt (1000 mm = 1 m)
    0x64, 0x00, 0x00, 0x00, // relative_alt (100 mm = 0.1 m)
    0x00, 0x00, 0x64, 0x00, // vx, vy (100 cm/s = 1 m/s)
    0x00, 0x00, 0x00, 0x00, // vz, hdg
    0xAA, 0xBB,
  ]);
  
  print('Paquet GLOBAL_POSITION_INT créé');
  print('Message ID (33): ${positionPacket[5]}');
  print('Altitude encoded: ${positionPacket.length} bytes');
  print('');
  
  // Test du parsing d'un float32
  final float32Bytes = Uint8List.fromList([0x00, 0x00, 0x80, 0x3F]);
  final float32 = _bytesToFloat32(float32Bytes, 0);
  print('Float32 parsing test (devrait être ~1.0): $float32');
  print('Convertir en degrés: ${float32 * 180 / 3.14159} °');
}

/// Teste la détection des paquets dans un flux
void testPacketDetection() {
  print('\n=== TEST DÉTECTION PAQUETS ===\n');
  
  // Simuler un flux avec plusieurs paquets et du bruit
  final stream = Uint8List.fromList([
    0xFF, 0xFF, 0xFF, // Bruit
    0xFE, 0x08, 0x01, 0x01, 0x01, 0x1E, 0x00, 0x00, 0x00, 0x00, 0xAA, 0xBB, // Petit paquet
    0xFF, 0xFF, // Plus de bruit
    0xFE, 0x04, 0x02, 0x01, 0x01, 0x21, 0xCC, 0xDD, 0xEE, 0xFF, // Un autre paquet
  ]);
  
  print('Stream total: ${stream.length} bytes');
  print('Cherchant les headers MAVLink (0xFE)...');
  
  int packetCount = 0;
  for (int i = 0; i < stream.length; i++) {
    if (stream[i] == 0xFE) {
      if (i + 6 <= stream.length) {
        final length = stream[i + 1];
        if (i + 6 + length + 2 <= stream.length) {
          print('✓ Paquet détecté à offset $i (longueur: $length)');
          packetCount++;
        } else {
          print('✗ Paquet incomplet à offset $i');
        }
      }
    }
  }
  
  print('Total paquets valides trouvés: $packetCount');
}

/// Convertir bytes en float32 (little-endian)
double _bytesToFloat32(Uint8List bytes, int offset) {
  final buffer = Uint8List.fromList(bytes.sublist(offset, offset + 4));
  return buffer.buffer.asFloat32List()[0];
}

/// Affiche les instructions de debugging
void printDebugInstructions() {
  print('''
=== INSTRUCTIONS DE DEBUG ===

1. ACTIVER LES LOGS:
   - Ouvrir l'app en mode debug: flutter run -v
   - Chercher les logs [3DR] et [MAVLink]

2. VÉRIFIER LA CONNEXION:
   - Settings → "Configurer les sources"
   - Sélectionner mode: Serial/UDP/TCP
   - Vérifier que "Connecté" devient vert

3. TRACER LES DONNÉES:
   - Dans main.dart, ajouter: DebugTelemetry.debugTelemetryFlow(service);
   - Vérifier que currentData n'est pas NULL
   - Vérifier que l'historique grandit

4. VÉRIFIER LES PAQUETS MAVLink:
   - Chercher "paquets reçus" dans les logs
   - Counter devrait incrémenter > 0
   - Si = 0, le parser MAVLink ne détecte pas les paquets

5. VÉRIFIER LES ONGLETS:
   - Graphiques/Tableau doivent afficher les données
   - Si vide, le Provider n'est pas mis à jour correctement
   - Vérifier Consumer<TelemetryService> dans les onglets

6. SERIAL PORT:
   - Vérifier le débit: 57600 baud (standard MAVLink)
   - Vérifier les paramètres: 8 bits, 1 stop, pas de parité
   - Utiliser un outil comme PuTTY pour vérifier les données brutes

7. UDP/TCP:
   - Vérifier l'IP et le port
   - Pour Mission Planner: 127.0.0.1:14550 (UDP) ou 5760 (TCP)
   - Tester avec netcat: nc -l 14550

''');
}
