import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../controllers/tracking_controller.dart';
import '../core/constants.dart';
import '../models/track_point.dart';
import '../widgets/map_action_button.dart';
import '../widgets/stats_panel.dart';
import 'history_screen.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  static const CameraPosition _fallbackCamera = CameraPosition(
    target: LatLng(23.8103, 90.4125),
    zoom: 14,
  );

  late final TrackingController _tracking;
  GoogleMapController? _mapController;
  TrackPoint? _lastHandledPoint;
  String? _lastError;
  bool _followUser = true;
  bool _hasZoomedToUser = false;
  MapType _mapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    _tracking = context.read<TrackingController>();
    _tracking.addListener(_handleTrackingChange);

    // Start automatically once the first frame is drawn.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_tracking.isTracking) _tracking.start();
    });
  }

  @override
  void dispose() {
    _tracking.removeListener(_handleTrackingChange);
    super.dispose();
  }

  void _handleTrackingChange() {
    final point = _tracking.current;
    if (point != null && !identical(point, _lastHandledPoint)) {
      _lastHandledPoint = point;
      if (_followUser) _animateTo(point);
    }

    final error = _tracking.error;
    if (error != null && error != _lastError && mounted) {
      _showMessage(error);
    }
    _lastError = error;
  }

  /// Requirement 1: smoothly animate the camera to the current location.
  Future<void> _animateTo(TrackPoint point) async {
    final controller = _mapController;
    if (controller == null) return;

    final update = _hasZoomedToUser
        ? CameraUpdate.newLatLng(point.latLng)
        : CameraUpdate.newLatLngZoom(point.latLng, AppConstants.defaultZoom);
    _hasZoomedToUser = true;

    try {
      await controller.animateCamera(update);
    } catch (_) {
      // Map may already be disposed; safe to ignore.
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    final point = _tracking.current;
    if (point != null) _animateTo(point);
  }

  void _toggleFollow() {
    setState(() => _followUser = !_followUser);
    final point = _tracking.current;
    if (_followUser && point != null) _animateTo(point);
  }

  void _toggleMapType() {
    setState(() {
      _mapType = _mapType == MapType.normal ? MapType.hybrid : MapType.normal;
    });
  }

  void _toggleTracking() {
    if (_tracking.isTracking) {
      _tracking.stop();
    } else {
      _tracking.start();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Requirement 4: marker with info window (title + lat/lng snippet).
  Set<Marker> _buildMarkers(TrackPoint? current) {
    if (current == null) return const <Marker>{};

    return {
      Marker(
        markerId: const MarkerId(AppConstants.markerId),
        position: current.latLng,
        infoWindow: InfoWindow(
          title: AppConstants.markerTitle,
          snippet: '${current.latLng.latitude}, ${current.latLng.longitude}',
        ),
      ),
    };
  }

  /// Requirement 3: polyline through every recorded location.
  Set<Polyline> _buildPolylines(List<LatLng> path) {
    if (path.length < 2) return const <Polyline>{};

    return {
      Polyline(
        polylineId: const PolylineId(AppConstants.polylineId),
        points: path,
        color: Colors.blue,
        width: 5,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TrackingController>();
    final current = controller.current;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appTitle),
        actions: [
          IconButton(
            tooltip: 'Route history',
            icon: const Icon(Icons.history_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const HistoryScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: _fallbackCamera,
                  mapType: _mapType,
                  onMapCreated: _onMapCreated,
                  markers: _buildMarkers(current),
                  polylines: _buildPolylines(controller.path),
                  zoomControlsEnabled: true,
                  zoomGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                  compassEnabled: true,
                  mapToolbarEnabled: false,
                  myLocationButtonEnabled: false,
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Column(
                    children: [
                      MapActionButton(
                        icon: _followUser
                            ? Icons.my_location_rounded
                            : Icons.location_searching_rounded,
                        tooltip: _followUser ? 'Following you' : 'Follow me',
                        active: _followUser,
                        onPressed: _toggleFollow,
                      ),
                      const SizedBox(height: 10),
                      MapActionButton(
                        icon: Icons.layers_rounded,
                        tooltip: 'Map type',
                        onPressed: _toggleMapType,
                      ),
                    ],
                  ),
                ),
                if (current == null) _LoadingOverlay(message: controller.error),
              ],
            ),
          ),
          StatsPanel(
            controller: controller,
            onToggleTracking: _toggleTracking,
          ),
        ],
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.white.withValues(alpha: 0.8),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  message ?? 'Getting your location…',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}