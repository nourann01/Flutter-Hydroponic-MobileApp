import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';

class CustDrawer extends StatelessWidget {
  const CustDrawer({super.key});

  void _navigateTo(BuildContext context, String routeName) {
    Navigator.pop(context);
    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 105, 170, 108),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 16,
              ),
              color: const Color.fromARGB(255, 105, 170, 108),
              child: const Text(
                'SMART Hydroponic',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            ListTile(
              title: const Text(
                'Dashboard',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),

              onTap: () => _navigateTo(context, '/dashboard'),
            ),

            ListTile(
              title: const Text(
                'Sensors',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              onTap: () => _navigateTo(context, '/sensors'),
            ),

            ListTile(
              title: const Text(
                'Control Panel',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              onTap: () => _navigateTo(context, '/control-panel'),
            ),

            ListTile(
              title: const Text(
                'Settings',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              onTap: () => _navigateTo(context, '/settings'),
            ),

            ListTile(
              title: const Text(
                'Analytics & History',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              onTap: () => _navigateTo(context, '/analytics'),
            ),
            ListTile(
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              onTap: () async {
                final authVM = Provider.of<AuthViewModel>(
                  context,
                  listen: false,
                );

                await authVM.logout(); // Only logic here

                // Navigate automatically based on state
                if (!authVM.isLoggedIn) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => SystemForms()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
