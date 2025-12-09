import 'package:fl_chart/fl_chart.dart';
import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';

class AnalyticsProvider extends ChangeNotifier {
  final SqliteService _sqliteService;

  AnalyticsProvider({SqliteService? sqliteService})
    : _sqliteService = sqliteService ?? SqliteService.instance;

  bool _isLoading = true;
  String _selectedChartSensor = 'Temperature';

  List<Map<String, dynamic>> _allSensorData = [];
  List<Map<String, dynamic>> _tempData = [];
  List<Map<String, dynamic>> _humidityData = [];
  List<Map<String, dynamic>> _lightData = [];
  List<Map<String, dynamic>> _waterData = [];

  double _avgTemp = 0.0;
  double _avgHumidity = 0.0;
  double _avgLight = 0.0;
  double _avgWater = 0.0;

  bool get isLoading => _isLoading;
  String get selectedChartSensor => _selectedChartSensor;

  double get avgTemp => _avgTemp;
  double get avgHumidity => _avgHumidity;
  double get avgLight => _avgLight;
  double get avgWater => _avgWater;

  List<Map<String, dynamic>> get allSensorData => _allSensorData;
  List<Map<String, dynamic>> get tempData => _tempData;
  List<Map<String, dynamic>> get humidityData => _humidityData;
  List<Map<String, dynamic>> get lightData => _lightData;
  List<Map<String, dynamic>> get waterData => _waterData;

  void setSelectedChartSensor(String sensor) {
    _selectedChartSensor = sensor;
    notifyListeners();
  }

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();

    final temp = await _sqliteService.getSensorData('Temperature');
    final humidity = await _sqliteService.getSensorData('Humidity');
    final light = await _sqliteService.getSensorData('Light Intensity');
    final water = await _sqliteService.getSensorData('Water Level');

    _avgTemp = _calculateAverage(temp);
    _avgHumidity = _calculateAverage(humidity);
    _avgLight = _calculateAverage(light);
    _avgWater = _calculateAverage(water);

    List<Map<String, dynamic>> combined = [
      ...temp,
      ...humidity,
      ...light,
      ...water,
    ];
    combined.sort((a, b) {
      final t1 = DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime(1970);
      final t2 = DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime(1970);
      return t2.compareTo(t1);
    });

    _tempData = temp;
    _humidityData = humidity;
    _lightData = light;
    _waterData = water;
    _allSensorData = combined;

    _isLoading = false;
    notifyListeners();
  }

  double _calculateAverage(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 0.0;
    double sum = 0;
    for (var item in data) {
      sum += (item['value'] as num).toDouble();
    }
    return sum / data.length;
  }

  // Returns the appropriate chart data for the selected sensor
  LineChartData get sensorChartData {
    List<Map<String, dynamic>> targetData;
    Color chartColor;

    switch (_selectedChartSensor) {
      case 'Temperature':
        targetData = _tempData;
        chartColor = Colors.red;
        break;
      case 'Humidity':
        targetData = _humidityData;
        chartColor = Colors.blue;
        break;
      case 'Light Intensity':
        targetData = _lightData;
        chartColor = Colors.orange;
        break;
      case 'Water Level':
        targetData = _waterData;
        chartColor = Colors.cyan;
        break;
      default:
        targetData = _tempData;
        chartColor = Colors.green;
    }

    final sortedData = List<Map<String, dynamic>>.from(targetData)
      ..sort((a, b) {
        final t1 = DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime(1970);
        final t2 = DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime(1970);
        return t1.compareTo(t2);
      });

    List<FlSpot> spots = [];
    for (int i = 0; i < sortedData.length; i++) {
      spots.add(
        FlSpot(i.toDouble(), (sortedData[i]['value'] as num).toDouble()),
      );
    }

    if (spots.isEmpty) spots.add(const FlSpot(0, 0));

    return LineChartData(
      gridData: const FlGridData(show: true, drawVerticalLine: false),
      titlesData: FlTitlesData(
        bottomTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, _) => Text(
              value.toStringAsFixed(1),
              style: const TextStyle(fontSize: 10, color: Colors.black54),
            ),
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          color: chartColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: chartColor.withOpacity(0.1),
          ),
          spots: spots,
        ),
      ],
    );
  }
}
