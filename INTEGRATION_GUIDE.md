# 🚁 GUIDE COMPLET D'INTÉGRATION - Serveur FastAPI + App Flutter

## 📋 Vue d'ensemble

Ce guide montre comment connecter votre **serveur FastAPI** à votre **application Flutter** et les tester ensemble.

---

## 🛠️ Étape 1 : Préparer le Serveur FastAPI

### Vérifier que le serveur répond

1. **Lancez votre serveur FastAPI**
```bash
cd your_server_directory
python your_server.py
# Ou si vous utilisez Uvicorn
uvicorn your_server:app --host 0.0.0.0 --port 8000
```

2. **Testez la connexion**
```bash
# Windows PowerShell
Invoke-WebRequest -Uri "http://localhost:8000/health" | Select-Object StatusCode

# Ou dans un navigateur
http://localhost:8000/dashboard
```

Vous devriez voir une page HTML avec le dashboard du serveur.

### Vérifier les endpoints importants

```bash
# Récupérer la dernière donnée
curl http://localhost:8000/latest-data

# Vérifier l'état du serveur
curl http://localhost:8000/health

# Obtenir toutes les données
curl http://localhost:8000/all-data
```

---

## 📱 Étape 2 : Configurer l'Application Flutter

### Options de Configuration

#### Option A : URL Locale (Recommandée pour développement)
Si vous testez sur le **même ordinateur** serveur + Client:

1. Lancez Flutter
```bash
cd c:\drone_monoitoring
flutter run
```

2. L'app utilisera automatiquement : `http://localhost:8000`

#### Option B : URL Distante (Serveur sur autre machine)

1. **Trouvez l'adresse IP du serveur** :
```powershell
ipconfig
# Cherchez : IPv4 Address (ex: 192.168.1.100)
```

2. **Dans l'application Flutter**:
   - Cliquez sur le bouton ⚙️ (Dashboard)
   - Entrez : `http://192.168.1.100:8000`
   - Cliquez "Appliquer"

#### Option C : Modification du Code

Éditez `lib/telemetry_service.dart` ligne 14 :
```dart
String serverUrl = "http://YOUR_IP_HERE:8000";
```

---

## 🧪 Étape 3 : Test avec Données Réelles

### Approche 1 : Utiliser le Drone Physique

1. **Lancez le serveur FastAPI** (il reçoit les données du drone)
2. **Lancez l'application Flutter**
3. **Décollez avec le drone** - les données arrivent en direct

### Approche 2 : Utiliser des Données Simulées

#### Via PowerShell (Simple)
```powershell
# Lancez ce script - il génère automatiquement des données de vol
.\test_with_mock_data.ps1
```

Cela va:
- Générer un vol simulé de 60 secondes
- Envoyer les données au serveur
- L'app Flutter affichera les données en direct

#### Via Python (Personnalisabel)
```bash
# Générer des données continues
python test_drone_data.py --url http://localhost:8000 --interval 1

# Ou depuis un autre IP
python test_drone_data.py --url http://192.168.1.100:8000 --interval 2
```

---

## ✅ Checklist de Vérification

Avant de démarrer, vérifiez :

### ✓ Serveur FastAPI
- [ ] Le serveur Python s'exécute sans erreur
- [ ] Vous pouvez accéder à `http://localhost:8000` dans un navigateur
- [ ] L'endpoint `/health` répond

### ✓ Configuration Réseau
- [ ] Firewall n'est pas bloqué sur le port 8000
- [ ] Si distant : Vous connaissez l'adresse IP du serveur
- [ ] Connexion réseau entre les appareils

### ✓ Application Flutter
- [ ] Flutter est installé
- [ ] `flutter pub get` a réussi
- [ ] Pas d'erreurs lors de `flutter analyze`

### ✓ Données
- [ ] Le serveur a au moins 1 point de données
- [ ] Ou vous êtes prêt à utiliser les données de test

---

## 🔍 Guide de Dépannage Détaillé

### Problème : "Non connecté au serveur"

**Vérifications à faire :**

1. **Le serveur Python s'exécute?**
```bash
# Ouvrez un terminal et lancez
python your_server.py
# Vous devriez voir :
# INFO:     Uvicorn running on http://0.0.0.0:8000
```

2. **L'URL est-elle correcte?**
   - ✗ `https://localhost:8000` (mauvais protocole)
   - ✗ `http://localhost:8001` (mauvais port)
   - ✓ `http://localhost:8000` (correct)

3. **Le port 8000 est libre?**
```powershell
netstat -ano | findstr :8000
# Si quelque chose s'affiche, le port est utilisé
# Changez le port dans votre serveur ou tuez le processus
```

4. **CORS n'est pas bloqué?**
   - Votre serveur FastAPI a déjà CORS activé ✓

### Problème : "Timeout connexion"

Cela signifie que le serveur prend trop de temps pour répondre.

**Vérifications :**

1. **Le serveur pond?**
```bash
# Testez directement
curl -I http://localhost:8000/health
# Réponse : HTTP/1.1 200 OK
```

2. **La machine a une bonne connexion?**
   - Test de bande passante
   - Pas d'autres gros téléchargements

3. **Les données arrivent-elles?**
```bash
# Envoyez une données de test
curl -X POST http://localhost:8000/drone-data ^
  -H "Content-Type: application/json" ^
  -d "{\"temperature\":25,\"altitude\":100,\"vitesse\":5,\"batterie\":12,\"roll\":0,\"pitch\":0,\"yaw\":0}"
```

### Problème : Application freeze

1. **Réduisez la fréquence :**
   - De 1 seconde à 2 secondes en `telemetry_service.dart`

2. **Limitez l'historique :**
   - De 100 à 50 points

3. **Fermez les autres applications**
   - Flutter peut être gourmand lors du développement

---

## 📊 Flux Complet de Données

### Scénario : Vol avec le Drone Physique

```
Drone Physique
     ↓ (données GPS/senseurs)
Serveur FastAPI (récupère et stocke)
     ↓ /latest-data (chaque 1s)
Application Flutter (reçoit et affiche)
     ↓ 
Écran : Dashboard + Graphiques + Tableau
```

### Scénario : Test avec Données Simulées

```
Script PowerShell / Python (génère des données)
     ↓ (POST /drone-data)
Serveur FastAPI (stocke en SQLite + excel + Firebase)
     ↓ (GET /latest-data)
Application Flutter (reçoit)
     ↓
UI affiche les données de test
```

---

## 📈 Vérifier que Tout Fonctionne

Une fois connecté, vérifiez :

1. **Dashboard affiche les données**
   - ✓ Altitude, Vitesse, Température, Batterie
   - ✓ Angles (Pitch, Roll, Yaw)
   - ✓ État de connexion (vert)

2. **Graphiques se mettent à jour**
   - ✓ Cliquez sur chaque onglet (Altitude, Vitesse, etc.)
   - ✓ Les courbes se dessinent

3. **Tableau affiche l'historique**
   - ✓ Plusieurs lignes de données
   - ✓ Horodatage correct

4. **Alertes s'affichent** (si applicable)
   - ✓ Batterie basse (< 10V)
   - ✓ Température anormale
   - ✓ Altitude extrême

## 🎯 Cas de Test Recommandés

### Test 1 : Connexion Locale (5 min)
```bash
# Terminal 1
python your_server.py

# Terminal 2
flutter run

# Result: App affiche "Connecté" après 1-2 secondes
```

### Test 2 : Données de Test PowerShell (10 min)
```bash
# Terminal 1
python your_server.py

# Terminal 2
.\test_with_mock_data.ps1
# Cela envoie 60 données de vol

# Terminal 3
flutter run

# Result: Graphiques se remplissent, tableau s'agrandit
```

### Test 3 : Reconnexion (5 min)
```bash
# Lancez l'app (connectée)
# Arrêtez le serveur (Ctrl+C)
# Result: Le dashboard affiche "Déconnecté"

# Relancez le serveur
# Result: L'app se reconnecte automatiquement en 2-5 secondes
```

### Test 4 : Changer l'URL (5 min)
```bash
# Tandis que l'app affiche "Déconnecté"
# Cliquez sur ⚙️
# Entrez une mauvaise URL (ex: http://999.999.999.999:8000)
# Cliquez "Appliquer"
# Result: Ça ne se connecte pas
# Retapez la bonne URL
# Result: Reconnexion réussie
```

---

## 🚀 Production Readiness

L'application est **100% opérationnelle** pour:

✅ Recevoir des données du drone
✅ Les afficher en temps réel
✅ Générer des graphiques
✅ Garder un historique
✅ Gérer les erreurs de connexion

**Optimisations futures possibles :**
- [ ] Cache des données Firebase pour mode hors-ligne
- [ ] Enregistrement des statistiques
- [ ] Export CSV/PDF
- [ ] Alarmes sonores pour alertes critiques
- [ ] Widget de notification pour appareils mobiles

---

## 📞 Besoin d'Aide?

Consultez :
- `README_APP.md` - Documentation générale de l'app
- `CONFIGURATION.md` - Configuration détaillée
- `CHANGES.md` - Résumé des modifications

---

**Bonne chance avec votre monitoring de drone! 🚁**
