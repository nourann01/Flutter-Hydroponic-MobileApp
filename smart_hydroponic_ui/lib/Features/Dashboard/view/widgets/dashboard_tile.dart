import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';

class DashboardTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String status;
  final double currentValue;
  final String symbol;

  const DashboardTile({
    required this.title,
    required this.icon,
    required this.status,
    required this.currentValue,
    required this.symbol,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Determine status color and icon based on status string
    final bool isNormal =
        status.toLowerCase() == 'normal' || status.toLowerCase() == 'ok';
    final bool isWarning = status.toLowerCase() == 'warning';
    // Default to danger if not normal or warning

    final Color statusColor = isNormal
        ? Colors.green
        : isWarning
        ? Colors.orange
        : Colors.red;

    final Color statusBgColor = isNormal
        ? Colors.green.shade50
        : isWarning
        ? Colors.orange.shade50
        : Colors.red.shade50;

    final IconData statusIcon = isNormal
        ? Icons.check_circle_outline
        : isWarning
        ? Icons.warning_amber_rounded
        : Icons.error_outline;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: icon + title + ON/OFF badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(icon, color: Colors.green[700]),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "${currentValue.toStringAsFixed(2)} $symbol",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
              child: OutlinedButton.icon(
                onPressed: () {},
                label: Text(status),
                icon: Icon(statusIcon, size: 14),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(
                    10,
                    20,
                  ), // ← removes min height constraint (default is 36)
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  foregroundColor: Colors.white,
                  backgroundColor: statusColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: const BorderSide(color: Colors.transparent),
                  textStyle: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardTileSystem extends StatelessWidget {
  const DashboardTileSystem({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardStateMgmt>(
      builder: (context, dashboardVM, child) {
        final isAutomatic = dashboardVM.isAutomatic;

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: Colors.black12,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "System Mode",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isAutomatic
                            ? Colors.green.shade50
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isAutomatic
                              ? Colors.green.withOpacity(0.3)
                              : Colors.blue.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isAutomatic
                                ? Icons.smart_toy_outlined
                                : Icons.touch_app_outlined,
                            size: 16,
                            color: isAutomatic
                                ? Colors.green[700]
                                : Colors.blue[700],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isAutomatic ? "Automatic" : "Manual",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isAutomatic
                                  ? Colors.green[700]
                                  : Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Toggle Buttons
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildModeButton(
                          label: "Manual",
                          icon: Icons.touch_app,
                          isSelected: !isAutomatic,
                          onTap: () => dashboardVM.toggleSystemMode(false),
                          activeColor: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _buildModeButton(
                          label: "Automatic",
                          icon: Icons.smart_toy,
                          isSelected: isAutomatic,
                          onTap: () => dashboardVM.toggleSystemMode(true),
                          activeColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required MaterialColor activeColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? activeColor[700] : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? activeColor[700] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardTileControls extends StatelessWidget {
  const DashboardTileControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ControlPanelStateMgmt, DashboardStateMgmt>(
      builder: (context, controlVM, dashboardVM, child) {
        final isAutomatic = dashboardVM.isAutomatic;

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: icon + title + ON/OFF badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Quick Controls",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isAutomatic)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.lock, size: 12, color: Colors.orange),
                            SizedBox(width: 4),
                            Text(
                              "AUTO MODE",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Opacity(
                  opacity: isAutomatic ? 0.5 : 1.0,
                  child: IgnorePointer(
                    ignoring: isAutomatic,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  controlVM.toggleWaterPump();
                                },
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  side: BorderSide(
                                    color: controlVM.waterPump.isOn
                                        ? Colors.green[700]!
                                        : Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                  foregroundColor: controlVM.waterPump.isOn
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                  backgroundColor: controlVM.waterPump.isOn
                                      ? Colors.green[600]
                                      : Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                label: Text(
                                  controlVM.waterPump.isOn
                                      ? "Water Pump ON"
                                      : "Water Pump",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                icon: const Icon(Icons.water_drop),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  controlVM.toggleLights();
                                },
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  side: BorderSide(
                                    color: controlVM.lights.isOn
                                        ? Colors.green[700]!
                                        : Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                  foregroundColor: controlVM.lights.isOn
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                  backgroundColor: controlVM.lights.isOn
                                      ? Colors.green[600]
                                      : Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                label: Text(
                                  controlVM.lights.isOn
                                      ? "Grow Lights ON"
                                      : "Grow Lights",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                icon: const Icon(Icons.wb_sunny),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // Map Fan to Nutrient Pump as requested
                                  controlVM.toggleNutrientPump();
                                },
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  side: BorderSide(
                                    color: controlVM.nutrientPump.isOn
                                        ? Colors.green[700]!
                                        : Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                  foregroundColor: controlVM.nutrientPump.isOn
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                  backgroundColor: controlVM.nutrientPump.isOn
                                      ? Colors.green[600]
                                      : Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                label: Text(
                                  controlVM.nutrientPump.isOn
                                      ? "Fan ON"
                                      : "Fan",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                icon: const Icon(Icons.air),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Emergency Stop - Always enabled for safety
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          controlVM.emergencyStop();
                          // Switch to manual mode after emergency stop
                          dashboardVM.toggleSystemMode(false);
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(color: Colors.red[700]!, width: 1.5),
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red[600],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        label: const Text(
                          "Emergency Stop",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        icon: const Icon(Icons.emergency),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
