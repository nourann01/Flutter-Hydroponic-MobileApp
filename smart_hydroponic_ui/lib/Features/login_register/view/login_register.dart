import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';

class SystemForms extends StatefulWidget {
  @override
  State<SystemForms> createState() => _SystemFormsState();
}

class _SystemFormsState extends State<SystemForms> {
  final GlobalKey<FormState> loginKey = GlobalKey<FormState>();
  final GlobalKey<FormState> registerKey = GlobalKey<FormState>();

  // ----- Login Controllers -----
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  // ----- Register Controllers -----
  final TextEditingController regNameController = TextEditingController();
  final TextEditingController regEmailController = TextEditingController();
  final TextEditingController regPasswordController = TextEditingController();
  final TextEditingController regConfirmPasswordController =
      TextEditingController();
  final TextEditingController regPhoneController = TextEditingController();

  int _tabIndex = 0;

  final List<DataTab> _tabs = [
    DataTab(title: "Login"),
    DataTab(title: "Register"),
  ];

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Image.asset('assets/images/Logo.png', width: 150, height: 150),
                const SizedBox(height: 20),
                const Text(
                  'Smart Hydroponic',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Monitor and control your hydroponic system',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                FlutterToggleTab(
                  width: 70,
                  borderRadius: 30,
                  height: 40,
                  selectedIndex: _tabIndex,
                  selectedBackgroundColors: [Colors.white],
                  selectedTextStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  unSelectedTextStyle: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  dataTabs: _tabs,
                  selectedLabelIndex: (index) =>
                      setState(() => _tabIndex = index),
                  isScroll: false,
                ),
                const SizedBox(height: 20),
                _tabIndex == 0 ? _loginForm(authVM) : _registerForm(authVM),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginForm(AuthViewModel authVM) {
    return Form(
      key: loginKey,
      child: Column(
        children: [
          _buildTextField(
            loginEmailController,
            'Email',
            Icons.email_outlined,
            type: 'email',
          ),
          const SizedBox(height: 20),
          _buildTextField(
            loginPasswordController,
            'Password',
            Icons.lock_outline,
            type: 'password',
            obscure: true,
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {},
              child: Text(
                "Forgot password?",
                style: TextStyle(color: Colors.green.shade700),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (loginKey.currentState!.validate()) {
                bool success = await authVM.login(
                  email: loginEmailController.text.trim(),
                  password: loginPasswordController.text.trim(),
                );
                if (success)
                  Navigator.pushReplacementNamed(context, '/dashboard');
                else
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(authVM.errorMessage ?? "Login failed"),
                    ),
                  );
              }
            },
            child: const Text("Login"),
          ),
        ],
      ),
    );
  }

  Widget _registerForm(AuthViewModel authVM) {
    return Form(
      key: registerKey,
      child: Column(
        children: [
          _buildTextField(
            regNameController,
            'Full Name',
            Icons.person,
            type: 'name',
          ),
          const SizedBox(height: 10),
          _buildTextField(
            regEmailController,
            'Email',
            Icons.email_outlined,
            type: 'email',
          ),
          const SizedBox(height: 20),
          _buildTextField(
            regPasswordController,
            'Password',
            Icons.lock_outline,
            type: 'password',
            obscure: true,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            regConfirmPasswordController,
            'Confirm Password',
            Icons.lock_outline,
            type: 'password',
            obscure: true,
            matchController: regPasswordController,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            regPhoneController,
            'Phone',
            Icons.phone,
            keyboard: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (registerKey.currentState!.validate()) {
                bool success = await authVM.register(
                  fullName: regNameController.text.trim(),
                  email: regEmailController.text.trim(),
                  password: regPasswordController.text.trim(),
                  phone: regPhoneController.text.trim(),
                );
                if (success)
                  Navigator.pushReplacementNamed(context, '/dashboard');
                else
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(authVM.errorMessage ?? "Signup failed"),
                    ),
                  );
              }
            },
            child: const Text("Sign Up"),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    String? type,
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
    TextEditingController? matchController,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        prefixIcon: Icon(icon, color: Colors.green.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'This field cannot be empty';
        switch (type) {
          case 'email':
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))
              return 'Enter valid email';
            break;
          case 'password':
            if (value.length < 6)
              return 'Password must be at least 6 characters';
            if (matchController != null && value != matchController.text)
              return 'Passwords do not match';
            break;
          case 'name':
            if (value.length < 3 || !RegExp(r'^[a-zA-Z ]+$').hasMatch(value))
              return 'Enter valid name';
            break;
        }
        return null;
      },
    );
  }
}
