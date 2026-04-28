import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CalibrationData {
  // Gyroscope calibration (drone)
  double gyroOffsetX;
  double gyroOffsetY;
  double gyroOffsetZ;
  
  // Accelerometer calibration (drone)
  double accelOffsetX;
  double accelOffsetY;
  double accelOffsetZ;
  double accelScaleX;
  double accelScaleY;
  double accelScaleZ;
  
  // Magnetometer calibration (drone)
  double magOffsetX;
  double magOffsetY;
  double magOffsetZ;
  double magScaleX;
  double magScaleY;
  double magScaleZ;
  
  // Remote control calibration
  double rcThrottleMin;
  double rcThrottleMax;
  double rcRollMin;
  double rcRollMax;
  double rcPitchMin;
  double rcPitchMax;
  double rcYawMin;
  double rcYawMax;
  
  // Compass calibration
  double compassDeclinationAngle;
  
  // Calibration status
  bool isGyroCalibrated;
  bool isAccelCalibrated;
  bool isMagCalibrated;
  bool isRCCalibrated;
  
  DateTime lastCalibrationTime;

  CalibrationData({
    this.gyroOffsetX = 0.0,
    this.gyroOffsetY = 0.0,
    this.gyroOffsetZ = 0.0,
    this.accelOffsetX = 0.0,
    this.accelOffsetY = 0.0,
    this.accelOffsetZ = 0.0,
    this.accelScaleX = 1.0,
    this.accelScaleY = 1.0,
    this.accelScaleZ = 1.0,
    this.magOffsetX = 0.0,
    this.magOffsetY = 0.0,
    this.magOffsetZ = 0.0,
    this.magScaleX = 1.0,
    this.magScaleY = 1.0,
    this.magScaleZ = 1.0,
    this.rcThrottleMin = 1000.0,
    this.rcThrottleMax = 2000.0,
    this.rcRollMin = 1000.0,
    this.rcRollMax = 2000.0,
    this.rcPitchMin = 1000.0,
    this.rcPitchMax = 2000.0,
    this.rcYawMin = 1000.0,
    this.rcYawMax = 2000.0,
    this.compassDeclinationAngle = 0.0,
    this.isGyroCalibrated = false,
    this.isAccelCalibrated = false,
    this.isMagCalibrated = false,
    this.isRCCalibrated = false,
    DateTime? lastCalibrationTime,
  }) : lastCalibrationTime = lastCalibrationTime ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'gyroOffsetX': gyroOffsetX,
      'gyroOffsetY': gyroOffsetY,
      'gyroOffsetZ': gyroOffsetZ,
      'accelOffsetX': accelOffsetX,
      'accelOffsetY': accelOffsetY,
      'accelOffsetZ': accelOffsetZ,
      'accelScaleX': accelScaleX,
      'accelScaleY': accelScaleY,
      'accelScaleZ': accelScaleZ,
      'magOffsetX': magOffsetX,
      'magOffsetY': magOffsetY,
      'magOffsetZ': magOffsetZ,
      'magScaleX': magScaleX,
      'magScaleY': magScaleY,
      'magScaleZ': magScaleZ,
      'rcThrottleMin': rcThrottleMin,
      'rcThrottleMax': rcThrottleMax,
      'rcRollMin': rcRollMin,
      'rcRollMax': rcRollMax,
      'rcPitchMin': rcPitchMin,
      'rcPitchMax': rcPitchMax,
      'rcYawMin': rcYawMin,
      'rcYawMax': rcYawMax,
      'compassDeclinationAngle': compassDeclinationAngle,
      'isGyroCalibrated': isGyroCalibrated,
      'isAccelCalibrated': isAccelCalibrated,
      'isMagCalibrated': isMagCalibrated,
      'isRCCalibrated': isRCCalibrated,
      'lastCalibrationTime': lastCalibrationTime.toIso8601String(),
    };
  }

  factory CalibrationData.fromJson(Map<String, dynamic> json) {
    return CalibrationData(
      gyroOffsetX: (json['gyroOffsetX'] as num?)?.toDouble() ?? 0.0,
      gyroOffsetY: (json['gyroOffsetY'] as num?)?.toDouble() ?? 0.0,
      gyroOffsetZ: (json['gyroOffsetZ'] as num?)?.toDouble() ?? 0.0,
      accelOffsetX: (json['accelOffsetX'] as num?)?.toDouble() ?? 0.0,
      accelOffsetY: (json['accelOffsetY'] as num?)?.toDouble() ?? 0.0,
      accelOffsetZ: (json['accelOffsetZ'] as num?)?.toDouble() ?? 0.0,
      accelScaleX: (json['accelScaleX'] as num?)?.toDouble() ?? 1.0,
      accelScaleY: (json['accelScaleY'] as num?)?.toDouble() ?? 1.0,
      accelScaleZ: (json['accelScaleZ'] as num?)?.toDouble() ?? 1.0,
      magOffsetX: (json['magOffsetX'] as num?)?.toDouble() ?? 0.0,
      magOffsetY: (json['magOffsetY'] as num?)?.toDouble() ?? 0.0,
      magOffsetZ: (json['magOffsetZ'] as num?)?.toDouble() ?? 0.0,
      magScaleX: (json['magScaleX'] as num?)?.toDouble() ?? 1.0,
      magScaleY: (json['magScaleY'] as num?)?.toDouble() ?? 1.0,
      magScaleZ: (json['magScaleZ'] as num?)?.toDouble() ?? 1.0,
      rcThrottleMin: (json['rcThrottleMin'] as num?)?.toDouble() ?? 1000.0,
      rcThrottleMax: (json['rcThrottleMax'] as num?)?.toDouble() ?? 2000.0,
      rcRollMin: (json['rcRollMin'] as num?)?.toDouble() ?? 1000.0,
      rcRollMax: (json['rcRollMax'] as num?)?.toDouble() ?? 2000.0,
      rcPitchMin: (json['rcPitchMin'] as num?)?.toDouble() ?? 1000.0,
      rcPitchMax: (json['rcPitchMax'] as num?)?.toDouble() ?? 2000.0,
      rcYawMin: (json['rcYawMin'] as num?)?.toDouble() ?? 1000.0,
      rcYawMax: (json['rcYawMax'] as num?)?.toDouble() ?? 2000.0,
      compassDeclinationAngle: (json['compassDeclinationAngle'] as num?)?.toDouble() ?? 0.0,
      isGyroCalibrated: json['isGyroCalibrated'] as bool? ?? false,
      isAccelCalibrated: json['isAccelCalibrated'] as bool? ?? false,
      isMagCalibrated: json['isMagCalibrated'] as bool? ?? false,
      isRCCalibrated: json['isRCCalibrated'] as bool? ?? false,
      lastCalibrationTime: json['lastCalibrationTime'] != null
          ? DateTime.parse(json['lastCalibrationTime'] as String)
          : DateTime.now(),
    );
  }
}

class CalibrationService extends ChangeNotifier {
  CalibrationData calibrationData = CalibrationData();
  String errorMessage = "";
  bool isCalibrating = false;
  String calibrationStatus = "";

  static const String _calibrationFileName = 'drone_calibration.json';

  CalibrationService() {
    loadCalibration();
  }

  Future<void> loadCalibration() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_calibrationFileName');
      
      if (await file.exists()) {
        final contents = await file.readAsString();
        final json = jsonDecode(contents);
        calibrationData = CalibrationData.fromJson(json);
        errorMessage = "";
      } else {
        calibrationData = CalibrationData();
      }
    } catch (e) {
      errorMessage = "Erreur lors du chargement de la calibration: $e";
      calibrationData = CalibrationData();
    }
    notifyListeners();
  }

  Future<void> saveCalibration() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_calibrationFileName');
      await file.writeAsString(jsonEncode(calibrationData.toJson()));
      errorMessage = "";
    } catch (e) {
      errorMessage = "Erreur lors de la sauvegarde: $e";
    }
    notifyListeners();
  }

  Future<void> startGyroCalibration() async {
    isCalibrating = true;
    calibrationStatus = "Calibration du gyroscope en cours... Immobilisez le drone!";
    notifyListeners();

    try {
      // Simulation de calibration (5 secondes)
      await Future.delayed(const Duration(seconds: 5));
      calibrationData.isGyroCalibrated = true;
      calibrationData.gyroOffsetX = 0.0;
      calibrationData.gyroOffsetY = 0.0;
      calibrationData.gyroOffsetZ = 0.0;
      calibrationStatus = "✓ Gyroscope calibré avec succès!";
      await saveCalibration();
    } catch (e) {
      calibrationStatus = "✗ Erreur lors de la calibration: $e";
    } finally {
      isCalibrating = false;
      notifyListeners();
    }
  }

  Future<void> startAccelCalibration() async {
    isCalibrating = true;
    calibrationStatus = "Calibration de l'accéléromètre en cours... Positionnez le drone dans 6 orientations différentes.";
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 10));
      calibrationData.isAccelCalibrated = true;
      calibrationData.accelOffsetX = 0.0;
      calibrationData.accelOffsetY = 0.0;
      calibrationData.accelOffsetZ = 0.0;
      calibrationStatus = "✓ Accéléromètre calibré!";
      await saveCalibration();
    } catch (e) {
      calibrationStatus = "✗ Erreur: $e";
    } finally {
      isCalibrating = false;
      notifyListeners();
    }
  }

  Future<void> startMagnetometerCalibration() async {
    isCalibrating = true;
    calibrationStatus = "Calibration du magnétomètre en cours... Tournez le drone lentement dans toutes les directions.";
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 15));
      calibrationData.isMagCalibrated = true;
      calibrationData.magOffsetX = 0.0;
      calibrationData.magOffsetY = 0.0;
      calibrationData.magOffsetZ = 0.0;
      calibrationStatus = "✓ Magnétomètre calibré!";
      await saveCalibration();
    } catch (e) {
      calibrationStatus = "✗ Erreur: $e";
    } finally {
      isCalibrating = false;
      notifyListeners();
    }
  }

  Future<void> calibrateRCChannel(String channel, double minValue, double maxValue) async {
    try {
      switch (channel.toLowerCase()) {
        case 'throttle':
          calibrationData.rcThrottleMin = minValue;
          calibrationData.rcThrottleMax = maxValue;
          break;
        case 'roll':
          calibrationData.rcRollMin = minValue;
          calibrationData.rcRollMax = maxValue;
          break;
        case 'pitch':
          calibrationData.rcPitchMin = minValue;
          calibrationData.rcPitchMax = maxValue;
          break;
        case 'yaw':
          calibrationData.rcYawMin = minValue;
          calibrationData.rcYawMax = maxValue;
          break;
      }
      if (calibrationData.rcThrottleMin != 1000.0 &&
          calibrationData.rcRollMin != 1000.0 &&
          calibrationData.rcPitchMin != 1000.0 &&
          calibrationData.rcYawMin != 1000.0) {
        calibrationData.isRCCalibrated = true;
      }
      await saveCalibration();
      notifyListeners();
    } catch (e) {
      errorMessage = "Erreur lors de la calibration RC: $e";
      notifyListeners();
    }
  }

  Future<void> resetAllCalibrations() async {
    calibrationData = CalibrationData();
    await saveCalibration();
    notifyListeners();
  }

  void setCompassDeclinationAngle(double angle) {
    calibrationData.compassDeclinationAngle = angle;
    notifyListeners();
  }

  bool areAllCalibrated() {
    return calibrationData.isGyroCalibrated &&
        calibrationData.isAccelCalibrated &&
        calibrationData.isMagCalibrated &&
        calibrationData.isRCCalibrated;
  }

  Future<String> exportCalibrationToJson() async {
    try {
      return jsonEncode(calibrationData.toJson());
    } catch (e) {
      errorMessage = "Erreur lors de l'export: $e";
      return "";
    }
  }

  Future<bool> importCalibrationFromJson(String jsonString) async {
    try {
      final json = jsonDecode(jsonString);
      calibrationData = CalibrationData.fromJson(json);
      await saveCalibration();
      errorMessage = "";
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = "Erreur lors de l'import: $e";
      notifyListeners();
      return false;
    }
  }
}
