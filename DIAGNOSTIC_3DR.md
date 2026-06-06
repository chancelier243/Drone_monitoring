# Guide de Diagnostic - Réception Données 3DR

## 🔧 Problème Rapporté
L'app reçoit la connexion 3DR (détection et connexion OK) mais **ne reçoit pas les données** ou ne peut pas les traiter pour alimenter les onglets.

## ✅ Corrections Apportées

### 1. **Accumulation Progressive des Données MAVLink**
**Fichier**: `lib/three_dr_service.dart`

**Problème**: Chaque paquet MAVLink créait une `TelemetryData` complète avec des valeurs partielles. Par exemple:
- Paquet ATTITUDE → Met à jour pitch/roll/yaw, mais altitude/speed/battery = anciennes valeurs
- Paquet POSITION → Met à jour altitude/speed, mais pitch/roll/yaw = anciennes valeurs

Résultat: **Les onglets recevaient des données inconsistantes et incomplètes**

**Solution**: 
- Créer un `_mavLinkDataAccumulator` qui accumule TOUS les champs
- Chaque paquet met à jour UNIQUEMENT les champs qu'il contient
- Créer une `TelemetryData` COMPLÈTE tous les 50ms ou 3 paquets MAVLink
- Envoyer les données complètes aux onglets via `notifyListeners()`

### 2. **Synchronisation Historique Cassée**
**Fichier**: `lib/telemetry_service.dart`

**Problème**: La ligne:
```dart
history.addAll(threeDRService.history
    .where((data) => !history.contains(data)));
```

Utilisait `contains()` qui compare par **référence**, pas par valeur! 
- Les objets du 3DR et du service de télémétrie sont des instances différentes
- La comparaison ÉCHOUAIT toujours
- L'historique du 3DR n'était JAMAIS synchronisé

**Solution**:
```dart
if (threeDRService.history.isNotEmpty) {
  final lastIndex = history.length;
  if (lastIndex < threeDRService.history.length) {
    history.addAll(
      threeDRService.history.sublist(lastIndex)
    );
  }
}
```
- Utilise les **indices** pour copier uniquement les nouvelles données
- Pas de comparaison par référence

---

## 🧪 Comment Tester

### **Étape 1: Vérifier que l'app compile sans erreur**
```bash
cd c:\drone_monitoring
flutter pub get
flutter run -v
```

### **Étape 2: Activer les Logs de Debug**

#### Dans **main.dart** ou après la connexion 3DR, ajouter:
```dart
import 'debug_telemetry.dart';

// Dans la page de connexion, après confirmation:
DebugTelemetry.debugTelemetryFlow(telemetryService);
DebugTelemetry.debug3DRService(telemetryService.threeDRService);
```

#### Lancer l'app avec logs verbeux:
```bash
flutter run -v 2>&1 | Tee-Object -FilePath debug.log
```

### **Étape 3: Vérifier dans les Logs**

Chercher les patterns suivants:

#### ✅ **Logs de Connexion**
```
[3DR] Connecté au port série: COM3
```

#### ✅ **Logs de Paquets MAVLink**
```
[3DR] Donnée complète: alt=125.5m, spd=15.23m/s, bat=85%, pitch=12.5°
```
- Si ce log apparaît, les données sont reçues et parsées ✓
- S'il N'APPARAÎT PAS, il y a un problème dans le parsing MAVLink

#### ✅ **Vérifier currentData**
Dans les logs, chercher:
```
Current Data:
  - Timestamp: 2026-06-05 14:32:15
  - Pitch/Roll/Yaw: 12.5° / -5.3° / 45.2°
  - Altitude: 125.5 m
  - Speed: 15.23 m/s
  - Battery: 85%
```

Si `currentData: NULL - ⚠️`, les données n'arrivent pas.

### **Étape 4: Vérifier les Onglets**

| Onglet | Quoi Vérifier | Si ✓ | Si ✗ |
|--------|---------------|-----|-----|
| **Graphiques** | Les courbes montent | Les données arrivent | Les onglets ne se rafraîchissent pas |
| **Tableau** | Les chiffres changent | L'historique se peuple | Les données ne sont pas ajoutées |
| **Instruments** | L'horizon bouge | Les angles sont parsés | Les angles restent 0 |

---

## 🔍 Diagnostic Avancé

### **Problème: Aucune donnée ne s'affiche**

**Vérifier 1**: Paquets MAVLink reçus?
```
Chercher dans les logs: "Donnée complète:"
```
- **OUI** → Aller au vérifier 2
- **NON** → Problème de réception série/UDP/TCP (voir ci-dessous)

**Vérifier 2**: Historique se remplit?
```dart
print('History: ${telemetryService.history.length} items');
```
- **Croît** → Aller au vérifier 3
- **Statique** → Problème de synchronisation historique

**Vérifier 3**: Les onglets reçoivent les notifications?
```dart
// Dans la page/onglet, ajouter:
Consumer<TelemetryService>(
  builder: (context, service, child) {
    print('TelemetryService rebuilt: currentData=${service.currentData?.altitude}');
    // ...
  }
)
```
- **Logs affichent les valeurs** → Consumer fonctionne ✓
- **Rien** → Provider n'est pas mis en place correctement

---

### **Problème: Pas de paquets MAVLink**

#### Option 1: Mode Série
```bash
# Vérifier les ports disponibles
Get-Content 'HKLM:\Hardware\DeviceMap\SerialComm'
```

Vérifier dans l'app:
- **Settings** → "Configurer les sources"
- Le port COM devrait être listé
- Sélectionner le port 3DR
- Vérifier: **Débit 57600 baud**

#### Option 2: Mode UDP (Mission Planner)
Tester avec **netcat**:
```bash
# Terminal 1 - Écouter sur le port UDP
nc -u -l 127.0.0.1 14550

# Terminal 2 - Tester la connexion
echo "test" | nc -u 127.0.0.1 14550
```

L'app UDP devrait recevoir quelque chose.

#### Option 3: Mode TCP
```bash
# Écouter sur le port TCP
nc -l 127.0.0.1 5760
```

---

## 📊 Vérifier les Données Complètes

### Ajouter ce code dans **mission_control_page.dart** ou **charts_page.dart**:

```dart
Consumer<TelemetryService>(
  builder: (context, service, child) {
    final data = service.displayData;
    
    if (data != null) {
      return Column(
        children: [
          Text('ALT: ${data.altitude.toStringAsFixed(1)}m', 
               style: TextStyle(color: Colors.green)),
          Text('SPD: ${data.speed.toStringAsFixed(2)}m/s',
               style: TextStyle(color: Colors.blue)),
          Text('BAT: ${data.battery.toStringAsFixed(0)}%',
               style: TextStyle(color: Colors.orange)),
          Text('PITCH: ${data.pitch.toStringAsFixed(1)}°',
               style: TextStyle(color: Colors.cyan)),
        ],
      );
    }
    
    return Text('Pas de données');
  }
)
```

---

## 🚀 Prochaines Étapes

1. **Lancer l'app**: `flutter run`
2. **Aller à Settings** → Configurer les sources 3DR
3. **Sélectionner le port/mode** et connecter
4. **Regarder les logs** pour voir "[3DR] Donnée complète:"
5. **Ouvrir les onglets** (Graphiques, Tableau, Instruments)
6. **Vérifier que les données s'affichent**

Si après ces étapes les onglets restent vides:
- **Copier-coller les logs de debug**
- **Vérifier les offsets MAVLink** (voir mavlink_test.dart)
- **Tester directement la réception série** avec PuTTY/netcat

---

## 💡 Notes Importantes

- Les corrections ont été testées pour compiler sans erreur ✅
- Les logs améliorés vous aideront à identifier exactement où le problème se situe
- Si aucune donnée n'arrive, le problème est dans les paramètres de connexion (port, débit, adresse IP)
- Si des données arrivent mais les onglets ne s'affichent pas, c'est un problème de Provider/Consumer

Bon luck! 🎯
