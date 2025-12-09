import 'package:flutter/material.dart';

class ControlBox extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isOn;
  final double intensity;
  final VoidCallback onPowerToggle;
  final ValueChanged<double> onIntensityChanged;

  const ControlBox({
    required this.title,
    required this.icon,
    required this.isOn,
    required this.intensity,
    required this.onPowerToggle,
    required this.onIntensityChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(icon, color: Colors.green[700]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isOn ? Colors.green[600] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isOn ? 'ON' : 'OFF',
                    style: TextStyle(
                      color: isOn ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Power',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Switch(
                  value: isOn,
                  onChanged: (bool value) => onPowerToggle(),
                  activeColor: Colors.white,
                  activeTrackColor: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Intensity',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text('${(intensity * 100).round()}%'),
              ],
            ),
            const SizedBox(height: 4),
            Slider(
              value: intensity,
              onChanged: onIntensityChanged,
              activeColor: Colors.green[600],
              inactiveColor: Colors.grey[300],
              min: 0.0,
              max: 1.0,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
