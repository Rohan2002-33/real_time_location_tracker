import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../core/constants.dart';
import '../models/track_point.dart';
import '../services/location_service.dart';

class TrackingController extends ChangeNotifier {
  TrackingController({LocationService? service})
      : _service = service ?? const LocationService();

  final LocationService _service;
  final List<TrackPoint> _points = [];

  Timer? _timer;
  bool _isTracking = false;
  bool _isFetching = false;
  bool _disposed = false;
  double _distanceMeters = 0;
  String? _error;

  List<TrackPoint> get points => List.unmodifiable(_points);
  List<LatLng> get path =>
      _points.map((point) => point.latLng).toList(growable: false);
  TrackPoint? get current => _points.isEmpty ? null : _points.last;
  bool get isTracking => _isTracking;
  double get distanceMeters => _distanceMeters;
  int get updateCount => _points.length;
  String? get error => _error;

  /// Fetches one location now, then every 10 seconds.
  Future<void> start() async {
    if (_isTracking) return;
    _isTracking = true;
    _error = null;
    notifyListeners();

    await _fetchLocation();
    if (!_isTracking || _disposed) return;

    _timer = Timer.periodic(
      AppConstants.updateInterval,
      (_) => _fetchLocation(),
    );
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _isTracking = false;
    notifyListeners();
  }

  /// Clears the route but keeps the latest point so the marker stays.
  void clearPath() {
    final last = current;
    _points.clear();
    if (last != null) _points.add(last);
    _distanceMeters = 0;
    notifyListeners();
  }

  Future<void> _fetchLocation() async {
    if (_isFetching || _disposed) return;
    _isFetching = true;

    try {
      final position = await _service.getCurrentPosition();
      final point = TrackPoint.fromPosition(position);

      if (_points.isNotEmpty) {
        final previous = _points.last.latLng;
        _distanceMeters += Geolocator.distanceBetween(
          previous.latitude,
          previous.longitude,
          point.latLng.latitude,
          point.latLng.longitude,
        );
      }

      _points.add(point);
      _error = null;
    } on TimeoutException {
      _error = 'No GPS signal yet. Try moving to an open area.';
    } catch (_) {
      _error = 'Unable to fetch your location.';
    } finally {
      _isFetching = false;
    }

    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}