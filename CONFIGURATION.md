# Configuration - Application de Monitoring de Drone

## 🚀 Guide de Configuration

### Étape 1 : Configuration du serveur FastAPI

Assurez-vous que votre serveur FastAPI est en cours d'exécution. Par défaut, l'application Flutter s'attend à ce que le serveur soit accessible à :

```
http://localhost:8000
```

#### Si le serveur est sur une machine différente :
Notez l'adresse IP de la machine où le serveur FastAPI s'exécute :
- Ouvrez une invite de commande
- Tapez : `ipconfig`
- Cherchez "IPv4 Address" (ex: `192.168.1.100`)

### Étape 2 : Lancer l'application Flutter

```bash
# Assurez-vous que vous êtes dans le répertoire du projet
cd c:\drone_monoitoring

# Installez les dépendances
flutter pub get

# Lancez l'application
flutter run
```

### Étape 3 : Configurer la connexion au serveur

Lorsque l'application démarre :

1. **Si vous voyez un écran "Non connecté au serveur"** :
   - Cliquez sur l'écran ou le bouton ⚙️ (paramètres) en bas à droite
   - Entrez l'URL de votre serveur (ex: `http://192.168.1.100:8000`)
   - Cliquez sur "Se connecter"

2. **Une fois connecté** :
   - Le dashboard affichera les données en temps réel
   - Les graphiques se mettront à jour automatiquement
   - Le tableau affichera l'historique complet

## 📊 Interface de l'Application

### 🏠 Onglet "Dashboard"
Affiche l'horizon artificiel et les paramètres clés du drone :
- **Altitude** : hauteur actuelle du drone
- **Vitesse** : vitesse de vol instantanée
- **Température** : température du système
- **Batterie** : tension de la batterie
- **Pitch/Roll/Yaw** : angles d'orientation
- **Alertes** : anomalies détectées (si présentes)

Cliquez sur ⚙️ pour:
- Modifier l'adresse du serveur
- Reconnexion

### 📈 Onglet "Graphiques"
Visualisez l'évolution des paramètres sous forme de graphiques :
- **Altitude** : évolution de la hauteur
- **Vitesse** : courbe de vitesse
- **Température** : variations thermiques
- **Batterie** : état de la batterie
- **Angles** : Pitch, Roll et Yaw combinés

### 📋 Onglet "Tableau"
Accédez à l'historique complet des données en format tableau Excel :
- Toutes les mesures datées et horodatées
- Exportable pour analyse ultérieure

## 🔧 Dépendances Requises

Le projet utilise les dépendances suivantes (déjà installées) :

- **flutter** : Framework d'interface
- **provider** : Gestion d'état
- **http** : Reqruêtes HTTP au serveur
- **fl_chart** : Graphiques
- **cupertino_icons** : Icônes iOS

## ⚙️ Configuration Avancée

### Changer l'URL du serveur

**Option 1 : Via l'interface**
- Cliquez sur le bouton ⚙️
- Modifiez l'URL
- Cliquez "Appliquer"

**Option 2 : Directement dans le code**
Éditez `lib/telemetry_service.dart` ligne 14 :
```dart
String serverUrl = "http://localhost:8000"; // Modifiez ceci
```

### Réduire la fréquence des mises à jour

Si vous constatez une forte consommation réseau, modifiez `lib/telemetry_service.dart` ligne 29 :
```dart
_timer = Timer.periodic(const Duration(seconds: 1), (timer) async { // Changez 1 en 2, 3, etc.
```

### Augmenter l'historique des graphiques

Modifiez `lib/telemetry_service.dart` ligne 63 :
```dart
if (history.length > 100) { // Changez 100 en 200, 500, etc.
```

## 🐛 Dépannage

### "Non connecté au serveur"
1. Vérifiez que le serveur FastAPI est en cours d'exécution
2. Vérifiez l'URL (devrait être http:// pas https://)
3. Assurez-vous que le port 8000 n'est pas firewall-blocked
4. Essayez de visiter l'URL dans un navigateur

### L'application freezing/lag
- Réduisez la fréquence des mises à jour
- Réduite l'historique à afficher
- Fermez d'autres applications

### Pas de données affichées
- Attendez quelques secondes (délai initial de connexion)
- Vérifiez que le serveur envoie des données
- Consultez les logs du terminal Flutter

## 📱 Appareils Supportés

L'application fonctionne sur :
- ✅ Android (4.1+)
- ✅ iOS (11.0+)
- ✅ Windows (10+)
- ✅ Linux
- ✅ macOS
- ✅ Web

## 📞 Points d'Extrémité de l'API Utilisés

L'application interroge ces endpoints du serveur FastAPI :

| Endpoint | Fréquence | Utilisation |
|----------|-----------|------------|
| `/latest-data` | Chaque 1s | Données temps réel |
| `/health` | On-demand | Vérification de l'état du serveur |

## 🎯 Prochaines Étapes

Une fois connecté et éprouvé :
1. Laissez le drone voler
2. Consultez les graphiques en direct
3. Capturez l'historique complet
4. Exportez les données depuis le serveur (endpoint `/export-excel`)

Bon monitoring ! 🚁
