import 'core/constants/app_imports.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('Starting app initialization...');

  // Firebase Initialization
  try {
    print('Initializing Firebase...');
    await FirebaseService.initialize();
    print('Firebase initialized.');
  } catch (e) {
    print('Firebase initialization failed: $e');
  }

  // SQLite Initialization
  print('Initializing SQLite...');
  await SqliteService.instance.database;
  print('SQLite initialized.');

  // Scheduler Initialization
  print('Initializing Scheduler...');
  SchedulerService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(
          create: (_) => ControlPanelStateMgmt(
            repository: ControlPanelRepository(
              sqliteService: SqliteService.instance,
              firebaseService: FirebaseService(),
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SensorStateMgmt(
            repository: SensorRepository(
              firebaseService: FirebaseService(),
              sqliteService: SqliteService.instance,
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsStateMgmt(
            repository: ThresholdRepository(firebaseService: FirebaseService()),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => DashboardStateMgmt(
            sensorStateMgmt: Provider.of<SensorStateMgmt>(
              context,
              listen: false,
            ),
            settingsStateMgmt: Provider.of<SettingsStateMgmt>(
              context,
              listen: false,
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => AlertsStateMgmt(
            repository: AlertsRepository(
              sqliteService: SqliteService.instance,
              sensorStateMgmt: Provider.of<SensorStateMgmt>(
                context,
                listen: false,
              ),
            ),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SMART Hydroponic',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreenWrapper(),
      routes: {
        '/dashboard': (context) => const Dashboard(),
        '/control-panel': (context) => const ControlPanel(),
        '/sensors': (context) => const SensorMonitoringPage(),
        '/alerts': (context) => const Alerts(),
        '/analytics': (context) => const AnalyticsHistoryScreen(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}

/// SplashScreenWrapper shows splash then navigates to AuthWrapper
class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();

    // Show splash for 3 seconds then navigate to auth
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthWrapper()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}

/// AuthWrapper handles safe loading of the current user
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    // Initialize AuthViewModel after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      await authViewModel.initializeUser();
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final authViewModel = Provider.of<AuthViewModel>(context);

    return authViewModel.currentUser != null
        ? const Dashboard()
        : SystemForms(); // Login / Registration page
  }
}
