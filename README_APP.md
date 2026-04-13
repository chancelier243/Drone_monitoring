# 🚁 Drone Monitoring System - Application Flutter

Une application complète de surveillance et d'analyse des données de vol en temps réel pour "Flight Data Monitoring System" (FDMS).

## ✨ Fonctionnalités

### 📊 Dashboard Principal
- **Horizon Artificiel** : Visualisation 3D de l'altitude et de l'inclinaison du drone
- **Affichage en Temps Réel** : Les données se mettent à jour automatiquement chaque seconde
- **Paramètres Clés** : Altitude, Vitesse, Température, Batterie, Angles (Pitch, Roll, Yaw)
- **Système d'Alertes** : Notifications visuelles pour les anomalies détectées
- **Statut de Connexion** : Indicateur visuel de l'état de la connexion au serveur

### 📈 Graphiques Dynamiques
- Sélection interactive de 5 graphiques différents :
  - Altitude dans le temps
  - Vitesse instantanée
  - Température du système
  - Tension de batterie
  - Angles de vol combinés (Pitch + Roll + Yaw)
- Historique des 100 derniers points de données
- Statistiques en temps réel (min, max, moyenne)

### 📋 Tableau Détaillé
- Historique complet de tous les paramètres
- 8 colonnes : Temps, Altitude, Vitesse, Température, Batterie, Pitch, Roll, Yaw
- Codage couleur pour une identification rapide
- Scroll horizontal et vertical pour tous les appareils

### ⚙️ Configuration Flexible
- Modification dynamique de l'URL du serveur
- Reconnexion instantanée
- Gestion d'erreurs robuste avec messages d'information

## 🛠️ Architecture Technique

### Stack Technologique
- **Flutter** : Framework multi-plateforme
- **Dart** : Langage de programmation
- **Provider** : Gestion d'état réactive
- **FL Chart** : Bibliothèque de graphiques
- **HTTP** : Communication REST avec le serveur

### Structure du Projet
```
lib/
├── main.dart                  # Point d'entrée, navigation
├── data_model.dart            # Modèle de données TelemetryData
├── telemetry_service.dart     # Service HTTP + gestion d'état
├── mission_control_page.dart  # Dashboard principal
├── charts_page.dart           # Graphiques dynamiques
└── table_page.dart            # Tableau de données
```

## 🚀 Guide de Démarrage Rapide

### Prérequis
- **Flutter** (3.11.1+) - [Installer](https://flutter.dev)
- **Dart** (inclus avec Flutter)
- **Serveur FastAPI** en cours d'exécution
- **Connexion réseau** vers le serveur

### Installation

1. **Clonez/Accédez au projet**
```bash
cd c:\drone_monoitoring
```

2. **Installez les dépendances**
```bash
flutter pub get
```

3. **Lancez l'application**
```bash
# Option A : Avec le script batch (Windows)
run_app.bat

# Option B : Directement
flutter run
```

### Configuration du Serveur

L'application s'attend à ce que le serveur FastAPI soit accessible à :
```
http://localhost:8000
```

**Si le serveur est sur une autre IP :**
1. Cliquez sur le bouton ⚙️ en bas à droite du Dashboard
2. Entrez l'adresse IP : `http://192.168.X.X:8000`
3. Cliquez "Appliquer"

## 📱 Plateformes Supportées

| Plateforme | Support | Notes |
|------------|---------|-------|
| Android | ✅ | 4.1+ |
| iOS | ✅ | 11.0+ |
| Windows | ✅ | SDK natif |
| Linux | ✅ | GTK3+ |
| macOS | ✅ | 10.11+ |
| Web | ✅ | Navigateurs modernes |

## 🔌 API REST Utilisée

L'application communique avec votre serveur FastAPI via ces endpoints :

| Endpoint | Méthode | Fréquence | Usage |
|----------|---------|-----------|-------|
| `/latest-data` | GET | 1s | Récupère la dernière donnée |
| `/health` | GET | On-demand | Vérifie l'état du serveur |

**Format des données reçues :**
```json
{
  "timestamp": "2024-01-15 14:30:45",
  "temperature": 42.5,
  "altitude": 150.8,
  "vitesse": 8.3,
  "batterie": 11.2,
  "roll": 5.2,
  "pitch": 3.1,
  "yaw": 45.0,
  "alerts": ["Température inhabituelle"]
}
```

## 🧪 Test avec Données Simulées

Pour tester sans drone physique :

### Option 1 : Script PowerShell (Recommandé pour Windows)
```powershell
# Exécuter le script de test
.\test_with_mock_data.ps1
```

Cela génère automatiquement un vol simulé de 60 secondes et envoie les données au serveur.

### Option 2 : Script Python
```bash
python test_drone_data.py --url http://localhost:8000 --interval 1
```

## 📊 Capacités de Monitoring

### Paramètres Surveillés
- **Position** : Altitude (mètres)
- **Mouvement** : Vitesse (m/s), Pitch/Roll/Yaw (degrés)
- **Santé** : Température (°C), Batterie (Volts)
- **Anomalies** : Détection et alertes en temps réel

### Limites de Normalité (Alertes)
- Température : -50°C à 150°C
- Altitude : -100m à 10000m
- Vitesse : 0 à 300 m/s
- Batterie : 0 à 30V
- Angles : ±180° pour Pitch/Roll, ±360° pour Yaw

## ⚙️ Configuration Avancée

### Changer la Fréquence de Mise à Jour

Éditez `lib/telemetry_service.dart` ligne 29 :
```dart
// Changez de 1 seconde à 2 secondes
_timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
```

### Augmenter l'Historique

Éditez `lib/telemetry_service.dart` ligne 63 :
```dart
// Stockez 200 points au lieu de 100
if (history.length > 200) {
  history.removeAt(0);
}
```

### Ajouter Authentification

Modifiez la fonction `fetchTelemetry()` dans `telemetry_service.dart` :
```dart
final response = await http.get(
  Uri.parse("$serverUrl/latest-data"),
  headers: {
    'Authorization': 'Bearer YOUR_TOKEN_HERE',
  },
);
```

## 🐛 Dépannage

### "Non connecté au serveur"

**Vérifications :**
1. ✓ Le serveur FastAPI s'exécute-t-il ?
   ```bash
   python your_server.py
   ```

2. ✓ L'URL est-elle correcte ? (http:// pas https://)

3. ✓ Le port 8000 est-il accessible ?
   ```bash
   curl http://localhost:8000/health
   ```

4. ✓ Firewall ou proxy bloque-t-il la connexion ?

### L'application freezes ou lag

- Réduisez la fréquence de mise à jour (voir config avancée)
- Limitez l'historique à 50 points
- Closez les autres applications

### Les graphiques ne s'affichent pas

- Attendez au moins 3-4 secondes
- Vérifiez que le serveur envoie des données
- Consultez la console Flutter pour les erreurs

```bash
# Afficher les logs Flutter
flutter logs
```

## 📈 Métriques Internes

- **Taille mémoire** : ~50 MB (+100 points d'historique)
- **Bande passante** : ~1KB par requête x 60/min = ~1 MB/h
- **Latence** : < 100ms local, < 500ms réseau

## 🎯 Cas d'Usage

1. **Monitoring en direct** : Surveillance du début à la fin du vol
2. **Entraînement** : Utilisation pédagogique pour apprentissage du pilotage
3. **Débogage** : Identification des anomalies et comportements inhabituels
4. **Analyse post-vol** : Examen détaillé de toutes les données de la mission
5. **Démonstration** : Présentation des capacités du système

## 🤝 Contribuer

Pour améliorer cette application :

1. Testez les différents cas d'utilisation
2. Signalez les bugs avec détails
3. Proposez des nouvelles fonctionnalités
4. Optimisez la performance

## 📄 Licence

Projet du Groupe 6 - FDMS Drone Monitoring System

## 🔗 Liens Utiles

- [Documentation Flutter](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [FL Chart Examples](https://github.com/imaNNeo/fl_chart)
- [Provider Pattern](https://pub.dev/packages/provider)

---

**Application développée pour le Groupe 6**  
**FDMS - Flight Data Monitoring System**  
2024
