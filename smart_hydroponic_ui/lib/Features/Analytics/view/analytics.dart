import 'package:fl_chart/fl_chart.dart';
import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';
import 'package:intl/intl.dart';

class AnalyticsHistoryScreen extends StatelessWidget {
  const AnalyticsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnalyticsProvider()..fetchData(),
      child: const _AnalyticsHistoryScreenContent(),
    );
  }
}

class _AnalyticsHistoryScreenContent extends StatelessWidget {
  const _AnalyticsHistoryScreenContent();

  void _exportData(BuildContext context, AnalyticsProvider provider) {
    // Simple CSV export simulation
    StringBuffer csv = StringBuffer();
    csv.writeln("Timestamp,Sensor Type,Value,Status");
    for (var item in provider.allSensorData) {
      csv.writeln(
        "${item['timestamp']},${item['sensorType']},${item['value']},${item['status']}",
      );
    }

    // In a real app, you'd save this to a file or share it.
    // For now, we'll show a dialog with the data.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Export Data (CSV Preview)"),
        content: SingleChildScrollView(child: SelectableText(csv.toString())),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(AnalyticsProvider provider) {
    if (provider.allSensorData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("No history data available"),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.allSensorData.length > 50
          ? 50
          : provider.allSensorData.length, // Limit to 50 for performance
      itemBuilder: (context, index) {
        final item = provider.allSensorData[index];
        final dateStr = item['timestamp'] as String?;
        final date = DateTime.tryParse(dateStr ?? '') ?? DateTime.now();
        final formattedDate = DateFormat('MMM d, HH:mm').format(date);
        final sensorType = item['sensorType'] ?? 'Unknown';
        final value = item['value'] ?? 0;
        final status = item['status'] ?? 'Normal';

        Color statusColor = Colors.green;
        if (status.toString().toLowerCase().contains('alert') ||
            status.toString().toLowerCase().contains('high') ||
            status.toString().toLowerCase().contains('low')) {
          statusColor = Colors.orange;
        }

        return Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withOpacity(0.1),
              child: Icon(
                _getIconForSensor(sensorType),
                color: Colors.green[800],
                size: 20,
              ),
            ),
            title: Text(
              "$sensorType: $value",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              formattedDate,
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForSensor(String type) {
    switch (type) {
      case 'Temperature':
        return Icons.thermostat;
      case 'Humidity':
        return Icons.water_drop;
      case 'Light Intensity':
        return Icons.wb_sunny;
      case 'Water Level':
        return Icons.waves;
      default:
        return Icons.sensors;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            title: const Text(
              'Analytics & History',
              style: TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            centerTitle: true,
            backgroundColor: Colors.green[700],
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Center(child: VoiceNavigationWidget()),
              ),
            ],
          ),
          drawer: const CustDrawer(),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Overview",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildSummaryCard(
                            "Avg Temp",
                            "${provider.avgTemp.toStringAsFixed(1)}°C",
                            Icons.thermostat,
                            Colors.red,
                          ),
                          _buildSummaryCard(
                            "Avg Hum",
                            "${provider.avgHumidity.toStringAsFixed(1)}%",
                            Icons.water_drop,
                            Colors.blue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildSummaryCard(
                            "Avg Light",
                            "${provider.avgLight.toStringAsFixed(0)} lx",
                            Icons.wb_sunny,
                            Colors.orange,
                          ),
                          _buildSummaryCard(
                            "Avg Water",
                            "${provider.avgWater.toStringAsFixed(0)}%",
                            Icons.waves,
                            Colors.cyan,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Trends",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          DropdownButton<String>(
                            value: provider.selectedChartSensor,
                            underline: Container(),
                            style: TextStyle(
                              color: Colors.green[800],
                              fontWeight: FontWeight.bold,
                            ),
                            items:
                                [
                                  'Temperature',
                                  'Humidity',
                                  'Light Intensity',
                                  'Water Level',
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                            onChanged: (newValue) {
                              if (newValue != null) {
                                provider.setSelectedChartSensor(newValue);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 250,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: LineChart(provider.sensorChartData),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "History Log",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildHistoryList(provider),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[800],
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _exportData(context, provider),
                          icon: const Icon(
                            Icons.file_download,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Export Data",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
