import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'telemetry_service.dart';
import 'three_dr_service.dart';

class DataSourceConfigPage extends StatefulWidget {
  const DataSourceConfigPage({super.key});

  @override
  State<DataSourceConfigPage> createState() => _DataSourceConfigPageState();
}

class _DataSourceConfigPageState extends State<DataSourceConfigPage> {
  late TextEditingController _serverUrlController;
  late TextEditingController _portController;
  late TextEditingController _hostController;
  late TextEditingController _remotePortController;
  
  ThreeDRService.ConnectionMode _selectedMode = ThreeDRService.ConnectionMode.udp;

  @override
  void initState() {
    super.initState();
    final telemetryService = context.read<TelemetryService>();
    _serverUrlController = TextEditingController(text: telemetryService.serverUrl);
    _portController = TextEditingController(text: telemetryService.threeDRService.devicePort);
    _hostController = TextEditingController(text: telemetryService.threeDRService.remoteHost);
    _remotePortController = TextEditingController(
      text: telemetryService.threeDRService.remotePort.toString(),
    );
    _selectedMode = telemetryService.threeDRService.connectionMode;
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _portController.dispose();
    _hostController.dispose();
    _remotePortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration Source Données'),
        elevation: 0,
      ),
      body: Consumer<TelemetryService>(
        builder: (context, telemetryService, _) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // ===== Sélection de la source =====
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Source de Données',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Serveur HTTP
                      _buildSourceOption(
                        context,
                        telemetryService,
                        DataSource.server,
                        'Serveur HTTP',
                        'Données via connexion serveur',
                        Icons.cloud,
                      ),
                      const SizedBox(height: 12),
                      // Module 3DR
                      _buildSourceOption(
                        context,
                        telemetryService,
                        DataSource.threeDR,
                        'Module 3DR Radio Télémétrie',
                        'Données via radio FPV 3DR',
                        Icons.radio,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ===== Configuration Serveur =====
              if (telemetryService.dataSource == DataSource.server)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Configuration Serveur',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _serverUrlController,
                          decoration: InputDecoration(
                            labelText: 'URL du Serveur',
                            hintText: 'http://localhost:5000',
                            prefixIcon: const Icon(Icons.link),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) {
                            telemetryService.setServerUrl(value);
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          telemetryService.isConnected
                              ? '✓ Connecté au serveur'
                              : '✗ Déconnecté',
                          style: TextStyle(
                            color: telemetryService.isConnected
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (telemetryService.errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Erreur: ${telemetryService.errorMessage}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

              // ===== Configuration 3DR =====
              if (telemetryService.dataSource == DataSource.threeDR)
                Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Configuration Module 3DR',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Mode de connexion
                            DropdownButtonFormField<ThreeDRService.ConnectionMode>(
                              value: _selectedMode,
                              decoration: InputDecoration(
                                labelText: 'Mode de Connexion',
                                prefixIcon: const Icon(Icons.settings_input_composite),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: ThreeDRService.ConnectionMode.serial,
                                  child: const Text('Port Série (USB)'),
                                ),
                                DropdownMenuItem(
                                  value: ThreeDRService.ConnectionMode.udp,
                                  child: const Text('UDP (Réseau)'),
                                ),
                                DropdownMenuItem(
                                  value: ThreeDRService.ConnectionMode.tcp,
                                  child: const Text('TCP (Réseau)'),
                                ),
                              ],
                              onChanged: (mode) {
                                if (mode != null) {
                                  setState(() => _selectedMode = mode);
                                  telemetryService.configureThreeDR(
                                    mode: mode,
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            // Paramètres selon le mode
                            if (_selectedMode == ThreeDRService.ConnectionMode.serial)
                              Column(
                                children: [
                                  TextField(
                                    controller: _portController,
                                    decoration: InputDecoration(
                                      labelText: 'Port Série',
                                      hintText: '/dev/ttyUSB0 ou COM3',
                                      prefixIcon: const Icon(Icons.cable),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      telemetryService.configureThreeDR(
                                        mode: _selectedMode,
                                        port: value,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _remotePortController,
                                    decoration: InputDecoration(
                                      labelText: 'Débit (Baud Rate)',
                                      hintText: '57600',
                                      prefixIcon: const Icon(Icons.speed),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      final baud = int.tryParse(value) ?? 57600;
                                      telemetryService.configureThreeDR(
                                        mode: _selectedMode,
                                        baudRate: baud,
                                      );
                                    },
                                  ),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  TextField(
                                    controller: _hostController,
                                    decoration: InputDecoration(
                                      labelText: 'Adresse IP',
                                      hintText: '192.168.1.1',
                                      prefixIcon: const Icon(Icons.language),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      telemetryService.configureThreeDR(
                                        mode: _selectedMode,
                                        host: value,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _remotePortController,
                                    decoration: InputDecoration(
                                      labelText: 'Port',
                                      hintText: '14550',
                                      prefixIcon: const Icon(Icons.outlet),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      final port = int.tryParse(value) ?? 14550;
                                      telemetryService.configureThreeDR(
                                        mode: _selectedMode,
                                        remotePort: port,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await telemetryService.threeDRService
                                      .connectToThreeDR();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          telemetryService.threeDRService
                                                  .isConnected
                                              ? 'Connecté au module 3DR'
                                              : 'Erreur: ${telemetryService.threeDRService.errorMessage}',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.power_settings_new),
                                label: const Text('Connecter au Module 3DR'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              telemetryService.threeDRService.isConnected
                                  ? '✓ Connecté au module 3DR'
                                  : '✗ Déconnecté du module 3DR',
                              style: TextStyle(
                                color: telemetryService.threeDRService
                                        .isConnected
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (telemetryService.threeDRService.errorMessage
                                .isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Erreur: ${telemetryService.threeDRService.errorMessage}',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.info, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  'À Propos du Module 3DR',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '• Le module 3DR utilise le protocole MAVLink\n'
                              '• Port Série: USB sur /dev/ttyUSB0 (Linux) ou COM3/4 (Windows)\n'
                              '• UDP: Port 14550 (standard MAVLink)\n'
                              '• Débit recommandé: 57600 baud\n'
                              '• Portée approximative: 1-4 km\n'
                              '• Fréquence: 900 MHz (ISM)\n'
                              '• Compatible ArduPilot et PX4',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSourceOption(
    BuildContext context,
    TelemetryService telemetryService,
    DataSource source,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = telemetryService.dataSource == source;
    
    return InkWell(
      onTap: () async {
        await telemetryService.switchDataSource(source);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.blue.shade50 : Colors.transparent,
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
