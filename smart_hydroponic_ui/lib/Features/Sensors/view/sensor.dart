import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';

class SensorMonitoringPage extends StatelessWidget {
  const SensorMonitoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Sensors', style: TextStyle(color: Colors.white)),
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
      body: Consumer<SensorStateMgmt>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading && viewModel.sensors.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null && viewModel.sensors.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${viewModel.errorMessage}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final sensors = viewModel.sensors;

          if (sensors.isEmpty) {
            return const Center(child: Text("No sensor data available."));
          }

          // Show all sensors
          final filteredSensors = sensors;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sensor Monitoring',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Live environmental data from your hydroponic system.',
                  style: TextStyle(color: Colors.black54, fontSize: 15),
                ),
                const SizedBox(height: 24),

                // Show Temperature and Humidity only
                ...filteredSensors.map((sensor) {
                  return Column(
                    children: [
                      SensorCard(
                        icon: _getSensorIcon(sensor.sensorType),
                        title: sensor.sensorType,
                        value: _formatSensorValue(sensor, viewModel),
                        color: _getSensorColor(sensor.sensorType),
                        history: viewModel.history[sensor.sensorType],
                      ),
                      const SizedBox(height: 8),
                      SensorCalibrationWidget(sensorType: sensor.sensorType),
                    ],
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getSensorIcon(String type) {
    switch (type) {
      case 'Temperature':
        return Icons.thermostat;
      case 'Humidity':
        return Icons.water_drop;
      case 'Water Level':
        return Icons.opacity;
      case 'Light Intensity':
        return Icons.light_mode;
      default:
        return Icons.device_unknown;
    }
  }

  Color _getSensorColor(String type) {
    switch (type) {
      case 'Temperature':
        return Colors.orange;
      case 'Humidity':
        return Colors.blue;
      case 'Water Level':
        return Colors.lightBlue;
      case 'Light Intensity':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  String _formatSensorValue(Sensor sensor, SensorStateMgmt vm) {
    final offset = vm.getCalibration(sensor.sensorType);
    final calibratedValue = sensor.value + offset;

    switch (sensor.sensorType) {
      case 'Temperature':
        return '${calibratedValue.toStringAsFixed(1)}°C';
      case 'Humidity':
        return '${calibratedValue.toStringAsFixed(1)}%';
      case 'Water Level':
        return '${calibratedValue.toStringAsFixed(1)}%';
      case 'Light Intensity':
        return '${calibratedValue.toStringAsFixed(1)} lx';
      default:
        return calibratedValue.toStringAsFixed(1);
    }
  }
}
