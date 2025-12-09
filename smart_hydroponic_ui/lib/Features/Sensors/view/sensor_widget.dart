import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';

class SensorCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final List<Sensor>? history;

  const SensorCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.history,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          title: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          children: [
            if (history != null && history!.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: history!.length,
                  itemBuilder: (context, index) {
                    final item = history![index];
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.history,
                        size: 16,
                        color: Colors.grey,
                      ),
                      title: Text(
                        "${item.value}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(item.timestamp),
                      trailing: Text(
                        item.status,
                        style: TextStyle(
                          color: item.status == "Optimal" || item.status == "OK"
                              ? Colors.green
                              : Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("No history available"),
              ),
          ],
        ),
      ),
    );
  }
}
