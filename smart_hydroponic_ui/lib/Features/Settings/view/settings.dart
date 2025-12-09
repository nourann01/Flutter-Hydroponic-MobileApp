import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabButton("Notifications", 0),
                  const SizedBox(width: 10),
                  _buildTabButton("Sensor Thresholds", 1),
                  const SizedBox(width: 10),
                  _buildTabButton("User Profile", 2),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (selectedTab == 0) _buildNotifications(authVM),
            if (selectedTab == 1) const SensorThresholdsWidget(),
            if (selectedTab == 2) _buildUserProfile(authVM),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedTab == index ? Colors.green : Colors.grey[300],
        foregroundColor: selectedTab == index ? Colors.white : Colors.black,
      ),
      onPressed: () => setState(() => selectedTab = index),
      child: Text(title),
    );
  }

  // -------------------------------
  // NOTIFICATIONS UI
  // -------------------------------
  Widget _buildNotifications(AuthViewModel authVM) {
    final user = authVM.currentUser;
    if (user == null) return const Text("No user logged in");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Notification Preferences",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        _buildSwitchTile(
          icon: Icons.email_outlined,
          color: Colors.purple,
          title: "Email Notifications",
          value: user.isEmailNotificationEnabled,
          onChanged: (v) async {
            await authVM.updateUser(isEmailNotificationEnabled: v);
          },
        ),

        _buildSwitchTile(
          icon: Icons.sms_outlined,
          color: Colors.green,
          title: "SMS Notifications",
          value: user.isSmsNotificationEnabled,
          onChanged: (v) async {
            await authVM.updateUser(isSmsNotificationEnabled: v);
          },
        ),

        _buildSwitchTile(
          icon: Icons.notifications_active,
          color: Colors.teal,
          title: "Push Notifications",
          value: user.isPushedNotificationEnabled,
          onChanged: (v) async {
            await authVM.updateUser(isPushedNotificationEnabled: v);
          },
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color color,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }

  // -------------------------------
  // USER PROFILE UI
  // -------------------------------
  Widget _buildUserProfile(AuthViewModel authVM) {
    final user = authVM.currentUser;
    if (user == null) return const Text("No user logged in");

    final name = TextEditingController(text: user.name);
    final phone = TextEditingController(text: user.phoneNumber);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "User Profile",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        _profileField(Icons.person, "Name", name, () async {
          await authVM.updateUser(name: name.text);
        }),

        _profileField(Icons.phone, "Phone Number", phone, () async {
          await authVM.updateUser(phoneNumber: phone.text);
        }),
      ],
    );
  }

  Widget _profileField(
    IconData icon,
    String label,
    TextEditingController controller,
    VoidCallback onSave, {
    bool obscure = false,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.save, color: Colors.blue),
          onPressed: onSave,
        ),
      ),
    );
  }
}
