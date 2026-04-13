class TelemetryData {
  final DateTime timestamp;
  final double pitch;
  final double roll;
  final double yaw;
  final double altitude;
  final double speed;
  final double battery;
  final double temperature;
  final double acceleration; // m/s² (norme ou valeur max/principale si vieux format)
  final double accelX;
  final double accelY;
  final double accelZ;
  final double pressure;     // hPa
  final List<String> alerts;

  TelemetryData({
    required this.timestamp,
    required this.pitch,
    required this.roll,
    required this.yaw,
    required this.altitude,
    required this.speed,
    required this.battery,
    required this.temperature,
    this.acceleration = 0.0,
    this.accelX = 0.0,
    this.accelY = 0.0,
    this.accelZ = 0.0,
    this.pressure = 1013.25,
    this.alerts = const [],
  });

  factory TelemetryData.fromJson(Map<String, dynamic> json) {
    return TelemetryData(
      timestamp:    _parseTimestamp(json['timestamp']),
      pitch: double.tryParse(json['pitch']?.toString() ?? '') ?? 0.0,
      roll:  double.tryParse(json['roll']?.toString() ?? '') ?? 0.0,
      yaw:   double.tryParse(json['yaw']?.toString() ?? '') ?? 0.0,
      altitude: double.tryParse(json['altitude']?.toString() ?? '') ?? 0.0,
      speed:        double.tryParse(json['speed']?.toString() ?? '') ?? 0.0,
      battery:      double.tryParse(json['battery']?.toString() ?? '') ?? 0.0,
      temperature:  double.tryParse(json['temperature']?.toString() ?? '') ?? 0.0,
      acceleration: double.tryParse(json['acceleration']?.toString() ?? '') ?? 0.0,
      accelX:       double.tryParse(json['accelX']?.toString() ?? '') ?? 0.0,
      accelY:       double.tryParse(json['accelY']?.toString() ?? '') ?? 0.0,
      accelZ:       double.tryParse(json['accelZ']?.toString() ?? '') ?? 0.0, // fallback pour compatibilité
      pressure:     double.tryParse(json['pressure']?.toString() ?? '') ?? 1013.25,
      alerts:       _parseAlerts(json['alerts']),
    );
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is String) {
      try { return DateTime.parse(timestamp); } catch (_) {}
    }
    return DateTime.now();
  }

  static List<String> _parseAlerts(dynamic alerts) {
    if (alerts == null) return [];
    if (alerts is List) return List<String>.from(alerts.map((e) => e.toString()));
    return [];
  }
}