class AppConstants {
  AppConstants._();

  static const String appTitle = 'Real-Time Location Tracker';
  static const String markerTitle = 'My current location';
  static const String markerId = 'current_location_marker';
  static const String polylineId = 'route_polyline';

  /// Assignment: fetch the user's location every 10 seconds.
  static const Duration updateInterval = Duration(seconds: 10);

  static const double defaultZoom = 17;
}
