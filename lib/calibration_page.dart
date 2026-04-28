import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'calibration_service.dart';

class CalibrationPage extends StatefulWidget {
  const CalibrationPage({super.key});

  @override
  State<CalibrationPage> createState() => _CalibrationPageState();
}

class _CalibrationPageState extends State<CalibrationPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CalibrationService>(
      builder: (context, calibrationService, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                Text(
                  "Calibration du Drone et Télécommande",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  "Calibrez les capteurs et la télécommande pour une performance optimale",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Statut global
                _buildGlobalStatus(calibrationService),
                const SizedBox(height: 20),

                // Message d'erreur
                if (calibrationService.errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Text(
                      calibrationService.errorMessage,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                if (calibrationService.errorMessage.isNotEmpty)
                  const SizedBox(height: 16),

                // Statut de calibration actuelle
                if (calibrationService.isCalibrating)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[300]!),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          calibrationService.calibrationStatus,
                          style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                if (calibrationService.isCalibrating) const SizedBox(height: 16),

                if (calibrationService.calibrationStatus.isNotEmpty && !calibrationService.isCalibrating)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: calibrationService.calibrationStatus.contains('✓')
                          ? Colors.green[100]
                          : Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: calibrationService.calibrationStatus.contains('✓')
                            ? Colors.green[300]!
                            : Colors.orange[300]!,
                      ),
                    ),
                    child: Text(
                      calibrationService.calibrationStatus,
                      style: TextStyle(
                        color: calibrationService.calibrationStatus.contains('✓')
                            ? Colors.green[700]
                            : Colors.orange[700],
                      ),
                    ),
                  ),
                if (calibrationService.calibrationStatus.isNotEmpty && !calibrationService.isCalibrating)
                  const SizedBox(height: 16),

                // Calibrations des capteurs du drone
                _buildSection(
                  context,
                  "Capteurs du Drone",
                  [
                    _buildCalibrationCard(
                      context,
                      icon: Icons.settings_input_antenna,
                      title: "Gyroscope",
                      description: "Calibrer les capteurs de rotation",
                      isCalibrated: calibrationService.calibrationData.isGyroCalibrated,
                      onPressed: calibrationService.isCalibrating
                          ? null
                          : () => _showGyroCalibrationDialog(context, calibrationService),
                    ),
                    _buildCalibrationCard(
                      context,
                      icon: Icons.speed,
                      title: "Accéléromètre",
                      description: "Calibrer les capteurs d'accélération",
                      isCalibrated: calibrationService.calibrationData.isAccelCalibrated,
                      onPressed: calibrationService.isCalibrating
                          ? null
                          : () => _showAccelCalibrationDialog(context, calibrationService),
                    ),
                    _buildCalibrationCard(
                      context,
                      icon: Icons.compass_calibration,
                      title: "Magnétomètre",
                      description: "Calibrer la boussole/capteur magnétique",
                      isCalibrated: calibrationService.calibrationData.isMagCalibrated,
                      onPressed: calibrationService.isCalibrating
                          ? null
                          : () => _showMagCalibrationDialog(context, calibrationService),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Calibration de la télécommande
                _buildSection(
                  context,
                  "Télécommande",
                  [
                    _buildCalibrationCard(
                      context,
                      icon: Icons.videogame_asset,
                      title: "Canaux RC",
                      description: "Calibrer les sticks/canaux de contrôle",
                      isCalibrated: calibrationService.calibrationData.isRCCalibrated,
                      onPressed: calibrationService.isCalibrating
                          ? null
                          : () => _showRCCalibrationDialog(context, calibrationService),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Autres paramètres
                _buildSection(
                  context,
                  "Autres Paramètres",
                  [
                    _buildCompassDeclinationCard(context, calibrationService),
                  ],
                ),
                const SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: calibrationService.isCalibrating
                          ? null
                          : () => _showExportDialog(context, calibrationService),
                      icon: const Icon(Icons.save_alt),
                      label: const Text("Exporter"),
                    ),
                    ElevatedButton.icon(
                      onPressed: calibrationService.isCalibrating
                          ? null
                          : () => _showImportDialog(context, calibrationService),
                      icon: const Icon(Icons.upload_file),
                      label: const Text("Importer"),
                    ),
                    ElevatedButton.icon(
                      onPressed: calibrationService.isCalibrating
                          ? null
                          : () => _showResetDialog(context, calibrationService),
                      icon: const Icon(Icons.restore),
                      label: const Text("Réinitialiser"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[300],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlobalStatus(CalibrationService service) {
    final allCalibrated = service.areAllCalibrated();
    return Card(
      color: allCalibrated ? Colors.green[50] : Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              allCalibrated ? Icons.check_circle : Icons.info,
              color: allCalibrated ? Colors.green : Colors.orange,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    allCalibrated ? "✓ Toutes les calibrations complètes" : "⚠ Calibration incomplète",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Gyro: ${service.calibrationData.isGyroCalibrated ? '✓' : '✗'} | "
                    "Accel: ${service.calibrationData.isAccelCalibrated ? '✓' : '✗'} | "
                    "Mag: ${service.calibrationData.isMagCalibrated ? '✓' : '✗'} | "
                    "RC: ${service.calibrationData.isRCCalibrated ? '✓' : '✗'}",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildCalibrationCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool isCalibrated,
    required VoidCallback? onPressed,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isCalibrated ? "✓ Calibré" : "✗ Non calibré",
                    style: TextStyle(
                      fontSize: 12,
                      color: isCalibrated ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onPressed,
              child: const Text("Calibrer"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompassDeclinationCard(BuildContext context, CalibrationService service) {
    final TextEditingController _controller = TextEditingController(
      text: service.calibrationData.compassDeclinationAngle.toString(),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Déclinaison Magnétique",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: InputDecoration(
                hintText: "Angle en degrés (ex: -5.5)",
                suffixText: "°",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) {
                final angle = double.tryParse(value);
                if (angle != null) {
                  service.setCompassDeclinationAngle(angle);
                }
              },
            ),
            const SizedBox(height: 8),
            Text(
              "Valeur actuelle: ${service.calibrationData.compassDeclinationAngle}°",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  void _showGyroCalibrationDialog(BuildContext context, CalibrationService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Calibration du Gyroscope"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Instructions:"),
            SizedBox(height: 12),
            Text("1. Immobilisez complètement le drone"),
            Text("2. Placez-le sur une surface plane et stable"),
            Text("3. Cliquez sur 'Démarrer' et ne bougez pas"),
            Text("4. Attendez la fin de la calibration (~5 secondes)"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await service.startGyroCalibration();
            },
            child: const Text("Démarrer"),
          ),
        ],
      ),
    );
  }

  void _showAccelCalibrationDialog(BuildContext context, CalibrationService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Calibration de l'Accéléromètre"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Instructions:"),
            SizedBox(height: 12),
            Text("1. Vous allez positionner le drone dans 6 orientations"),
            Text("2. Pour chaque orientation, maintenez ~1-2 secondes"),
            Text("3. Haut, Bas, Avant, Arrière, Gauche, Droite"),
            Text("4. Suivez les instructions à l'écran"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await service.startAccelCalibration();
            },
            child: const Text("Démarrer"),
          ),
        ],
      ),
    );
  }

  void _showMagCalibrationDialog(BuildContext context, CalibrationService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Calibration du Magnétomètre"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Instructions:"),
            SizedBox(height: 12),
            Text("1. Loin des sources magnétiques (métaux, électronique)"),
            Text("2. Tournez lentement le drone dans toutes les directions"),
            Text("3. Créez un mouvement en 8 ou en sphère"),
            Text("4. Continuez pendant ~15 secondes"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await service.startMagnetometerCalibration();
            },
            child: const Text("Démarrer"),
          ),
        ],
      ),
    );
  }

  void _showRCCalibrationDialog(BuildContext context, CalibrationService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Calibration des Canaux RC"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Instructions:"),
            SizedBox(height: 12),
            Text("1. Mettez la télécommande sous tension"),
            Text("2. Bougez chaque stick à sa position minimale"),
            Text("3. Puis à sa position maximale"),
            Text("4. Canaux: Throttle, Roll, Pitch, Yaw"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showRCChannelCalibration(context, service);
            },
            child: const Text("Suivant"),
          ),
        ],
      ),
    );
  }

  void _showRCChannelCalibration(BuildContext context, CalibrationService service) {
    final channels = ['Throttle', 'Roll', 'Pitch', 'Yaw'];
    int currentIndex = 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Calibration: ${channels[currentIndex]}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Canal: ${channels[currentIndex]}"),
            const SizedBox(height: 16),
            const Text("1. Bougez le stick à sa position minimale"),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                labelText: "Valeur min",
                hintText: "ex: 1000",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            const Text("2. Bougez le stick à sa position maximale"),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                labelText: "Valeur max",
                hintText: "ex: 2000",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Suivant"),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, CalibrationService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exporter la Calibration"),
        content: const Text("Voulez-vous exporter la configuration de calibration actuelle?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final json = await service.exportCalibrationToJson();
              if (json.isNotEmpty && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Calibration exportée avec succès")),
                );
              }
            },
            child: const Text("Exporter"),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context, CalibrationService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Importer la Calibration"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Collez le contenu JSON de votre calibration:"),
            const SizedBox(height: 16),
            TextField(
              minLines: 5,
              maxLines: 10,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                hintText: "Contenu JSON...",
              ),
              onChanged: (value) {
                // Stockage temporaire
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Importer"),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, CalibrationService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Réinitialiser"),
        content: const Text("Êtes-vous sûr? Toutes les calibrations seront supprimées."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await service.resetAllCalibrations();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Calibrations réinitialisées")),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Réinitialiser"),
          ),
        ],
      ),
    );
  }
}
