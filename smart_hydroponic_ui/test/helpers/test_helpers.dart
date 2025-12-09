import 'package:mockito/annotations.dart';
import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';
import 'package:sqflite/sqflite.dart';

@GenerateMocks([
  FirebaseService,
  SqliteService,
  SchedulerService,
  AuthService,
  SensorRepository,
  ControlPanelRepository,
  ThresholdRepository,
  AlertsRepository,
  SettingsStateMgmt,
  SensorStateMgmt,
  DatabaseEvent,
  DataSnapshot,
  Database,
])
void main() {}
