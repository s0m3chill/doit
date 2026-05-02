import 'package:flutter/material.dart';
import 'package:doit/core/di/injection_container.dart' as di;
import 'package:doit/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const DoItApp());
}
