import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:file_picker/file_picker.dart';
import 'telemetry_service.dart';

class ChartsPage extends StatefulWidget {
  const ChartsPage({super.key});

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  // 0=Altitude, 1=Vitesse, 2=Température, 3=Batterie, 4=Angles, 5=Accélération, 6=Pression
  int selectedChart = 0;

  static const _charts = [
    (icon: "Alt", label: "Altitude", color: Colors.blueAccent),
    (icon: "Vit", label: "Vitesse", color: Colors.orange),
    (icon: "Tmp", label: "Temperature", color: Colors.redAccent),
    (icon: "Bat", label: "Batterie", color: Colors.greenAccent),
    (icon: "Ang", label: "Angles", color: Colors.purpleAccent),
    (icon: "Acc", label: "Acceleration", color: Colors.cyanAccent),
    (icon: "Prs", label: "Pression", color: Colors.tealAccent),
  ];

  /// Import un fichier Excel ou CSV
  Future<void> _importFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx'], // Uniquement les formats supportés
        withData: true, // IMPORTANT: Charge le contenu du fichier en mémoire
        dialogTitle: 'Importer un fichier Excel ou CSV',
      );

      if (result != null && result.files.single.bytes != null) {
        final fileExtension = result.files.single.extension?.toLowerCase();
        final bytes =
            result.files.single.bytes!; // On récupère les données brutes

        final service = Provider.of<TelemetryService>(context, listen: false);

        try {
          if (fileExtension == 'xlsx') {
            await service.importExcelBytes(bytes);
          } else if (fileExtension == 'csv') {
            await service.importCSVBytes(bytes);
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '✓ Fichier importé : ${result.files.single.name}',
                ),
                backgroundColor: Colors.greenAccent,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur lors de l\'import : $e'),
                backgroundColor: Colors.redAccent,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  /// Navigation au graphique précédent
  void _goToPreviousChart() {
    setState(() {
      selectedChart = (selectedChart - 1).clamp(0, _charts.length - 1);
    });
  }

  /// Navigation au graphique suivant
  void _goToNextChart() {
    setState(() {
      selectedChart = (selectedChart + 1).clamp(0, _charts.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF161B22)
        : Colors.grey[100];

    return Consumer<TelemetryService>(
      builder: (context, service, child) {
        final history = service.history;

        if (history.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.show_chart, size: 60, color: Colors.grey[700]),
                const SizedBox(height: 12),
                const Text(
                  "En attente de donnees...",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Text(
                  service.errorMessage.isEmpty
                      ? "Connectez-vous au serveur, insérez une donnée manuelle ou importez un fichier"
                      : service.errorMessage,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.file_upload),
                  label: const Text("Importer Excel/CSV"),
                  onPressed: _importFile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    backgroundColor: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // ── Stat chips ──
              Container(
                color: bgColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatChip(
                      "Points",
                      history.length.toString(),
                      Colors.blueAccent,
                    ),
                    _buildStatChip(
                      "Alt max",
                      "${history.map((d) => d.altitude).reduce((a, b) => a > b ? a : b).toStringAsFixed(2)} m",
                      Colors.green,
                    ),
                    _buildStatChip(
                      "Vit max",
                      "${history.map((d) => d.speed).reduce((a, b) => a > b ? a : b).toStringAsFixed(2)} m/s",
                      Colors.orange,
                    ),
                    _buildStatChip(
                      "Bat min",
                      "${history.map((d) => d.battery).reduce((a, b) => a < b ? a : b).toStringAsFixed(2)} V",
                      Colors.greenAccent,
                    ),
                  ],
                ),
              ),

              // ── Sélecteur de graphique avec navigation ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
                child: Row(
                  children: [
                    // Bouton précédent
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                      onPressed: _goToPreviousChart,
                      tooltip: "Graphique précédent",
                      splashRadius: 20,
                    ),
                    // Graphiques - scrollable
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                            _charts.length,
                            (i) => _buildChartButton(i),
                          ),
                        ),
                      ),
                    ),
                    // Bouton suivant
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 20),
                      onPressed: _goToNextChart,
                      tooltip: "Graphique suivant",
                      splashRadius: 20,
                    ),
                    // Bouton import
                    IconButton(
                      icon: const Icon(Icons.upload_file, size: 20),
                      onPressed: _importFile,
                      tooltip: "Importer fichier",
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),

              // ── Graphique ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  height: 260,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getChartColor(
                        selectedChart,
                      ).withValues(alpha: 0.5),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                  child: _buildSelectedChart(history),
                ),
              ),

              // ── Stats live ──
              Padding(
                padding: const EdgeInsets.all(12),
                child: _buildLiveStats(service),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getChartColor(int idx) {
    const colors = [
      Colors.blueAccent,
      Colors.orange,
      Colors.redAccent,
      Colors.greenAccent,
      Colors.purpleAccent,
      Colors.cyanAccent,
      Colors.tealAccent,
    ];
    return colors[idx];
  }

  Widget _buildChartButton(int index) {
    final isSelected = selectedChart == index;
    final color = _getChartColor(index);
    final info = _charts[index];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () => setState(() => selectedChart = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.2)
                : (isDark ? const Color(0xFF161B22) : Colors.grey[200]),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: isSelected ? 2 : 1),
          ),
          child: Text(
            info.label,
            style: TextStyle(
              color: isSelected
                  ? color
                  : (isDark ? Colors.grey[400] : Colors.grey[700]),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedChart(List<dynamic> history) {
    switch (selectedChart) {
      case 0:
        return _buildLineChart(
          history,
          (d) => d.altitude,
          Colors.blueAccent,
          "Altitude (m)",
        );
      case 1:
        return _buildLineChart(
          history,
          (d) => d.speed,
          Colors.orange,
          "Vitesse (m/s)",
        );
      case 2:
        return _buildLineChart(
          history,
          (d) => d.temperature,
          Colors.redAccent,
          "Temperature (C)",
        );
      case 3:
        return _buildLineChart(
          history,
          (d) => d.battery,
          Colors.greenAccent,
          "Batterie (V)",
        );
      case 4:
        return _buildAnglesChart(history);
      case 5:
        return _buildAccelerationChart(history);
      case 6:
        return _buildLineChart(
          history,
          (d) => d.pressure,
          Colors.tealAccent,
          "Pression (hPa)",
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildLineChart(
    List<dynamic> history,
    double Function(dynamic) extractor,
    Color color,
    String unit,
  ) {
    if (history.isEmpty) return const SizedBox();

    final spots = <FlSpot>[];
    for (int i = 0; i < history.length; i++) {
      final v = extractor(history[i]);
      if (v.isFinite) spots.add(FlSpot(i.toDouble(), v));
    }
    if (spots.isEmpty)
      return const Center(
        child: Text("Pas de donnees", style: TextStyle(color: Colors.grey)),
      );

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY).abs() < 0.1 ? 1.0 : (maxY - minY) * 0.15;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LineChart(
      LineChartData(
        minY: minY - padding,
        maxY: maxY + padding,
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
            final service = Provider.of<TelemetryService>(
              context,
              listen: false,
            );
            if (!event.isInterestedForInteractions ||
                response == null ||
                response.lineBarSpots == null ||
                response.lineBarSpots!.isEmpty) {
              // Quand on lâche le clic/doigt
              service.setScrubbedIndex(null);
            } else {
              // Quand on survole ou clique
              service.setScrubbedIndex(response.lineBarSpots!.first.spotIndex);
            }
          },
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.1),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (v, _) => Text(
                v.toStringAsFixed(2),
                style: TextStyle(
                  color: isDark ? Colors.grey : Colors.grey[700],
                  fontSize: 9,
                ),
              ),
            ),
          ),
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildAnglesChart(List<dynamic> history) {
    if (history.isEmpty) return const SizedBox();

    List<FlSpot> pitchSpots = [], rollSpots = [], yawSpots = [];
    for (int i = 0; i < history.length; i++) {
      pitchSpots.add(FlSpot(i.toDouble(), history[i].pitch));
      rollSpots.add(FlSpot(i.toDouble(), history[i].roll));
      yawSpots.add(FlSpot(i.toDouble(), history[i].yaw % 180));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        LineChart(
          LineChartData(
            lineTouchData: LineTouchData(
              handleBuiltInTouches: true,
              touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                final service = Provider.of<TelemetryService>(
                  context,
                  listen: false,
                );
                if (!event.isInterestedForInteractions ||
                    response == null ||
                    response.lineBarSpots == null ||
                    response.lineBarSpots!.isEmpty) {
                  // Quand on lâche le clic/doigt
                  service.setScrubbedIndex(null);
                } else {
                  // Quand on survole ou clique
                  service.setScrubbedIndex(
                    response.lineBarSpots!.first.spotIndex,
                  );
                }
              },
            ),
            lineBarsData: [
              LineChartBarData(
                spots: pitchSpots,
                isCurved: true,
                color: Colors.blueAccent,
                barWidth: 2,
                dotData: const FlDotData(show: false),
              ),
              LineChartBarData(
                spots: rollSpots,
                isCurved: true,
                color: Colors.green,
                barWidth: 2,
                dotData: const FlDotData(show: false),
              ),
              LineChartBarData(
                spots: yawSpots,
                isCurved: true,
                color: Colors.purpleAccent,
                barWidth: 2,
                dotData: const FlDotData(show: false),
              ),
            ],
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (v, _) => Text(
                    "${v.toInt()}",
                    style: TextStyle(
                      color: isDark ? Colors.grey : Colors.grey[700],
                      fontSize: 9,
                    ),
                  ),
                ),
              ),
              bottomTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
          ),
        ),
        // Légende
        Positioned(
          top: 0,
          right: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _legendItem("Pitch", Colors.blueAccent),
              _legendItem("Roll", Colors.green),
              _legendItem("Yaw", Colors.purpleAccent),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccelerationChart(List<dynamic> history) {
    if (history.isEmpty) return const SizedBox();

    List<FlSpot> xSpots = [], ySpots = [], zSpots = [];
    for (int i = 0; i < history.length; i++) {
      xSpots.add(FlSpot(i.toDouble(), history[i].accelX));
      ySpots.add(FlSpot(i.toDouble(), history[i].accelY));
      zSpots.add(FlSpot(i.toDouble(), history[i].accelZ));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        LineChart(
          LineChartData(
            lineTouchData: LineTouchData(
              handleBuiltInTouches: true,
              touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                final service = Provider.of<TelemetryService>(
                  context,
                  listen: false,
                );
                if (!event.isInterestedForInteractions ||
                    response == null ||
                    response.lineBarSpots == null ||
                    response.lineBarSpots!.isEmpty) {
                  // Quand on lâche le clic/doigt
                  service.setScrubbedIndex(null);
                } else {
                  // Quand on survole ou clique
                  service.setScrubbedIndex(
                    response.lineBarSpots!.first.spotIndex,
                  );
                }
              },
            ),
            lineBarsData: [
              LineChartBarData(
                spots: xSpots,
                isCurved: true,
                color: Colors.redAccent,
                barWidth: 2,
                dotData: const FlDotData(show: false),
              ),
              LineChartBarData(
                spots: ySpots,
                isCurved: true,
                color: Colors.greenAccent,
                barWidth: 2,
                dotData: const FlDotData(show: false),
              ),
              LineChartBarData(
                spots: zSpots,
                isCurved: true,
                color: Colors.blueAccent,
                barWidth: 2,
                dotData: const FlDotData(show: false),
              ),
            ],
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (v, _) => Text(
                    v.toStringAsFixed(1),
                    style: TextStyle(
                      color: isDark ? Colors.grey : Colors.grey[700],
                      fontSize: 9,
                    ),
                  ),
                ),
              ),
              bottomTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
          ),
        ),
        Positioned(
          top: 0,
          right: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _legendItem("Accel X", Colors.redAccent),
              _legendItem("Accel Y", Colors.greenAccent),
              _legendItem("Accel Z", Colors.blueAccent),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 3,
          color: color,
          margin: const EdgeInsets.only(right: 4),
        ),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLiveStats(TelemetryService service) {
    if (service.displayData == null) return const SizedBox();
    final data = service.displayData!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service.scrubbedIndex != null
                ? "Statistiques à ce point précis"
                : "Statistiques en temps reel",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              _buildStatBox(
                "Altitude",
                "${data.altitude.toStringAsFixed(2)} m",
                Colors.blue,
              ),
              _buildStatBox(
                "Vitesse",
                "${data.speed.toStringAsFixed(2)} m/s",
                Colors.orange,
              ),
              _buildStatBox(
                "Temp",
                "${data.temperature.toStringAsFixed(2)} C",
                Colors.red,
              ),
              _buildStatBox(
                "Batterie",
                "${data.battery.toStringAsFixed(2)} V",
                Colors.green,
              ),
              _buildStatBox(
                "Pitch",
                "${data.pitch.toStringAsFixed(2)} deg",
                Colors.purple,
              ),
              _buildStatBox(
                "Roll",
                "${data.roll.toStringAsFixed(2)} deg",
                Colors.indigo,
              ),
              _buildStatBox(
                "Accel X",
                "${data.accelX.toStringAsFixed(2)} m/s2",
                Colors.redAccent,
              ),
              _buildStatBox(
                "Accel Y",
                "${data.accelY.toStringAsFixed(2)} m/s2",
                Colors.greenAccent,
              ),
              _buildStatBox(
                "Accel Z",
                "${data.accelZ.toStringAsFixed(2)} m/s2",
                Colors.blueAccent,
              ),
              _buildStatBox(
                "Pression",
                "${data.pressure.toStringAsFixed(2)} hPa",
                Colors.teal,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8),
        color: color.withValues(alpha: 0.05),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
