import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';

class SensorCalibrationWidget extends StatefulWidget {
  final String sensorType; // which sensor this is for
  final double currentValue; // optional: display current reading

  const SensorCalibrationWidget({
    super.key,
    required this.sensorType,
    this.currentValue = 0.0,
  });

  @override
  State<SensorCalibrationWidget> createState() =>
      _SensorCalibrationWidgetState();
}

class _SensorCalibrationWidgetState extends State<SensorCalibrationWidget> {
  late TextEditingController _offsetController;

  @override
  void initState() {
    super.initState();
    final sensorVM = Provider.of<SensorStateMgmt>(context, listen: false);
    final currentOffset = sensorVM.getCalibration(widget.sensorType);
    _offsetController = TextEditingController(text: currentOffset.toString());
  }

  @override
  void dispose() {
    _offsetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sensorVM = Provider.of<SensorStateMgmt>(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.sensorType,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (widget.currentValue != 0.0)
              Text("Current value: ${widget.currentValue}"),
            const SizedBox(height: 8),
            TextField(
              controller: _offsetController,
              decoration: const InputDecoration(
                labelText: "Calibration Offset",
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final offset = double.tryParse(_offsetController.text) ?? 0.0;
                sensorVM.setCalibration(
                  SensorCalibration(
                    sensorType: widget.sensorType,
                    offset: offset,
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Calibration applied")),
                );
              },
              child: const Text("Calibrate"),
            ),
          ],
        ),
      ),
    );
  }
}
