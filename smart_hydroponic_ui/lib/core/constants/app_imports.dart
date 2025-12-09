// lib/app_imports.dart
export 'package:flutter/material.dart';

//Providers
export 'package:provider/provider.dart';
// Views
export '../../Features/ControlPanel/view/controlpanel.dart';
export '../../Features/ControlPanel/view/widgets/controlbox_widget.dart';
export '../../Features/ControlPanel/view/widgets/schedulealert_widget.dart';

export '../../Features/login_register/view/login_register.dart';

export '../../Features/Alerts/view/alerts.dart';
export '../../Features/Alerts/view/widgets/alerts_tile.dart';

export '../../Features/Analytics/view/analytics.dart';

export '../../Features/Dashboard/view/dashboard.dart';
export '../../Features/Dashboard/view/widgets/CustDrawer.dart';
export '../../Features/Dashboard/view/widgets/dashboard_tile.dart';

export '../../Features/Settings/view/settings.dart';
export '../../Features/Settings/view/sensor_thresholds_widget.dart';

export '../../Features/Sensors/view/sensor.dart';
export '../../Features/Sensors/view/calibration_widget.dart';
export '../../Features/Sensors/view/sensor_widget.dart';

export '../../Features/Splash/view/splash.dart';

// ViewModels
export '../../Features/ControlPanel/viewmodel/controlpanel_statemgmt.dart';
export '../../Features/login_register/viewmodel/AuthViewModel.dart';
export '../../Features/Sensors/viewmodel/sensors_statemgmt.dart';
export 'package:smart_hydroponic_ui/Features/Settings/viewmodel/settings_statemgmt.dart';
export '../../Features/Dashboard/viewmodel/dashboard_statemgmt.dart';
export '../../Features/Alerts/viewmodel/alerts_statemgmt.dart';
export '../../Features/Analytics/viewmodel/analyticsStatmgmt.dart';

// Models
export '../../Features/ControlPanel/model/actuator_model.dart';
export '../../Features/Login_Register/model/User.dart';
export '../../Features/Sensors/model/sensor_model.dart';
export '../../Features/Settings/model/thresholds_model.dart';
export '../../Features/Alerts/model/alert_model.dart';
export '../../Features/ControlPanel/model/schedules_model.dart';
export '../../Features/Sensors/model/calibration_model.dart';
//services
export '../../core/services/firebase_service.dart';
export '../../core/services/sqlite_service.dart';
export '../../core/services/AuthService.dart';
export '../../core/services/scheduler_service.dart';
//repositories
export '../../Features/ControlPanel/model/controlpanel_repository.dart';
export '../../Features/Sensors/model/sensors_repository.dart';
export '../../Features/Settings/model/thresholds_repository.dart';
export '../../Features/Alerts/model/alerts_repository.dart';

//firebase
export 'package:firebase_core/firebase_core.dart';
export 'package:smart_hydroponic_ui/firebase_options.dart';
export 'package:firebase_database/firebase_database.dart';
