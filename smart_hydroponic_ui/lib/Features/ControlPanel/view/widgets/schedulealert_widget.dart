import 'package:flutter/material.dart';

class ScheduleTaskWindow extends StatefulWidget {
  final List<String> taskTypes;

  final void Function(String taskType) onTaskTypeChanged;
  final void Function(double intensity) onIntensityChanged;
  final void Function(bool isOn) onIsOnChanged;
  final void Function(TimeOfDay time) onTimePicked;
  final VoidCallback onSave;

  const ScheduleTaskWindow({
    super.key,
    required this.taskTypes,
    required this.onTaskTypeChanged,
    required this.onIntensityChanged,
    required this.onIsOnChanged,
    required this.onTimePicked,
    required this.onSave,
  });

  @override
  State<ScheduleTaskWindow> createState() => _ScheduleTaskWindowState();
}

class _ScheduleTaskWindowState extends State<ScheduleTaskWindow> {
  String? selectedTask;
  double intensity = 1.0;
  bool isOn = true;
  TimeOfDay? selectedTime;

  void resetLocalInputs() {
    setState(() {
      selectedTask = null;
      intensity = 1.0;
      isOn = true;
      selectedTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Schedule a Task",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          // Task Type
          const Text("Task Type", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            hint: const Text("Choose Task"),
            value: selectedTask,
            items: widget.taskTypes.map((task) {
              return DropdownMenuItem(value: task, child: Text(task));
            }).toList(),
            onChanged: (value) {
              setState(() => selectedTask = value);
              widget.onTaskTypeChanged(value!);
            },
          ),

          const SizedBox(height: 20),

          // On/Off Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Turn On/Off", style: TextStyle(fontWeight: FontWeight.bold)),
              Switch(
                value: isOn,
                onChanged: (value) {
                  setState(() => isOn = value);
                  widget.onIsOnChanged(value);
                },
                activeColor: Colors.green,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Intensity Slider
          Text("Intensity: ${(intensity * 100).round()}%", 
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: intensity,
            min: 0.0,
            max: 1.0,
            divisions: 20,
            label: "${(intensity * 100).round()}%",
            onChanged: (value) {
              setState(() => intensity = value);
              widget.onIntensityChanged(value);
            },
            activeColor: Colors.green,
          ),

          const SizedBox(height: 20),

          // Time selector
          const Text("Schedule Time", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          OutlinedButton(
            onPressed: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (picked != null) {
                setState(() => selectedTime = picked);
                widget.onTimePicked(picked);
              }
            },
            child: Text(
              selectedTime == null
                  ? "Pick Time"
                  : selectedTime!.format(context),
            ),
          ),

          const SizedBox(height: 30),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  widget.onSave(); 
                  resetLocalInputs();
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
