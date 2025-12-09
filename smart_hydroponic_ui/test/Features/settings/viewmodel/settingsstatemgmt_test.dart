import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';

import '../../../helpers/test_helpers.mocks.dart';

void main() {
  late SettingsStateMgmt settings;
  late MockThresholdRepository mockRepo;

  setUp(() {
    mockRepo = MockThresholdRepository();
    settings = SettingsStateMgmt(repository: mockRepo);
  });

  test('loads default thresholds on initialization', () {
    expect(settings.thresholds.length, 4);

    expect(settings.thresholds[0].sensorType, "temperature");
    expect(settings.thresholds[1].sensorType, "humidity");
    expect(settings.thresholds[2].sensorType, "waterLevel");
    expect(settings.thresholds[3].sensorType, "lightIntensity");

    for (var t in settings.thresholds) {
      expect(t.minValue, 0);
      expect(t.maxValue, 100);
    }
  });

  test('updateThreshold calls repository and updates list', () async {
    final updated = SensorThreshold(
      sensorType: "temperature",
      minValue: 10,
      maxValue: 50,
    );

    when(mockRepo.saveThreshold(any)).thenAnswer((_) async => null);

    // Track notification triggers
    var notified = false;
    settings.addListener(() {
      notified = true;
    });

    await settings.updateThreshold(updated);

    // Verify repository interaction
    verify(mockRepo.saveThreshold(updated)).called(1);

    // Verify threshold updated
    final match = settings.thresholds.firstWhere(
      (t) => t.sensorType == "temperature",
    );

    expect(match.minValue, 10);
    expect(match.maxValue, 50);

    // Verify notifyListeners() called
    expect(notified, true);
  });

  test('updateThreshold does NOT crash when sensor not found', () async {
    final newType = SensorThreshold(
      sensorType: "unknownSensor",
      minValue: 5,
      maxValue: 15,
    );

    when(mockRepo.saveThreshold(any)).thenAnswer((_) async => null);

    // Should not throw even though the sensorType isn't in the list
    await settings.updateThreshold(newType);

    // It should call saveThreshold even if not found
    verify(mockRepo.saveThreshold(newType)).called(1);

    // List should NOT change
    expect(settings.thresholds.length, 4);
  });
}
