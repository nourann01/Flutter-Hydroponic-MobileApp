import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqliteService {
  // Singleton instance
  static final SqliteService instance = SqliteService._init();
  static Database? _database;

  SqliteService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('hydroponics.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }
  


  Future _createDB(Database db, int version) async {
  // ACTUATORS
  await db.execute('''
    CREATE TABLE actuators (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      actuatorType TEXT,
      status INTEGER,
      intensity REAL,
      timestamp TEXT
    )
  ''');

  // SENSORS
  await db.execute('''
    CREATE TABLE sensors (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      sensorType TEXT,
      value REAL,
      status TEXT,
      timestamp TEXT
    )
  ''');

  // ALERTS (NEW SCHEMA)
  await db.execute('''
    CREATE TABLE alerts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      sensorType TEXT,
      previousStatus TEXT,
      currentStatus TEXT,
      sensorValue REAL,
      message TEXT,
      timestamp TEXT,
      isRead INTEGER DEFAULT 0
    )
  ''');

  // SCHEDULED TASKS
  await db.execute('''
    CREATE TABLE scheduled_tasks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      taskType TEXT,
      parameters TEXT,
      scheduledTime TEXT,
      status TEXT,
      intensity REAL,
      isOn INTEGER
    )
  ''');

  // SYSTEM SETTINGS
  await db.execute('''
    CREATE TABLE system_settings (
      key TEXT PRIMARY KEY,
      value TEXT
    )
  ''');

  // USERS
  await db.execute('''
    CREATE TABLE users (
      uid TEXT PRIMARY KEY,
      fullName TEXT,
      phoneNumber TEXT
    )
  ''');
}



  //actuator methods
  Future<void> insertActuatorLog(Map<String, dynamic> actuatorMap) async {
    final db = await database;
    await db.insert('actuators', actuatorMap);
  }

  Future<List<Map<String, dynamic>>> getActuatorLogs(
    String actuatorType,
  ) async {
    final db = await database;
    return await db.query(
      'actuators',
      where: 'actuatorType = ?',
      whereArgs: [actuatorType],
      orderBy: 'timestamp DESC',
    );
  }


  //sensor methods
  Future<void> insertSensorData(Map<String, dynamic> sensorMap) async {
    final db = await database;
    await db.insert('sensors', sensorMap);
  }

  Future<List<Map<String, dynamic>>> getSensorData(String sensorType) async {
    final db = await database;
    return await db.query(
      'sensors',
      where: 'sensorType = ?',
      whereArgs: [sensorType],
      orderBy: 'timestamp DESC',
    );
  }

  //alert methods
  Future<void> insertAlert(Map<String, dynamic> alertMap) async {
    final db = await database;
    await db.insert('alerts', alertMap);
  }

  Future<List<Map<String, dynamic>>> getAlerts(String severity) async {
    final db = await database;
    return await db.query(
      'alerts',
      where: 'severity = ?',
      whereArgs: [severity],
      orderBy: 'timestamp DESC',
    );
  }

  //scheduled task methods
  Future<void> insertScheduledTask(Map<String, dynamic> taskMap) async {
    final db = await database;
    await db.insert('scheduled_tasks', taskMap);
  }

  Future<List<Map<String, dynamic>>> getScheduledTasks(String status) async {
    final db = await database;
    return await db.query(
      'scheduled_tasks',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'scheduledTime ASC',
    );
  }

  Future<void> updateScheduledTaskStatus(int id, String status) async {
    final db = await database;
    await db.update(
      'scheduled_tasks',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  //user methods
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users', orderBy: 'fullName ASC');
  }

  Future<Map<String, dynamic>?> getUserByUid(String uid) async {
    final db = await database;
    final result = await db.query('users', where: 'uid = ?', whereArgs: [uid]);
    if (result.isEmpty) return null;
    return result.first;
  }


  // System Settings Methods
Future<void> setSystemSetting(String key, String value) async {
  final db = await database;

  await db.insert(
    'system_settings',
    {'key': key, 'value': value},
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<String?> getSystemSetting(String key) async {
  final db = await database;

  final result = await db.query(
    'system_settings',
    where: 'key = ?',
    whereArgs: [key],
  );

  if (result.isNotEmpty) {
    return result.first['value'] as String?;
  }
  return null;
}

}
