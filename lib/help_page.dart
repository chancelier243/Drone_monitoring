import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Center(
              child: Column(
                children: [
                  Icon(Icons.help_outline, size: 64, color: Colors.blue),
                  const SizedBox(height: 12),
                  Text(
                    "Mode d'Emploi",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Guide complet de l'application Drone Monitoring",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Table des matières
            _buildTableOfContents(context),
            const SizedBox(height: 32),

            // 1. Démarrage
            _buildSection(
              context,
              "1. Démarrage Rapide",
              [
                _buildSubsection(
                  "Connexion au serveur",
                  [
                    "Assurez-vous que le serveur de télémétrie est actif",
                    "Dans l'onglet 'Mission Control', entrez l'URL du serveur",
                    "Format: http://IP_SERVEUR:PORT (ex: http://192.168.1.100:5000)",
                    "L'application tentera une connexion automatique",
                    "Vous verrez un horizon artificiel une fois connecté",
                  ],
                ),
                _buildSubsection(
                  "Interface principale",
                  [
                    "🎮 Mission Control: Affichage en temps réel et horizon artificiel",
                    "📊 Charts: Graphiques des données historiques",
                    "📋 Tableau: Vue détaillée de toutes les données",
                    "⚙️ Paramètres: Configuration de l'application",
                    "🔧 Calibration: Calibration du drone et de la télécommande",
                    "❓ Aide: Ce mode d'emploi",
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 1b. Module de télémétrie
            _buildSection(
              context,
              "1b. Module de Télémétrie et Mode de Connexion",
              [
                _buildSubsection(
                  "Qu'est-ce que le module de télémétrie?",
                  [
                    "Le module de télémétrie est le cœur de l'application",
                    "Il reçoit les données du drone en temps réel via le serveur",
                    "Fréquence de mise à jour: 1 Hz (1 mesure par seconde)",
                    "Les données sont stockées dans un historique (50 dernières mesures)",
                    "L'interface se met à jour automatiquement à chaque nouvelle donnée",
                  ],
                ),
                _buildSubsection(
                  "Accès au mode de connexion",
                  [
                    "1. Ouvrez l'application et allez à l'onglet 'Mission Control'",
                    "2. Si aucune donnée n'est reçue, vous verrez l'écran de connexion",
                    "3. Cet écran affiche: ☁️ Non connecté au serveur",
                    "4. Un formulaire de configuration du serveur s'affiche",
                    "5. C'est ici que vous entrez l'URL pour se connecter au module de télémétrie",
                  ],
                ),
                _buildSubsection(
                  "Configuration de l'URL du serveur",
                  [
                    "Format générique: http://IP_SERVEUR:PORT",
                    "Exemple local: http://localhost:5000 ou http://127.0.0.1:5000",
                    "Exemple réseau: http://192.168.1.100:5000",
                    "Exemple IPv4: http://10.0.0.5:8000",
                    "Support localtunnel: http://monapp.loca.lt (utile pour l'accès à distance)",
                    "Port par défaut du serveur: 5000",
                    "⚠️ Assurez-vous que http:// est présent (pas https si non supporté)",
                  ],
                ),
                _buildSubsection(
                  "Étapes pour se connecter",
                  [
                    "1. Vérifiez que le serveur Python (server.py) est actif",
                    "2. Notez l'IP du serveur (http://IP:PORT)",
                    "3. Dans l'écran de connexion, effacez l'URL actuelle",
                    "4. Entrez la nouvelle URL (ex: http://192.168.1.100:5000)",
                    "5. Cliquez sur le bouton 'Se connecter' (bleu)",
                    "6. L'application va tenter la connexion automatiquement",
                    "7. Attendez quelques secondes pour la première réponse",
                    "8. Si réussi, un horizon artificiel s'affichera",
                  ],
                ),
                _buildSubsection(
                  "Qu'est-ce que le module reçoit du serveur?",
                  [
                    "📍 Position: Latitude, Longitude, Altitude",
                    "🎯 Attitude: Pitch (tangage), Roll (roulis), Yaw (cap/lacet)",
                    "⚡ Vitesse: Vitesse actuelle du drone (m/s)",
                    "🔋 Batterie: Tension actuelle (V)",
                    "🌡️ Température: Capteur interne (°C)",
                    "📊 Capteurs: Gyroscope, Accéléromètre, Magnétomètre (3 axes)",
                    "📈 Pression: Pression atmosphérique (Pa ou hPa)",
                    "⚠️ Alertes: Avertissements en cas de seuil dépassé",
                  ],
                ),
                _buildSubsection(
                  "Endpoint du serveur",
                  [
                    "Endpoint principal: /latest-data",
                    "Fréquence: L'application interroge toutes les 1 seconde",
                    "Format de réponse: JSON",
                    "Le serveur doit toujours répondre avec la dernière donnée",
                    "Exemple: {\"pitch\": 5.2, \"roll\": -3.1, \"yaw\": 45.0, ...}",
                  ],
                ),
                _buildSubsection(
                  "Gestion des erreurs de connexion",
                  [
                    "❌ 'Non connecté': Vérifiez l'URL et que le serveur est actif",
                    "❌ 'Timeout': Le serveur met trop de temps à répondre (8s max)",
                    "❌ 'Réponse invalide': Le serveur retourne du HTML au lieu de JSON",
                    "❌ 'Acces refuse (403)': L'URL est peut-être mal formatée",
                    "💡 Pour localtunnel: Visitez l'URL dans un navigateur d'abord",
                    "🔄 L'application réessaie automatiquement toutes les secondes",
                    "📊 Compteur 'Tentatives echouees' montre le nombre de reconnexions",
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 2. Mission Control
            _buildSection(
              context,
              "2. Onglet Mission Control",
              [
                _buildSubsection(
                  "Horizon Artificiel",
                  [
                    "Affiche l'attitude du drone (pitch, roll, yaw)",
                    "La ligne d'horizon montre l'inclinaison du drone",
                    "Le marqueur de cap (yaw) est en haut",
                    "Les échelles latérales indiquent l'angle de roulis",
                  ],
                ),
                _buildSubsection(
                  "Informations en temps réel",
                  [
                    "Affichage des valeurs critiques du drone",
                    "Altitude, vitesse, batterie et température",
                    "Alerte si des seuils sont dépassés",
                    "Mise à jour toutes les 1 seconde",
                  ],
                ),
                _buildSubsection(
                  "Manuelle Donnée",
                  [
                    "Permet d'entrer manuellement des données de télémétrie",
                    "Utile pour les tests ou l'enregistrement manuel",
                    "Accessible via le menu ⋮ en haut à droite",
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Graphiques
            _buildSection(
              context,
              "3. Onglet Charts (Graphiques)",
              [
                _buildSubsection(
                  "Visualisation des données",
                  [
                    "Affiche l'historique des 50 dernières mesures",
                    "Graphiques: Altitude, Vitesse, Batterie, Température",
                    "Accélération, Gyroscope, Pression",
                    "Les données se mettent à jour en temps réel",
                  ],
                ),
                _buildSubsection(
                  "Interaction",
                  [
                    "Survolez un point pour voir la valeur exacte",
                    "Les valeurs survolées s'affichent en haut",
                    "Zoom possible selon le graphique",
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 4. Tableau
            _buildSection(
              context,
              "4. Onglet Tableau",
              [
                _buildSubsection(
                  "Vue détaillée",
                  [
                    "Affiche tous les paramètres du drone dans un tableau",
                    "Format: Paramètre | Valeur | Unité",
                    "Parfait pour analyser les données détaillées",
                    "Les données se rafraîchissent en temps réel",
                  ],
                ),
                _buildSubsection(
                  "Export de données",
                  [
                    "Bouton 'Exporter en Excel' en bas de page",
                    "Exporte l'historique complet en fichier .xlsx",
                    "Utile pour l'analyse post-vol",
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 5. Calibration
            _buildSection(
              context,
              "5. Onglet Calibration",
              [
                _buildSubsection(
                  "Pourquoi calibrer?",
                  [
                    "Les capteurs se dérivent avec le temps et la température",
                    "Une mauvaise calibration affecte la stabilité du drone",
                    "Calibrez avant chaque campagne importante",
                  ],
                ),
                _buildSubsection(
                  "Avant de commencer",
                  [
                    "⚠️ SÉCURITÉ : Retirez TOUJOURS les hélices du drone",
                    "✓ Utilisez une surface plane et stable",
                    "✓ Éloignez-vous des sources magnétiques (métaux, électronique)",
                    "✓ Assurez-vous que le drone est bien alimenté",
                    "✓ Calibrez dans un environnement sans vibrations externes",
                  ],
                ),
                _buildSubsection(
                  "Calibration du Gyroscope",
                  [
                    "1. Immobilisez complètement le drone",
                    "2. Placez-le sur une surface plane et stable",
                    "3. Cliquez sur 'Calibrer' et attendez (~5 secondes)",
                    "4. Ne bougez pas pendant la calibration",
                    "✓ Le capteur sera considéré comme calibré",
                  ],
                ),
                _buildSubsection(
                  "Calibration de l'Accéléromètre",
                  [
                    "1. Positionnez le drone dans 6 orientations différentes",
                    "2. Haut, Bas, Avant, Arrière, Gauche, Droite",
                    "3. Maintenez chaque position ~2 secondes",
                    "4. Suivez les instructions affichées",
                    "Durée: ~10 secondes",
                  ],
                ),
                _buildSubsection(
                  "Calibration du Magnétomètre",
                  [
                    "1. Éloignez-vous de toute source magnétique",
                    "2. Tournez le drone lentement dans toutes les directions",
                    "3. Créez un mouvement en forme de 8 ou de sphère",
                    "4. Continuez pendant ~15 secondes",
                    "Important: Loin des métaux, électronique, câbles",
                  ],
                ),
                _buildSubsection(
                  "Calibration RC (Télécommande)",
                  [
                    "1. Mettez la télécommande sous tension",
                    "2. Pour chaque canal (Throttle, Roll, Pitch, Yaw):",
                    "   - Bougez le stick à sa position minimale",
                    "   - Entrez la valeur minimum",
                    "   - Bougez à la position maximale",
                    "   - Entrez la valeur maximum",
                    "3. Validez chaque canal",
                  ],
                ),
                _buildSubsection(
                  "Déclinaison Magnétique",
                  [
                    "C'est la différence entre le nord magnétique et le nord géographique",
                    "Varie selon votre localisation",
                    "Valeur positive: Nord magnétique à l'est du nord géographique",
                    "Valeur négative: Nord magnétique à l'ouest",
                    "Exemple: France ≈ -5° à -7°",
                  ],
                ),
                _buildSubsection(
                  "Gestion des calibrations",
                  [
                    "Exporter: Sauvegarde votre config de calibration en JSON",
                    "Importer: Charge une config sauvegardée précédemment",
                    "Réinitialiser: Efface toutes les calibrations",
                    "Status: ✓ = Calibré | ✗ = Non calibré",
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 6. Paramètres
            _buildSection(
              context,
              "6. Onglet Paramètres",
              [
                _buildSubsection(
                  "Thème",
                  [
                    "Choisissez entre mode clair et mode sombre",
                    "Le mode sombre est utile en conditions externes",
                  ],
                ),
                _buildSubsection(
                  "Couleur d'accent",
                  [
                    "Personnalisez la couleur principale de l'interface",
                    "10 couleurs disponibles",
                  ],
                ),
                _buildSubsection(
                  "Actions disponibles",
                  [
                    "Menu ⋮: Options supplémentaires",
                    "Basculer thème: Change clair/sombre rapidement",
                    "Effacer historique: Vide toutes les données",
                    "Entrée manuelle: Ajouter des données manuellement",
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 7. Import/Export
            _buildSection(
              context,
              "7. Import et Export de Données",
              [
                _buildSubsection(
                  "Export en Excel",
                  [
                    "Disponible dans l'onglet Tableau",
                    "Exporte l'historique complet en .xlsx",
                    "Format lisible dans Microsoft Excel",
                    "Inclut: timestamp, tous les paramètres, unités",
                  ],
                ),
                _buildSubsection(
                  "Export de Calibration",
                  [
                    "Disponible dans Calibration",
                    "Format: JSON",
                    "Permet de sauvegarder votre configuration",
                    "Utile pour appliquer les mêmes réglages à plusieurs drones",
                  ],
                ),
                _buildSubsection(
                  "Import de Calibration",
                  [
                    "Récupérez un JSON de calibration précédente",
                    "Collez-le dans le dialogue d'import",
                    "L'application chargera tous les paramètres",
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 8. Dépannage
            _buildSection(
              context,
              "8. Dépannage",
              [
                _buildSubsection(
                  "Pas de connexion au serveur",
                  [
                    "✓ Vérifiez que le serveur Python (server.py) est actif",
                    "✓ Lancez: python server.py ou python3 server.py",
                    "✓ Vérifiez l'URL (http://IP:PORT), ex: http://192.168.1.100:5000",
                    "✓ Vérifiez le pare-feu et la connexion réseau",
                    "✓ Ping l'IP pour vérifier la connectivité: ping 192.168.1.100",
                    "✓ Vérifiez le port (5000 par défaut) en accédant à http://IP:5000 dans un navigateur",
                    "✓ Pour localtunnel: visitez l'URL dans un navigateur d'abord",
                    "✓ Attendez au moins 8 secondes avant de relancer la tentative",
                  ],
                ),
                _buildSubsection(
                  "Module télémétrie et réception de données",
                  [
                    "Si connexion OK mais pas de données:",
                    "  1. Vérifiez que le serveur expose l'endpoint /latest-data",
                    "  2. Testez dans un navigateur: http://IP:PORT/latest-data",
                    "  3. Vous devez voir une réponse JSON avec les données du drone",
                    "  4. Si HTML au lieu de JSON: erreur de serveur",
                    "Si les données arrivent mais ne changent pas:",
                    "  1. Le drone n'envoie peut-être pas de nouvelles données",
                    "  2. Vérifiez que le drone est actif et relie au serveur",
                    "  3. Vérifiez la fréquence de mise à jour (1 Hz attendu)",
                  ],
                ),
                _buildSubsection(
                  "L'horizon artificiel ne s'affiche pas",
                  [
                    "  • Vérifiez d'abord la connexion au module de télémétrie",
                    "  • Attendez que le statut 'Connecté' (vert) s'affiche",
                    "  • Les données Pitch, Roll, Yaw doivent être reçues",
                    "  • Si vides: le serveur n'envoie pas ces champs",
                    "  • Vérifiez le format JSON du serveur",
                  ],
                ),
                _buildSubsection(
                  "Données instables ou saccadées",
                  [
                    "  • Calibrez les capteurs (Gyro, Accel, Mag) sur le drone",
                    "  • Éloignez-vous de sources magnétiques",
                    "  • Vérifiez la connexion réseau (Wi-Fi ou filaire)",
                    "  • Si réseau Wi-Fi instable, utilisez un câble réseau",
                    "  • Vérifiez la latence: ping -t IP_SERVEUR",
                    "  • Réduisez les interférences radio",
                  ],
                ),
                _buildSubsection(
                  "Problèmes d'affichage",
                  [
                    "Changez de thème: clair/sombre",
                    "Redémarrez l'application",
                    "Vérifiez la résolution de votre écran",
                  ],
                ),
                _buildSubsection(
                  "Export ne fonctionne pas",
                  [
                    "Vérifiez que vous avez du stockage libre",
                    "Vérifiez les permissions d'accès au stockage",
                    "Assurez-vous que les données ne sont pas vides",
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 9. Raccourcis & Astuces
            _buildSection(
              context,
              "9. Astuces et Bonnes Pratiques",
              [
                _buildSubsection(
                  "Performance optimale",
                  [
                    "Calibrez avant chaque campagne importante",
                    "Exportez les données après chaque vol",
                    "Maintenez le firmware du drone à jour",
                    "Utilisez une connexion réseau stable",
                  ],
                ),
                _buildSubsection(
                  "Sauvegardes",
                  [
                    "Exportez régulièrement votre calibration",
                    "Sauvegardez les fichiers Excel sur votre ordinateur",
                    "Gardez une copie de votre configuration de référence",
                  ],
                ),
                _buildSubsection(
                  "Maintenance",
                  [
                    "Vérifiez régulièrement l'état de la batterie",
                    "Surveillez la température du drone",
                    "Observez les alertes affichées",
                    "Nettoyez les capteurs si nécessaire",
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 10. Spécifications
            _buildSection(
              context,
              "10. Spécifications Techniques",
              [
                _buildSubsection(
                  "Compatibilité",
                  [
                    "Android 5.0+",
                    "iOS 12.0+",
                    "Web (navigateur moderne)",
                    "Windows/macOS/Linux (via Flutter)",
                  ],
                ),
                _buildSubsection(
                  "Données suportées",
                  [
                    "Attitude: Pitch, Roll, Yaw",
                    "Position: Altitude, Latitude, Longitude",
                    "Vitesse et accélération (3 axes)",
                    "Capteurs: Gyroscope, Accéléromètre, Magnétomètre",
                    "Batterie, Température, Pression",
                  ],
                ),
                _buildSubsection(
                  "Fréquence de mise à jour",
                  [
                    "Télémétrie: 1 Hz (1 mesure par seconde)",
                    "UI: Mise à jour en temps réel",
                    "Historique: 50 dernières mesures stockées",
                  ],
                ),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildTableOfContents(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Table des matières",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _tocItem("1. Démarrage Rapide"),
            _tocItem("1b. Module de Télémétrie et Connexion"),
            _tocItem("2. Onglet Mission Control"),
            _tocItem("3. Onglet Charts"),
            _tocItem("4. Onglet Tableau"),
            _tocItem("5. Onglet Calibration"),
            _tocItem("6. Onglet Paramètres"),
            _tocItem("7. Import et Export"),
            _tocItem("8. Dépannage"),
            _tocItem("9. Astuces"),
            _tocItem("10. Spécifications"),
          ],
        ),
      ),
    );
  }

  Widget _tocItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildSubsection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 12, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        ...items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(left: 32, bottom: 4),
            child: Text(
              "• $item",
              style: const TextStyle(fontSize: 13),
            ),
          );
        }).toList(),
        const SizedBox(height: 8),
      ],
    );
  }
}
