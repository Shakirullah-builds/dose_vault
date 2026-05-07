import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dose_tracker/core/services/hive_service.dart';
import 'package:dose_tracker/core/theme/app_theme.dart';
import 'package:dose_tracker/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const ProviderScope(child: DoseTrackerApp()));
}

class DoseTrackerApp extends StatelessWidget {
  const DoseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dose Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppShell(),
    );
  }
}
