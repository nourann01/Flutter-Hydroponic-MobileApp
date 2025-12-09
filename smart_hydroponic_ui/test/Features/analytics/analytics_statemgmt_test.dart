import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';
import '../../helpers/test_helpers.mocks.dart'; // adjust path

void main() {
  late AnalyticsProvider analyticsProvider;
  late MockSqliteService mockSqliteService;

  setUp(() {
    mockSqliteService = MockSqliteService();
    analyticsProvider = AnalyticsProvider(sqliteService: mockSqliteService);
  });

  test('initial state', () {
    expect(analyticsProvider.isLoading, true);
    expect(analyticsProvider.selectedChartSensor, 'Temperature');
    expect(analyticsProvider.avgTemp, 0.0);
    expect(analyticsProvider.allSensorData, []);
  });

  test('fetchData loads sensor data and calculates averages', () async {
    final tempData = [
      {'value': 25.0, 'timestamp': '2025-12-08T10:00:00'},
      {'value': 27.0, 'timestamp': '2025-12-08T11:00:00'},
    ];
    final humidityData = [
      {'value': 50.0, 'timestamp': '2025-12-08T10:00:00'},
      {'value': 55.0, 'timestamp': '2025-12-08T11:00:00'},
    ];
    final lightData = [
      {'value': 300.0, 'timestamp': '2025-12-08T10:00:00'},
    ];
    final waterData = [
      {'value': 80.0, 'timestamp': '2025-12-08T10:00:00'},
    ];

    // Stub all sensor calls
    when(
      mockSqliteService.getSensorData('Temperature'),
    ).thenAnswer((_) async => tempData);
    when(
      mockSqliteService.getSensorData('Humidity'),
    ).thenAnswer((_) async => humidityData);
    when(
      mockSqliteService.getSensorData('Light Intensity'),
    ).thenAnswer((_) async => lightData);
    when(
      mockSqliteService.getSensorData('Water Level'),
    ).thenAnswer((_) async => waterData);

    await analyticsProvider.fetchData();

    expect(analyticsProvider.avgTemp, (25.0 + 27.0) / 2);
    expect(analyticsProvider.avgHumidity, (50.0 + 55.0) / 2);
    expect(analyticsProvider.avgLight, 300.0);
    expect(analyticsProvider.avgWater, 80.0);

    expect(analyticsProvider.tempData, tempData);
    expect(analyticsProvider.humidityData, humidityData);
    expect(analyticsProvider.lightData, lightData);
    expect(analyticsProvider.waterData, waterData);

    expect(
      analyticsProvider.allSensorData.first['timestamp'],
      '2025-12-08T11:00:00',
    );
    expect(analyticsProvider.isLoading, false);
  });

  test('setSelectedChartSensor updates sensor', () {
    analyticsProvider.setSelectedChartSensor('Humidity');
    expect(analyticsProvider.selectedChartSensor, 'Humidity');
  });

  test('sensorChartData returns LineChartData with correct spots', () async {
    final tempData = [
      {'value': 25.0, 'timestamp': '2025-12-08T10:00:00'},
      {'value': 27.0, 'timestamp': '2025-12-08T11:00:00'},
    ];
    final humidityData = [
      {'value': 50.0, 'timestamp': '2025-12-08T10:00:00'},
    ];
    final lightData = [
      {'value': 300.0, 'timestamp': '2025-12-08T10:00:00'},
    ];
    final waterData = [
      {'value': 80.0, 'timestamp': '2025-12-08T10:00:00'},
    ];

    // Stub all sensor calls
    when(
      mockSqliteService.getSensorData('Temperature'),
    ).thenAnswer((_) async => tempData);
    when(
      mockSqliteService.getSensorData('Humidity'),
    ).thenAnswer((_) async => humidityData);
    when(
      mockSqliteService.getSensorData('Light Intensity'),
    ).thenAnswer((_) async => lightData);
    when(
      mockSqliteService.getSensorData('Water Level'),
    ).thenAnswer((_) async => waterData);

    await analyticsProvider.fetchData();

    final chartData = analyticsProvider.sensorChartData;

    expect(chartData.lineBarsData.first.spots.length, tempData.length);
    expect(chartData.lineBarsData.first.color, isNotNull);
  });
}
