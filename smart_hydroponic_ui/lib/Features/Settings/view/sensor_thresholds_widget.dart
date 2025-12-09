import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';

class SensorThresholdsWidget extends StatelessWidget {
  const SensorThresholdsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsStateMgmt>(
      builder: (context, settingsVM, child) {
        final thresholds = settingsVM.thresholds;

        if (thresholds.isEmpty) {
          // show defaults so user can set initial values
          final defaultSensors = [
            SensorThreshold(
              sensorType: 'Temperature',
              minValue: 0,
              maxValue: 100,
            ),
            SensorThreshold(sensorType: 'Humidity', minValue: 0, maxValue: 100),
            SensorThreshold(
              sensorType: 'Water Level',
              minValue: 0,
              maxValue: 100,
            ),
            SensorThreshold(
              sensorType: 'Light Intensity',
              minValue: 0,
              maxValue: 100,
            ),
          ];
          return _buildList(context, settingsVM, defaultSensors);
        }

        return _buildList(context, settingsVM, thresholds);
      },
    );
  }

  Widget _buildList(
    BuildContext context,
    SettingsStateMgmt vm,
    List<SensorThreshold> list,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Sensor Thresholds",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...list.map((t) => _thresholdCard(context, vm, t)).toList(),
      ],
    );
  }

  Widget _thresholdCard(
    BuildContext context,
    SettingsStateMgmt vm,
    SensorThreshold t,
  ) {
    final minController = TextEditingController(text: t.minValue.toString());
    final maxController = TextEditingController(text: t.maxValue.toString());

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.sensorType,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: minController,
                    decoration: const InputDecoration(
                      labelText: "Min",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: maxController,
                    decoration: const InputDecoration(
                      labelText: "Max",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Save"),
                onPressed: () async {
                  final min = double.tryParse(minController.text);
                  final max = double.tryParse(maxController.text);

                  if (min == null || max == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter valid numbers"),
                      ),
                    );
                    return;
                  }

                  final updated = SensorThreshold(
                    sensorType: t.sensorType,
                    minValue: min,
                    maxValue: max,
                  );

                  try {
                    await vm.updateThreshold(updated); // <-- correct call
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${t.sensorType} threshold saved"),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Failed to save ${t.sensorType}: $e"),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
