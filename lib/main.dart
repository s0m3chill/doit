import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:doit/core/di/injection_container.dart' as di;
import 'package:doit/core/services/notification_service.dart';
import 'package:doit/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await di.init();

  // Initialize notification system.
  await di.sl<NotificationService>().initialize();

  runApp(const DoItApp());
}
