import 'package:geolocator/geolocator.dart';

enum LocationStatus { granted, serviceDisabled, denied, deniedForever }

class LocationService {
  const LocationService();

  /// Checks state without showing any system dialog.
  Future<LocationStatus> checkStatus() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return LocationStatus.serviceDisabled;
    return _map(await Geolocator.checkPermission());
  }

  /// Shows the system permission dialog when needed.
  Future<LocationStatus> requestPermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return LocationStatus.serviceDisabled;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return _map(permission);
  }

  Future<Position> getCurrentPosition() {
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  LocationStatus _map(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationStatus.granted;
      case LocationPermission.deniedForever:
        return LocationStatus.deniedForever;
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
        return LocationStatus.denied;
    }
  }
}