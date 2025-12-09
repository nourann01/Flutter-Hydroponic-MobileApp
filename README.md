# 🌱 SMART Hydroponic System - Flutter Mobile App

A Flutter mobile application for monitoring and controlling IoT-enabled hydroponic farming systems with real-time sensor data, analytics, and voice-controlled navigation.

---

# Prerequisites
- Flutter SDK 3.0+  
- Dart 3.0+  
- Android Studio or VS Code  

---

# Installation

### Clone the repository
```bash
git clone https://github.com/nourann01/SMART-Hydroponic_Flutter_MobileApp.git
cd SMART-Hydroponic_Flutter_MobileApp

### Install dependencies
flutter pub get

### Run the app
flutter run

# 🎤 Voice Commands
Tap the microphone icon and say:

"Go to sensors"
"Open analytics"
"Go to control panel"
"Open settings"
"Go to alerts"

# 📂 Project Structure
lib/
├── core/              # Constants, services, widgets
├── Features/
│   ├── Dashboard/     # Main dashboard
│   ├── Sensors/       # Sensor monitoring
│   ├── Analytics/     # Data analytics
│   ├── ControlPanel/  # Device control
│   ├── Alerts/        # Notifications
│   └── Settings/      # App settings
└── main.dart
