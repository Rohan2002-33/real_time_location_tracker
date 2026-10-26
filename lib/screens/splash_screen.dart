import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/routes.dart';
import '../core/theme.dart';
import '../services/location_service.dart';
import 'permission_screen.dart';
import 'tracker_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  late final Animation<double> _fade =
      CurvedAnimation(parent: _animation, curve: Curves.easeOut);

  late final Animation<double> _scale = Tween<double>(begin: 0.85, end: 1).animate(
    CurvedAnimation(parent: _animation, curve: Curves.easeOutBack),
  );

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final minimumDelay = Future<void>.delayed(const Duration(milliseconds: 1600));
    final status = await const LocationService().checkStatus();
    await minimumDelay;
    if (!mounted) return;

    final next = status == LocationStatus.granted
        ? const TrackerScreen()
        : PermissionScreen(initialStatus: status);

    Navigator.of(context).pushReplacement(fadeRoute<void>(next));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E88E5), Color(0xFF0D47A1)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 104,
                        height: 104,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 24,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.my_location_rounded,
                          size: 52,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        AppConstants.appTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Follow every move in real time',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 40),
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}