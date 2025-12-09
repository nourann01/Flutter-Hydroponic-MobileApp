import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_hydroponic_ui/core/services/firebase_service.dart';
import 'package:smart_hydroponic_ui/core/services/sqlite_service.dart';
import 'package:smart_hydroponic_ui/Features/ControlPanel/model/schedules_model.dart';
import 'package:smart_hydroponic_ui/Features/ControlPanel/model/actuator_model.dart';

class SchedulerService {
  static final SchedulerService _instance = SchedulerService._internal();
  factory SchedulerService() => _instance;
  SchedulerService._internal();

  Timer? _timer;
  final SqliteService _sqliteService = SqliteService.instance;
  final FirebaseService _firebaseService = FirebaseService();

  // Start the scheduler
  void init() {
    // Check every 30 seconds
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkSchedules();
    });
    print("SchedulerService started.");
  }

  // Stop if needed
  void dispose() {
    _timer?.cancel();
  }

  Future<void> _checkSchedules() async {
    try {
      // get pending tasks
      final List<Map<String, dynamic>> pendingTasksData = await _sqliteService
          .getScheduledTasks('pending');

      if (pendingTasksData.isEmpty) return;

      final now = TimeOfDay.now();
      final currentMinutes = now.hour * 60 + now.minute;

      for (var taskMap in pendingTasksData) {
        final task = ScheduledTask.fromMap(taskMap);

        // Parse stored time "HH:mm"
        if (task.scheduledTime.isEmpty) continue;
        final parts = task.scheduledTime.split(":");
        final taskHour = int.parse(parts[0]);
        final taskMinute = int.parse(parts[1]);
        final taskMinutes = taskHour * 60 + taskMinute;
        if (currentMinutes >= taskMinutes) {
          await _executeTask(task);
        }
      }
    } catch (e) {
      print("SchedulerService Error: $e");
    }
  }

  Future<void> _executeTask(ScheduledTask task) async {
    print(
      "Executing scheduled task: ${task.taskType} at ${task.scheduledTime}",
    );

    try {
      // Use schedule model
      double intensity = task.intensity ?? 1.0;
      bool isOn = task.isOn ?? true;

      final actuator = Actuator(
        actuatorType: task.taskType,
        intensity: intensity,
        isOn: isOn,
        timestamp: DateTime.now().toIso8601String(),
      );

      //Send to Firebase
      final data = {
        'actuatorType': actuator.actuatorType,
        'isOn': actuator.isOn,
        'intensity': actuator.intensity,
        'timestamp': actuator.timestamp,
      };
      await _firebaseService.writeActuatorData(data);

      //Log to SQLite History for gui updates
      await _sqliteService.insertActuatorLog(actuator.toMap());

      // update status
      if (task.id != null) {
        await _sqliteService.updateScheduledTaskStatus(task.id!, 'completed');
        print("Task ${task.id} executed and logged to history.");
      }
    } catch (e) {
      print("Failed to execute task ${task.id}: $e");
    }
  }
}
