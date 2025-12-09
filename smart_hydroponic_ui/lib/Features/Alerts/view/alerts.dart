import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';

class Alerts extends StatelessWidget {
  const Alerts({super.key});

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
      ),
      drawer: const CustDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Alerts',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    Consumer<AlertsStateMgmt>(
                      builder: (context, alertsVM, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: alertsVM.unreadCount > 0
                                ? Colors.red.shade50
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: alertsVM.unreadCount > 0
                                  ? Colors.red.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            '${alertsVM.unreadCount} Unread',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: alertsVM.unreadCount > 0
                                  ? Colors.red[700]
                                  : Colors.grey[700],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Ink(
                      decoration: ShapeDecoration(
                        color: Colors.grey[200],
                        shape: const CircleBorder(),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.settings),
                        color: Colors.black,
                        iconSize: 20,
                        onPressed: () {
                          Navigator.pushNamed(context, '/settings');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Ink(
                      decoration: ShapeDecoration(
                        color: Colors.grey[200],
                        shape: const CircleBorder(),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.dashboard),
                        color: Colors.black,
                        iconSize: 20,
                        onPressed: () {
                          Navigator.pushNamed(context, '/dashboard');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Alerts List
            Expanded(
              child: Consumer<AlertsStateMgmt>(
                builder: (context, alertsVM, child) {
                  if (alertsVM.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (alertsVM.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            alertsVM.errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  if (alertsVM.alerts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No alerts',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: alertsVM.alerts.length,
                    itemBuilder: (context, index) {
                      final alert = alertsVM.alerts[index];
                      return _buildAlertListTile(context, alert, alertsVM);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final alertsVM = Provider.of<AlertsStateMgmt>(context, listen: false);
          alertsVM.insertDummyAlerts();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dummy alerts inserted!')),
          );
        },
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add_alert, color: Colors.white),
      ),
    );
  }

  Widget _buildAlertListTile(
    BuildContext context,
    alert,
    AlertsStateMgmt alertsVM,
  ) {
    // Determine icon and color based on severity
    IconData icon;
    Color color;

    switch (alert.severity.toLowerCase()) {
      case 'danger':
        icon = Icons.error;
        color = Colors.red;
        break;
      case 'warning':
        icon = Icons.warning;
        color = Colors.orange;
        break;
      default:
        icon = Icons.info;
        color = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: alert.isRead ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: alert.isRead ? Colors.grey[200]! : color.withOpacity(0.3),
          width: alert.isRead ? 1 : 2,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          alert.title,
          style: TextStyle(
            fontWeight: alert.isRead ? FontWeight.w500 : FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              alert.message,
              style: const TextStyle(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              alert.timestamp,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: !alert.isRead
            ? IconButton(
                icon: const Icon(Icons.check_circle_outline),
                color: Colors.green,
                onPressed: () {
                  if (alert.id != null) {
                    alertsVM.markAsRead(alert.id!);
                  }
                },
                tooltip: 'Mark as read',
              )
            : Icon(Icons.check_circle, color: Colors.grey[400], size: 20),
        onTap: () {
          if (!alert.isRead && alert.id != null) {
            alertsVM.markAsRead(alert.id!);
          }
        },
      ),
    );
  }
}
