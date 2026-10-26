import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackPoint {
  const TrackPoint({
    required this.latLng,
    required this.timestamp,
    this.accuracy = 0,
    this.speed = 0,
  });

  final LatLng latLng;
  final DateTime timestamp;
  final double accuracy;
  final double speed;

  factory TrackPoint.fromPosition(Position position) {
    return TrackPoint(
      latLng: LatLng(position.latitude, position.longitude),
      timestamp: DateTime.now(),
      accuracy: position.accuracy,
      speed: position.speed,
    );
  }
}