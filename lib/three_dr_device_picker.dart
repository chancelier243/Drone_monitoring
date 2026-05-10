import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'telemetry_service.dart';
import 'three_dr_service.dart';

/// Page pour détecter et sélectionner les modules 3DR disponibles
class ThreeDRDevicePickerPage extends StatefulWidget {
  const ThreeDRDevicePickerPage({super.key});

  @override
  State<ThreeDRDevicePickerPage> createState() =>
      _ThreeDRDevicePickerPageState();
}

class _ThreeDRDevicePickerPageState extends State<ThreeDRDevicePickerPage> {
  bool _isScanning = false;
  List<ThreeDRDevice> _devices = [];

  @override
  void initState() {
    super.initState();
    _scanForDevices();
  }

  Future<void> _scanForDevices() async {
    setState(() => _isScanning = true);

    try {
      final telemetryService = context.read<TelemetryService>();
      _devices = await telemetryService.threeDRService.detectThreeDRDevices();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur scan: $e')),
        );
      }
    }

    if (mounted) {
      setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final telemetryService = context.read<TelemetryService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélectionner Module 3DR'),
        elevation: 0,
      ),
      body: _isScanning
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Scan des ports sériels...'),
                ],
              ),
            )
          : _devices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Aucun module 3DR détecté',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _scanForDevices,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Rescanner'),
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
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
                                      'Dépannage',
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
                                  '• Vérifiez que le module 3DR est alimenté\n'
                                  '• Vérifiez la connexion USB\n'
                                  '• Installez les drivers FTDI si nécessaire\n'
                                  '• Redémarrez l\'appareil\n'
                                  '• Essayez un autre port USB',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _devices.length,
                  itemBuilder: (context, index) {
                    final device = _devices[index];
                    final isSelected =
                        telemetryService.threeDRService.selectedDevice ==
                            device;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          telemetryService.threeDRService.selectDevice(device);
                          Navigator.pop(context, device);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.radio,
                                color: isSelected ? Colors.green : Colors.grey,
                                size: 32,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      device.productName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      device.portName,
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
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
