# 📡 Intégration Module 3DR FPV Télémétrie

## Vue d'ensemble

L'application Drone Monitoring supporte maintenant deux sources de données pour la télémétrie du drone:

1. **Serveur HTTP** - Mode existant (recommandé pour testing/simulation)
2. **Module 3DR Radio Télémétrie** - Mode nouveau (pour drone réel)

## Architecture

### Services de Télémétrie

- **`TelemetryService`** - Service principal qui gère les deux sources
- **`ThreeDRService`** - Service dédié au module 3DR (MAVLink, communication série/UDP)

### Modes de Connexion 3DR

#### 1. Port Série (USB)
```
Mode: Serial
Port: /dev/ttyUSB0 (Linux/Mac) ou COM3/COM4 (Windows)
Débit: 57600 baud (standard MAVLink)
Cas d'usage: Connexion directe USB du module 3DR au PC
```

#### 2. UDP (Réseau)
```
Mode: UDP
Host: 192.168.1.1 (IP du module 3DR)
Port: 14550 (port standard MAVLink)
Cas d'usage: Communication via réseau local
```

#### 3. TCP (Réseau)
```
Mode: TCP
Host: 192.168.1.1
Port: 14550+
Cas d'usage: Communication TCP (moins courant)
```

## Protocole MAVLink

Le module 3DR utilise le protocole **MAVLink** pour communiquer. Les messages supportés:

- **Message #30 (ATTITUDE)** - Pitch, Roll, Yaw
- **Message #33 (GLOBAL_POSITION_INT)** - Altitude, Vitesse, Position GPS
- **Message #42 (POWER_STATUS)** - Statut batterie

### Format MAVLink
```
[STX] [LEN] [SEQ] [SYSID] [COMPID] [MSGID] [PAYLOAD] [CRC1] [CRC2]
0xFE  [1]   [1]   [1]     [1]     [1]     [variable] [1]    [1]
```

## Utilisation

### 1. Basculer entre les sources

```dart
// Via TelemetryService
final telemetryService = Provider.of<TelemetryService>(context);

// Passer à la source serveur
await telemetryService.switchDataSource(DataSource.server);

// Passer à la source 3DR
await telemetryService.switchDataSource(DataSource.threeDR);
```

### 2. Configurer le module 3DR

```dart
telemetryService.configureThreeDR(
  mode: ThreeDRService.ConnectionMode.udp,
  host: '192.168.1.1',
  remotePort: 14550,
);
```

### 3. Interface utilisateur

Accédez à la page de configuration depuis Settings → "Configurer les sources"

## Dépendances

Les packages utilisés (optionnels pour communication réelle):

```yaml
# Pour communication série réelle (activer si nécessaire)
# flutter_libserialport: ^0.2.0

# Pour USB réel
# usb_serial: ^0.2.4
```

## Améliorations Futures

- [ ] Connexion série réelle via `flutter_libserialport`
- [ ] Communication UDP réelle
- [ ] Support de plus de messages MAVLink
- [ ] Détection automatique de ports sériels
- [ ] Stockage des paramètres de configuration
- [ ] Enregistrement des connexions 3DR
- [ ] Support multi-drone via MAVLink System IDs
- [ ] Calibration de capteurs via MAVLink
- [ ] Mise à jour firmware du module 3DR

## Spécifications Module 3DR

**Radio Télémétrie 3DR**
- Fréquence: 900 MHz (ou 433 MHz suivant région)
- Portée: 1-4 km
- Vitesse: jusqu'à 250 kbps
- Interface: Port série FTDI USB
- Protocole: MAVLink
- Alimentation: 4.75-5.25V
- Consommation: ~100mA en transmission

## Dépannage

### Problème: "Pas de données reçues"

**Solutions:**
1. Vérifiez que le module 3DR est alimenté
2. Vérifiez le bon port (USB reconnu?)
3. Testez avec l'outil MAVProxy: `mavproxy.py --master=/dev/ttyUSB0 --baudrate=57600`
4. Vérifiez la fréquence radio (900 MHz vs 433 MHz)

### Problème: "Connection refused"

**Solutions:**
1. Le port série n'est pas accessible
2. Vérifiez les permissions: `sudo chmod 666 /dev/ttyUSB0` (Linux)
3. Installez les drivers FTDI si nécessaire

### Problème: "MAVLink parse error"

**Solutions:**
1. Le format du paquet est invalide
2. Vérifiez le débit (doit être 57600)
3. Essayez de redémarrer le module 3DR

## Fichiers Modifiés

- `lib/three_dr_service.dart` - Nouveau service pour 3DR
- `lib/telemetry_service.dart` - Intégration des deux sources
- `lib/data_source_config_page.dart` - Nouvelle page de configuration
- `lib/settings_page.dart` - Lien vers configuration
- `lib/main.dart` - Import de la nouvelle page
- `pubspec.yaml` - Commentaires sur dépendances optionnelles

## Exemple d'utilisation complet

```dart
// Dans un Widget
Consumer<TelemetryService>(
  builder: (context, telemetryService, _) {
    return Column(
      children: [
        Text('Source: ${telemetryService.dataSource.toString()}'),
        if (telemetryService.isConnected)
          Text('✓ Connecté')
        else
          Text('✗ Déconnecté'),
        
        // Afficher les données (sources mélangées automatiquement)
        if (telemetryService.currentData != null)
          DroneDataWidget(data: telemetryService.currentData!),
      ],
    );
  },
)
```

## Contact & Support

Pour des questions sur le module 3DR:
- 3DRobotics: https://3drobotics.com
- ArduPilot Documentation: https://ardupilot.org
- MAVLink Protocol: https://mavlink.io
