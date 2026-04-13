# 🚀 QUICK START - Démarrage Rapide (5 minutes)

## ⏱️ Si vous êtes pressé, commencez ici

### Prérequis
- ✅ Flutter installé
- ✅ Serveur FastAPI prêt (sur port 8000)
- ✅ Données drone ou simulator prêt

---

## 🚀 Démarrage en 3 Étapes

### Étape 1 : Installez les dépendances (1 min)
```bash
cd c:\drone_monoitoring
flutter pub get
```

### Étape 2 : Lancez l'app (30s)
```bash
flutter run
```

### Étape 3 : Configurez le serveur (1 min)
- Si serveur sur `localhost:8000` → L'app se connecte **automatiquement** ✅
- Si serveur ailleurs → Cliquez sur ⚙️ en bas à droite → Entrez l'URL

**C'est tout!** 🎉

---

## 🧪 Mode Test (avec données simulées)

Si vous n'avez pas de drone :

### Option A : PowerShell (Recommandé - Windows)
```powershell
# Terminal 1: Lancez le serveur
python your_server.py

# Terminal 2: Lancez l'app
flutter run

# Terminal 3: Générez des données
.\test_with_mock_data.ps1
```

### Option B : Python
```bash
# Terminal 1: Serveur
python your_server.py

# Terminal 2: App
flutter run

# Terminal 3: Données
python test_drone_data.py
```

---

## ✅ Vérifications Rapides

### La connexion a réussi si :
- [ ] Dashboard affiche des nombres (pas "En attente")
- [ ] Horizon artificiel se bouge
- [ ] Statut affiche "Connecté" en vert

### Les graphiques s'affichent si :
- [ ] Vous attendez 2-3 secondes
- [ ] Le tableau a au moins 5 lignes

### Les alertes s'affichent si :
- [ ] Les données dépassent les limites
- [ ] Une boîte rouge apparaît sur le dashboard

---

## 🆘 Problème Rapide?

| Symptôme | Solution |
|----------|----------|
| "Non connecté au serveur" | Serveur n'est pas lancé, lancez-le |
| Rien ne s'affiche | Attendez 2-3 secondes, données arrivent lentement |
| L'app crash | Relancez avec `flutter run` |
| Impossible de trouver le serveur | Modifiez l'URL en cliquant ⚙️ |

---

## 📱 Comment Modifier l'URL du Serveur

1. Attendez que l'app charge
2. Cliquez sur le bouton ⚙️ (en bas à droite du Dashboard)
3. Modifiez l'URL
4. Cliquez "Appliquer"

**Exemple d'URLs :**
- `http://localhost:8000` - Sur cette machine
- `http://192.168.1.100:8000` - Autre machine sur réseau local
- `http://10.0.0.5:8000` - Autre IP locale

---

## 🎯 Ce que vous Verrez

### Écran 1 : Dashboard
```
┌─────────────────────────────────────┐
│ Statut: Connecté  Bat: 12V  T: 42°C │
├─────────────────────────────────────┤
│                                       │
│        [Horizon Artificiel]           │
│                                       │
├─────────────────────────────────────┤
│ Altitude  Vitesse    Température    │
│  150m     8.5m/s        42°C        │
│                                       │
│ Batterie   Pitch       Roll          │
│  12.0V      5.2°        3.1°        │
│                                       │
│ Yaw        Alertes                   │
│ 125°       Aucune      [⚙️]          │
└─────────────────────────────────────┘
```

### Écran 2 : Graphiques (cliquez sur les boutons)
- 📈 Altitude dans le temps
- ⚡ Vitesse dans le temps
- 🌡️ Température dans le temps
- 🔋 Batterie dans le temps
- 📐 Angles (Pitch, Roll, Yaw)

### Écran 3 : Tableau
```
Temps    | Alt   | Vitesse | Temp | Batterie | Pitch | Roll | Yaw
---------|-------|---------|------|----------|-------|------|-----
14:30:45 | 150.8 |   8.3   | 42.5 |   12.0V  | 5.2°  | 3.1° | 45°
14:30:46 | 151.2 |   8.1   | 42.7 |   12.0V  | 5.3°  | 3.0° | 46°
...
```

---

## 📞 Documentation Complète

Si vous avez des questions :
- 📖 `README_APP.md` - Documentation générale
- ⚙️ `CONFIGURATION.md` - Configuration avancée
- 🔗 `INTEGRATION_GUIDE.md` - Intégration serveur
- ✅ `FINAL_CHECKLIST.md` - Checklist complète

---

## 🎉 C'est Parti!

**Tapez simplement :**
```bash
cd c:\drone_monoitoring
flutter run
```

Et admirez le résultat! 🚁

---

**Bon monitoring! 📊**
