# Modifications - Import Excel Indépendant & Navigation Graphiques

## ✅ Fonctionnalités Ajoutées

### 1. **Import de fichiers Excel/CSV indépendant du serveur**
- L'application fonctionne maintenant **sans dépendre** de la connexion au serveur
- Support des fichiers `*.xlsx` et `*.csv`
- Les données importées sont chargées immédiatement dans les graphiques

#### Modifications dans `telemetry_service.dart`:
- Amélioration des fonctions `importExcelFile()` et `importCSVFile()`
- L'état `isConnected` passe à `true` après l'import
- Messages d'erreur clairs lors de l'import

#### Dépendances ajoutées dans `pubspec.yaml`:
- **`file_picker: ^8.1.6`** - Pour sélectionner les fichiers (Excel/CSV)

---

### 2. **Navigation améliorée entre les graphiques**

#### Interface enrichie dans `charts_page.dart`:
- **Boutons flèches** (←/→) pour naviguer entre les graphiques
- **Bouton d'import** (📤) accessible directement dans la barre graphique
- Les flèches permettent de naviguer cycliquement entre les 7 graphiques :
  1. Altitude
  2. Vitesse
  3. Température
  4. Batterie
  5. Angles (Pitch/Roll/Yaw)
  6. Accélération (X/Y/Z)
  7. Pression

#### Comportements ajoutés:
- Navigation avec les flèches gauche/droite
- Bouton d'import (📤) pour charger un fichier Excel/CSV
- Affichage d'un message d'aide quand aucune donnée n'est disponible
- Les flèches peuvent être cliquées ou utilisées via tooltip

---

## 📋 Mode d'utilisation

### **Sans serveur (Mode fichier local)**
1. Ouvrir l'application
2. Page "Graphiques" affiche : *"En attente de données..."*
3. Cliquer sur le bouton **"Importer Excel/CSV"** ou l'icône 📤
4. Sélectionner un fichier `.xlsx` ou `.csv`
5. ✅ Les graphiques s'affichent immédiatement avec les données importées
6. Naviguer entre les graphiques avec les flèches ou en cliquant les onglets

### **Format de fichier attendu (Excel/CSV)**
Colonnes requises (dans cet ordre):
```
[0]  timestamp        DateTime
[1]  altitude         double (m)
[2]  speed           double (m/s)
[3]  temperature     double (°C)
[4]  battery         double (V)
[5]  pitch           double (°)
[6]  roll            double (°)
[7]  yaw             double (°)
[8]  accelX          double (m/s²)
[9]  accelY          double (m/s²)
[10] accelZ          double (m/s²)
[11] pressure        double (hPa)
```

---

## 🔧 Fichiers modifiés

| Fichier | Changements |
|---------|-----------|
| **pubspec.yaml** | Ajout `file_picker: ^8.1.6` |
| **lib/charts_page.dart** | Navigation flèches, bouton import, import de fichiers |
| **lib/telemetry_service.dart** | Amélioration gestion d'état après import |

---

## 🎯 Avantages

✅ **Indépendance du serveur** - L'app fonctionne sans connexion réseau  
✅ **Navigation fluide** - Parcourir les 7 graphiques facilement  
✅ **Import rapide** - Charger les données en quelques clics  
✅ **Feedback visuel** - Messages de confirmation/erreur clairs  
✅ **Expérience améliorée** - UI plus intuitive et ergonomique  

---

## 📌 Architecture

```
ChartsPage (UI)
  ├─ Boutons flèches navigation (←/→)
  ├─ Bouton import (📤)
  ├─ Sélecteur graphiques (7 onglets)
  └─ Affichage graphiques
      └─ Import via TelemetryService.importExcelFile() / importCSVFile()
```

---

## 🚀 Prochaines améliorations possibles

- [ ] Ajouter un indicateur "Données importées" vs "Données serveur"
- [ ] Exporter les graphiques en PNG/PDF
- [ ] Historique des fichiers importés
- [ ] Glisser-déposer pour importer les fichiers
- [ ] Supprimer/réinitialiser les données importées
