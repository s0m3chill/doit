import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:doit/core/di/injection_container.dart' as di;
import 'package:doit/core/services/notification_action_handler.dart';
import 'package:doit/core/services/notification_service.dart';
import 'package:doit/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await di.init();

  final actionHandler = di.sl<NotificationActionHandler>();

  // Initialize notifications with action callbacks wired to the handler.
  await di.sl<NotificationService>().initialize(
        onAction: actionHandler.handleAction,
        onTap: actionHandler.handleNotificationTap,
      );

  runApp(const DoItApp());
}
