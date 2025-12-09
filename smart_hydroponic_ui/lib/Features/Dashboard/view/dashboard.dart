import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';
export 'package:smart_hydroponic_ui/voice_navigation_widget.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SMART Hydroponic System',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        actions: [
          // Voice Navigation Widget
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Center(child: VoiceNavigationWidget()),
          ),
        ],
      ),
      drawer: const CustDrawer(),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Real-time System Overview',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Consumer<DashboardStateMgmt>(
                        builder: (context, viewModel, child) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              right: 8.0,
                              bottom: 8.0,
                            ),
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              label: Text(
                                viewModel.isOnline
                                    ? 'System Online'
                                    : 'System Offline',
                              ),
                              icon: Icon(
                                viewModel.isOnline
                                    ? Icons.power_settings_new
                                    : Icons.power_off,
                                size: 12,
                              ),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(10, 20),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                shape: const StadiumBorder(),
                                side: BorderSide(
                                  color: viewModel.isOnline
                                      ? Colors.green
                                      : Colors.red,
                                  width: 1.5,
                                ),
                                foregroundColor: viewModel.isOnline
                                    ? Colors.green[700]
                                    : Colors.red[700],
                                backgroundColor: viewModel.isOnline
                                    ? Colors.green[50]
                                    : Colors.red[50],
                                textStyle: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                elevation: 0,
                              ),
                            ),
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Ink(
                              decoration: ShapeDecoration(
                                color: Colors.grey[200],
                                shape: const CircleBorder(),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.settings),
                                color: Colors.black,
                                onPressed: () {
                                  Navigator.pushNamed(context, '/settings');
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Ink(
                              decoration: ShapeDecoration(
                                color: Colors.grey[200],
                                shape: const CircleBorder(),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.notifications),
                                color: Colors.black,
                                onPressed: () {
                                  Navigator.pushNamed(context, '/alerts');
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Consumer2<DashboardStateMgmt, SensorStateMgmt>(
              builder: (context, dashboardVM, sensorVM, child) {
                final tempData =
                    dashboardVM.getSensorDataForTile('Temperature') ??
                    {'value': 0.0, 'symbol': '°C', 'status': 'Normal'};
                final humidityData =
                    dashboardVM.getSensorDataForTile('Humidity') ??
                    {'value': 0.0, 'symbol': '%', 'status': 'Normal'};
                final lightData =
                    dashboardVM.getSensorDataForTile('Light Intensity') ??
                    {'value': 0.0, 'symbol': 'Lux', 'status': 'Normal'};
                final waterData =
                    dashboardVM.getSensorDataForTile('Water Level') ??
                    {'value': 0.0, 'symbol': '%', 'status': 'Normal'};

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DashboardTile(
                            title: 'Temperature',
                            icon: Icons.thermostat_outlined,
                            status: tempData['status'] as String,
                            currentValue: tempData['value'] as double,
                            symbol: tempData['symbol'] as String,
                          ),
                        ),
                        Expanded(
                          child: DashboardTile(
                            title: 'Humidity',
                            icon: Icons.water_drop_outlined,
                            status: humidityData['status'] as String,
                            currentValue: humidityData['value'] as double,
                            symbol: humidityData['symbol'] as String,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: DashboardTile(
                            title: 'Light Intensity',
                            icon: Icons.light_mode_outlined,
                            status: lightData['status'] as String,
                            currentValue: lightData['value'] as double,
                            symbol: lightData['symbol'] as String,
                          ),
                        ),
                        Expanded(
                          child: DashboardTile(
                            title: 'Water Level',
                            icon: Icons.opacity,
                            status: waterData['status'] as String,
                            currentValue: waterData['value'] as double,
                            symbol: waterData['symbol'] as String,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 5),
            DashboardTileSystem(),
            SizedBox(height: 5),
            DashboardTileControls(),
          ],
        ),
      ),
    );
  }
}
