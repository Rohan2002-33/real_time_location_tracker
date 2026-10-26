import 'package:flutter/material.dart';

import '../core/routes.dart';
import '../core/theme.dart';
import '../services/location_service.dart';
import 'tracker_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({
    super.key,
    this.initialStatus = LocationStatus.denied,
  });

  final LocationStatus initialStatus;

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen>
    with WidgetsBindingObserver {
  final LocationService _service = const LocationService();

  late LocationStatus _status = widget.initialStatus;
  bool _busy = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // User may come back from system settings: re-check automatically.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final status = await _service.checkStatus();
    _apply(status);
  }

  Future<void> _onPrimaryPressed() async {
    setState(() => _busy = true);

    switch (_status) {
      case LocationStatus.serviceDisabled:
        await _service.openLocationSettings();
      case LocationStatus.deniedForever:
        await _service.openAppSettings();
      case LocationStatus.denied:
      case LocationStatus.granted:
        _apply(await _service.requestPermission());
    }

    if (mounted) setState(() => _busy = false);
  }

  void _apply(LocationStatus status) {
    if (!mounted || _navigated) return;

    if (status == LocationStatus.granted) {
      _navigated = true;
      Navigator.of(context).pushReplacement(
        fadeRoute<void>(const TrackerScreen()),
      );
      return;
    }
    setState(() => _status = status);
  }

  _PermissionContent get _content {
    switch (_status) {
      case LocationStatus.serviceDisabled:
        return const _PermissionContent(
          icon: Icons.location_disabled_rounded,
          title: 'Location is turned off',
          message: 'Turn on GPS so the app can follow your position on the map.',
          action: 'Turn on location',
        );
      case LocationStatus.deniedForever:
        return const _PermissionContent(
          icon: Icons.lock_outline_rounded,
          title: 'Permission blocked',
          message: 'Location access was permanently denied. Open app settings '
              'and allow location to continue.',
          action: 'Open app settings',
        );
      case LocationStatus.denied:
      case LocationStatus.granted:
        return const _PermissionContent(
          icon: Icons.my_location_rounded,
          title: 'Allow location access',
          message: 'We use your location to show where you are, refresh it '
              'every 10 seconds and draw your route on the map.',
          action: 'Allow location access',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _content;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(content.icon, size: 56, color: AppTheme.primary),
              ),
              const SizedBox(height: 32),
              Text(
                content.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                content.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: AppTheme.textSecondary,
                ),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _busy ? null : _onPrimaryPressed,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(content.action),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your location is only used while the app is open.',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionContent {
  const _PermissionContent({
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final String action;
}