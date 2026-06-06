import 'package:flutter/foundation.dart';
import 'telemetry_service.dart';

/// Utilitaire de debug pour tracer les données MAVLink
class DebugTelemetry {
  static void debugTelemetryFlow(TelemetryService service) {
    if (!kDebugMode) return;
    
    // Afficher l'état de la source de données
    print('=== DEBUG TELEMETRY FLOW ===');
    print('Data Source: ${service.dataSource}');
    print('Is Connected: ${service.isConnected}');
    print('Error Message: ${service.errorMessage}');
    print('Failed Attempts: ${service.failedAttempts}');
    
    // Afficher les données actuelles
    if (service.currentData != null) {
      final data = service.currentData!;
      print('Current Data:');
      print('  - Timestamp: ${data.timestamp}');
      print('  - Pitch/Roll/Yaw: ${data.pitch.toStringAsFixed(2)}° / '
          '${data.roll.toStringAsFixed(2)}° / '
          '${data.yaw.toStringAsFixed(2)}°');
      print('  - Altitude: ${data.altitude.toStringAsFixed(1)} m');
      print('  - Speed: ${data.speed.toStringAsFixed(2)} m/s');
      print('  - Battery: ${data.battery.toStringAsFixed(0)}%');
      print('  - Temperature: ${data.temperature.toStringAsFixed(1)}°C');
    } else {
      print('Current Data: NULL - ⚠️ AUCUNE DONNÉE');
    }
    
    // Afficher l'historique
    print('History Size: ${service.history.length}');
    if (service.history.isNotEmpty) {
      final lastData = service.history.last;
      print('Last Entry in History:');
      print('  - Altitude: ${lastData.altitude.toStringAsFixed(1)} m');
      print('  - Speed: ${lastData.speed.toStringAsFixed(2)} m/s');
      print('  - Battery: ${lastData.battery.toStringAsFixed(0)}%');
    }
    
    print('========================\n');
  }

  /// Debug l'état du service 3DR
  static void debug3DRService(dynamic threeDRService) {
    if (!kDebugMode) return;
    
    print('=== DEBUG 3DR SERVICE ===');
    print('Connected: ${threeDRService.isConnected}');
    print('Device Port: ${threeDRService.devicePort}');
    print('Connection Mode: ${threeDRService.connectionMode}');
    print('Packet Count: ${threeDRService._packetCount}');
    print('Last Data Time: ${threeDRService._lastDataTime}');
    print('History Size: ${threeDRService.history.length}');
    
    if (threeDRService.currentData != null) {
      print('Current Data: Available');
    } else {
      print('Current Data: NULL - ⚠️ PAS DE DONNÉES');
    }
    
    print('========================\n');
  }
}
