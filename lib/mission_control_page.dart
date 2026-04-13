import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'telemetry_service.dart';

class MissionControlPage extends StatefulWidget {
  const MissionControlPage({super.key});

  @override
  State<MissionControlPage> createState() => _MissionControlPageState();
}

class _MissionControlPageState extends State<MissionControlPage> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final service = Provider.of<TelemetryService>(context, listen: false);
    _urlController.text = service.serverUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TelemetryService>(
      builder: (context, service, child) {
        final data = service.currentData;

        if (data == null) {
          return Stack(
            children: [
              _buildConnectionScreen(service, context),
            ],
          );
        }

        return Stack(
          children: [
            Container(color: Theme.of(context).scaffoldBackgroundColor),
            SingleChildScrollView(
              child: Column(
                children: [
                  _buildStatusBar(service, data),
                  // Horizon artificiel style Mission Planner
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: ArtificialHorizon(
                        pitch: data.pitch,
                        roll: data.roll,
                        yaw: data.yaw,
                        altitude: data.altitude,
                        speed: data.speed,
                      ),
                    ),
                  ),
                  _buildParametersGrid(data),
                  if (data.alerts.isNotEmpty) _buildAlertsSection(data.alerts),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConnectionScreen(TelemetryService service, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 80, color: Colors.red[300]),
            const SizedBox(height: 20),
            Text(
              "Non connecte au serveur",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              service.errorMessage,
              style: TextStyle(fontSize: 14, color: Colors.red[200]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Configuration du serveur",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _urlController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: "Ex: http://192.168.1.100:5000",
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => service.setServerUrl(_urlController.text),
                    icon: const Icon(Icons.check),
                    label: const Text("Se connecter"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Tentatives echouees: ${service.failedAttempts}",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar(TelemetryService service, dynamic data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final batteryColor = data.battery > 11.0
        ? Colors.greenAccent
        : (data.battery > 10.0 ? Colors.yellowAccent : Colors.redAccent);

    return Container(
      color: isDark ? const Color(0xFF161B22) : Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(children: [
            const Text("Status", style: TextStyle(fontSize: 11, color: Colors.grey)),
            Row(children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: service.isConnected ? Colors.greenAccent : Colors.redAccent,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                service.isConnected ? "Connecte" : "Deconnecte",
                style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold,
                  color: service.isConnected ? (isDark ? Colors.greenAccent : Colors.green) : Colors.redAccent,
                ),
              ),
            ]),
          ]),
          _buildStatusItem("Batterie", "${data.battery.toStringAsFixed(2)}V", batteryColor),
          _buildStatusItem("Temp", "${data.temperature.toStringAsFixed(2)}C", _getTempColor(data.temperature)),
          _buildStatusItem("Alertes", data.alerts.length.toString(), data.alerts.isEmpty ? Colors.greenAccent : Colors.redAccent),
        ],
      ),
    );
  }

  Color _getBatteryColor(double battery) {
    if (battery > 11.0) return Colors.greenAccent;
    if (battery > 10.0) return Colors.yellowAccent;
    return Colors.redAccent;
  }

  Color _getTempColor(double temperature) {
    if (temperature < 30) return Colors.blueAccent;
    if (temperature < 40) return Colors.greenAccent;
    if (temperature < 50) return Colors.yellowAccent;
    return Colors.redAccent;
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildParametersGrid(dynamic data) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: [
          _buildParamCard("Altitude",      "${data.altitude.toStringAsFixed(2)} m",     Colors.blueAccent,    Icons.height),
          _buildParamCard("Vitesse",       "${data.speed.toStringAsFixed(2)} m/s",      Colors.green,         Icons.speed),
          _buildParamCard("Pitch",         "${data.pitch.toStringAsFixed(2)} deg",       Colors.orange,        Icons.trending_up),
          _buildParamCard("Roll",          "${data.roll.toStringAsFixed(2)} deg",        Colors.purpleAccent,  Icons.rotate_90_degrees_ccw),
          _buildParamCard("Batterie",      "${data.battery.toStringAsFixed(2)} V",      _getBatteryColor(data.battery), Icons.battery_charging_full),
          _buildParamCard("Temperature",   "${data.temperature.toStringAsFixed(2)} C",  _getTempColor(data.temperature), Icons.thermostat),
          _buildParamCard("Accel Z (G)",   "${data.accelZ.toStringAsFixed(2)} m/s2",    Colors.cyanAccent,    Icons.trending_up),
          _buildParamCard("Pression",      "${data.pressure.toStringAsFixed(2)} hPa",    Colors.tealAccent,    Icons.compress),
        ],
      ),
    );
  }

  Widget _buildParamCard(String label, String value, Color color, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 8)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 3),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildAlertsSection(List<String> alerts) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: Colors.redAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                'Alertes (${alerts.length})',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.redAccent),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...alerts.map((alert) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 6, color: Colors.redAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    alert,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  HORIZON ARTIFICIEL — Style Mission Planner
// ═══════════════════════════════════════════════════════════════════════════════

class ArtificialHorizon extends StatelessWidget {
  final double pitch;
  final double roll;
  final double yaw;
  final double altitude;
  final double speed;

  const ArtificialHorizon({
    super.key,
    required this.pitch,
    required this.roll,
    required this.yaw,
    required this.altitude,
    required this.speed,
  });

  static const double _size = 280.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Horizon principal dans un cercle avec clip
          ClipOval(
            child: SizedBox(
              width: _size,
              height: _size,
              child: CustomPaint(
                painter: _HorizonPainter(pitch: pitch, roll: roll),
                size: const Size(_size, _size),
              ),
            ),
          ),

          // Indicateur de roulis (arc + triangle en haut)
          CustomPaint(
            painter: _RollArcPainter(roll: roll),
            size: const Size(_size, _size),
          ),

          // Croix de référence centrale fixe
          CustomPaint(
            painter: _ReticlePainter(),
            size: const Size(_size, _size),
          ),

          // Bordure extérieure avec graduation de roulis
          Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2),
            ),
          ),

          // Panneau vitesse (gauche)
          Positioned(
            left: 0,
            top: _size * 0.15,
            child: _SidePanel(
              label: "SPD",
              value: speed.toStringAsFixed(2),
              unit: "m/s",
              width: 44,
              height: _size * 0.7,
            ),
          ),

          // Panneau altitude (droite)
          Positioned(
            right: 0,
            top: _size * 0.15,
            child: _SidePanel(
              label: "ALT",
              value: altitude.toStringAsFixed(2),
              unit: "m",
              width: 44,
              height: _size * 0.7,
            ),
          ),

          // Cap magnétique en bas
          Positioned(
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white30),
              ),
              child: Text(
                "${yaw.toStringAsFixed(2)}°",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Peintre de l'horizon (ciel + sol + lignes de tangage) ──────────────────

class _HorizonPainter extends CustomPainter {
  final double pitch;
  final double roll;

  const _HorizonPainter({required this.pitch, required this.roll});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(-roll * math.pi / 180);

    // Décalage vertical dû au tangage (1° ≈ 3px pour bien remplir)
    final pitchOffset = pitch * 3.0;
    final halfW = size.width;
    final halfH = size.height;

    // ── Ciel ──
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF1A3A6B), const Color(0xFF2E6DB4)],
      ).createShader(Rect.fromLTWH(-halfW, -halfH + pitchOffset, halfW * 2, halfH));
    canvas.drawRect(Rect.fromLTWH(-halfW, -halfH + pitchOffset, halfW * 2, halfH), skyPaint);

    // ── Sol ──
    final groundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF5C3A10), const Color(0xFF3B2408)],
      ).createShader(Rect.fromLTWH(-halfW, pitchOffset, halfW * 2, halfH));
    canvas.drawRect(Rect.fromLTWH(-halfW, pitchOffset, halfW * 2, halfH), groundPaint);

    // ── Ligne d'horizon ──
    final horizonPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(-halfW, pitchOffset), Offset(halfW, pitchOffset), horizonPaint);

    // ── Lignes de tangage (pitch ladder) ──
    _drawPitchLadder(canvas, pitchOffset, halfW);

    canvas.restore();
  }

  void _drawPitchLadder(Canvas canvas, double pitchOffset, double halfW) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 10,
      fontFamily: 'monospace',
    );

    for (int deg = -30; deg <= 30; deg += 5) {
      if (deg == 0) continue;
      final y = pitchOffset - deg * 3.0;
      final isMajor = deg % 10 == 0;
      final lineHalfW = isMajor ? halfW * 0.28 : halfW * 0.16;

      canvas.drawLine(Offset(-lineHalfW, y), Offset(lineHalfW, y), linePaint);

      if (isMajor) {
        // Petits traits verticaux aux extrémités
        canvas.drawLine(Offset(-lineHalfW, y), Offset(-lineHalfW, y + (deg > 0 ? 5 : -5)), linePaint);
        canvas.drawLine(Offset(lineHalfW, y), Offset(lineHalfW, y + (deg > 0 ? 5 : -5)), linePaint);

        // Texte du degré
        final tp = TextPainter(
          text: TextSpan(text: deg.abs().toString(), style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(-lineHalfW - tp.width - 4, y - tp.height / 2));
        tp.paint(canvas, Offset(lineHalfW + 4, y - tp.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(_HorizonPainter old) => old.pitch != pitch || old.roll != roll;
}

// ─── Arc indicateur de roulis ─────────────────────────────────────────────────

class _RollArcPainter extends CustomPainter {
  final double roll;
  const _RollArcPainter({required this.roll});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width / 2 - 6;

    final arcPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Arc du haut (graduation roulis) — de -60° à +60°
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      -math.pi * 5 / 6, // -150° en radians depuis axe X
      math.pi * 2 / 3,  // 120° d'arc
      false,
      arcPaint,
    );

    // Graduations sur l'arc : 0°, ±10°, ±20°, ±30°, ±45°, ±60°
    final markPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (final deg in [-60, -45, -30, -20, -10, 0, 10, 20, 30, 45, 60]) {
      final angle = (-90 + deg) * math.pi / 180;
      final isMajor = deg % 30 == 0;
      final innerR = radius - (isMajor ? 10 : 6);
      canvas.drawLine(
        Offset(cx + math.cos(angle) * innerR, cy + math.sin(angle) * innerR),
        Offset(cx + math.cos(angle) * radius, cy + math.sin(angle) * radius),
        markPaint,
      );
    }

    // Triangle indicateur de roulis
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(roll * math.pi / 180);
    final triPaint = Paint()..color = Colors.white;
    final path = Path()
      ..moveTo(0, -(radius - 18))
      ..lineTo(-7, -(radius - 6))
      ..lineTo(7, -(radius - 6))
      ..close();
    canvas.drawPath(path, triPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RollArcPainter old) => old.roll != roll;
}

// ─── Réticule central fixe ────────────────────────────────────────────────────

class _ReticlePainter extends CustomPainter {
  const _ReticlePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Ailes (gauche et droite)
    canvas.drawLine(Offset(cx - 50, cy), Offset(cx - 18, cy), paint);
    canvas.drawLine(Offset(cx + 18, cy), Offset(cx + 50, cy), paint);

    // Petite montée au centre
    canvas.drawLine(Offset(cx - 18, cy), Offset(cx - 8, cy + 12), paint);
    canvas.drawLine(Offset(cx + 8, cy + 12), Offset(cx + 18, cy), paint);
    canvas.drawLine(Offset(cx - 8, cy + 12), Offset(cx + 8, cy + 12), paint);

    // Point central
    final dotPaint = Paint()..color = Colors.yellow;
    canvas.drawCircle(Offset(cx, cy), 3, dotPaint);
  }

  @override
  bool shouldRepaint(_ReticlePainter old) => false;
}

// ─── Panneau latéral (vitesse / altitude) ────────────────────────────────────

class _SidePanel extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final double width;
  final double height;

  const _SidePanel({
    required this.label,
    required this.value,
    required this.unit,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 9, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.center,
          ),
          Text(unit, style: const TextStyle(color: Colors.grey, fontSize: 9)),
        ],
      ),
    );
  }
}
