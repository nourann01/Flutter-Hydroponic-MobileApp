import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';

class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key});

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ControlPanelStateMgmt>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    void _openScheduleDialog(
      //lazem nshoof mmkn n7otaha feen gher el mkan dahh!!
      BuildContext context,
      ControlPanelStateMgmt viewModel,
      String selectedTaskType,
    ) {
      viewModel.setTaskType(selectedTaskType);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            content: ScheduleTaskWindow(
              taskTypes: const ["waterPump", "lights", "nutrientPump"],
              onTaskTypeChanged: viewModel.setTaskType,
              onIntensityChanged: viewModel.setScheduledIntensity,
              onIsOnChanged: viewModel.setScheduledIsOn,
              onTimePicked: viewModel.setScheduledTime,
              onSave: () async {
                await viewModel.saveScheduledTask();
                viewModel.resetScheduleInputs();
                Navigator.pop(context);
              },
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Control Panel',
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
      body: Consumer2<ControlPanelStateMgmt, DashboardStateMgmt>(
        //badal ma rebuild kolo hy rebuild bas lly et8yr
        builder: (context, viewModel, dashboardVM, child) {
          final isAutomatic = dashboardVM.isAutomatic;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isAutomatic)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock, color: Colors.orange[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "System is in Automatic Mode. Manual controls are disabled.",
                            style: TextStyle(
                              color: Colors.orange[900],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Control Panel',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Manual actuator control and scheduling',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 10),
                          Opacity(
                            opacity: isAutomatic ? 0.5 : 1.0,
                            child: IgnorePointer(
                              ignoring: isAutomatic,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  viewModel.emergencyStop();
                                },
                                icon: const Icon(Icons.warning_amber_rounded),
                                label: const Text('Emergency Stop'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[600],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Opacity(
                  opacity: isAutomatic ? 0.5 : 1.0,
                  child: IgnorePointer(
                    ignoring: isAutomatic,
                    child: Column(
                      children: [
                        ControlBox(
                          title: 'Water Pump',
                          icon: Icons.water_drop,
                          isOn: viewModel.waterPump.isOn,
                          intensity: viewModel.waterPump.intensity,
                          onPowerToggle: viewModel.toggleWaterPump,
                          onIntensityChanged: viewModel.setWaterPumpIntensity,
                        ),

                        const SizedBox(height: 16),
                        ControlBox(
                          title: 'Grow Lights',
                          icon: Icons.light_mode,
                          isOn: viewModel.lights.isOn,
                          intensity: viewModel.lights.intensity,
                          onPowerToggle: viewModel.toggleLights,
                          onIntensityChanged: viewModel.setLightsIntensity,
                        ),

                        const SizedBox(height: 16),
                        ControlBox(
                          title: 'Nutrient Pump',
                          icon: Icons.bolt,
                          isOn: viewModel.nutrientPump.isOn,
                          intensity: viewModel.nutrientPump.intensity,
                          onPowerToggle: viewModel.toggleNutrientPump,
                          onIntensityChanged:
                              viewModel.setNutrientPumpIntensity,
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _openScheduleDialog(
                                context,
                                viewModel,
                                "nutrientPump",
                              );
                            },
                            icon: const Icon(Icons.schedule_outlined),
                            label: const Text(
                              'Schedule',
                              style: TextStyle(
                                color: Color.fromARGB(255, 9, 110, 12),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.green),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Actuator History',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Wrap each actuator type in its own FutureBuilder
                      ...['waterPump', 'lights', 'nutrientPump'].map((type) {
                        return FutureBuilder<List<Actuator>>(
                          future: viewModel.getActuatorHistory(type),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Text('No history for $type');
                            }

                            final history = snapshot.data!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: history.map((actuator) {
                                return ListTile(
                                  leading: Icon(
                                    actuator.actuatorType == 'waterPump'
                                        ? Icons.water_drop
                                        : actuator.actuatorType == 'lights'
                                        ? Icons.light_mode
                                        : Icons.bolt,
                                    color: Colors.green[700],
                                  ),
                                  title: Text(
                                    '${actuator.actuatorType} - ${actuator.isOn ? "ON" : "OFF"}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Intensity: ${(actuator.intensity * 100).round()}%',
                                  ),
                                  trailing: Text(
                                    actuator.timestamp,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
