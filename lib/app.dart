import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/tracking_controller.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'screens/splash_screen.dart';

class TrackerApp extends StatelessWidget {
  const TrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TrackingController(),
      child: MaterialApp(
        title: AppConstants.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}