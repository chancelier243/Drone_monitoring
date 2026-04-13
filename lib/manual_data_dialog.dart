import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data_model.dart';
import 'telemetry_service.dart';

class ManualDataDialog extends StatefulWidget {
  const ManualDataDialog({super.key});

  @override
  State<ManualDataDialog> createState() => _ManualDataDialogState();
}

class _ManualDataDialogState extends State<ManualDataDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _altCtrl = TextEditingController(text: "100.0");
  final _speedCtrl = TextEditingController(text: "15.0");
  final _batCtrl = TextEditingController(text: "11.5");
  final _tempCtrl = TextEditingController(text: "25.0");
  final _pitchCtrl = TextEditingController(text: "0.0");
  final _rollCtrl = TextEditingController(text: "0.0");
  final _yawCtrl = TextEditingController(text: "0.0");
  final _accXCtrl = TextEditingController(text: "0.0");
  final _accYCtrl = TextEditingController(text: "0.0");
  final _accZCtrl = TextEditingController(text: "9.81");
  final _pressCtrl = TextEditingController(text: "1013.25");

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Insérer une donnée manuelle"),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildField(_altCtrl, "Altitude (m)"),
                _buildField(_speedCtrl, "Vitesse (m/s)"),
                _buildField(_batCtrl, "Batterie (V)"),
                _buildField(_tempCtrl, "Température (°C)"),
                Row(
                  children: [
                    Expanded(child: _buildField(_pitchCtrl, "Pitch")),
                    const SizedBox(width: 8),
                    Expanded(child: _buildField(_rollCtrl, "Roll")),
                    const SizedBox(width: 8),
                    Expanded(child: _buildField(_yawCtrl, "Yaw")),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _buildField(_accXCtrl, "Accel X")),
                    const SizedBox(width: 8),
                    Expanded(child: _buildField(_accYCtrl, "Accel Y")),
                    const SizedBox(width: 8),
                    Expanded(child: _buildField(_accZCtrl, "Accel Z")),
                  ],
                ),
                _buildField(_pressCtrl, "Pression (hPa)"),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final data = TelemetryData(
                timestamp: DateTime.now(),
                pitch: double.parse(_pitchCtrl.text),
                roll: double.parse(_rollCtrl.text),
                yaw: double.parse(_yawCtrl.text),
                altitude: double.parse(_altCtrl.text),
                speed: double.parse(_speedCtrl.text),
                battery: double.parse(_batCtrl.text),
                temperature: double.parse(_tempCtrl.text),
                accelX: double.parse(_accXCtrl.text),
                accelY: double.parse(_accYCtrl.text),
                accelZ: double.parse(_accZCtrl.text),
                acceleration: double.parse(_accZCtrl.text), // Par défaut la norme est l'axe Z pour les tests
                pressure: double.parse(_pressCtrl.text),
              );
              
              Provider.of<TelemetryService>(context, listen: false).injectData(data);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Donnée injectée avec succès !")),
              );
            }
          },
          child: const Text("Ajouter"),
        ),
      ],
    );
  }

  Widget _buildField(TextEditingController ctrl, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (v) => (v == null || double.tryParse(v) == null) ? "Invalide" : null,
      ),
    );
  }
}
