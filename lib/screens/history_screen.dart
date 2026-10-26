import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/tracking_controller.dart';
import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/track_point.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Future<void> _confirmClear(
    BuildContext context,
    TrackingController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear route history?'),
        content: const Text(
          'This removes the recorded path and distance. '
          'Your current location is kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) controller.clearPath();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TrackingController>();
    final points = controller.points;
    final latestFirst = points.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Route history'),
        actions: [
          IconButton(
            tooltip: 'Clear history',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: points.length > 1
                ? () => _confirmClear(context, controller)
                : null,
          ),
        ],
      ),
      body: points.isEmpty
          ? const _EmptyState()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: latestFirst.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _SummaryCard(
                    points: points,
                    distanceMeters: controller.distanceMeters,
                  );
                }
                final point = latestFirst[index - 1];
                final number = latestFirst.length - (index - 1);
                return _PointTile(
                  point: point,
                  number: number,
                  isLatest: index == 1,
                );
              },
            ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.points, required this.distanceMeters});

  final List<TrackPoint> points;
  final double distanceMeters;

  @override
  Widget build(BuildContext context) {
    final duration = points.last.timestamp.difference(points.first.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _SummaryItem(label: 'Distance', value: Formatters.distance(distanceMeters)),
          _SummaryItem(label: 'Points', value: '${points.length}'),
          _SummaryItem(label: 'Duration', value: Formatters.duration(duration)),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _PointTile extends StatelessWidget {
  const _PointTile({
    required this.point,
    required this.number,
    required this.isLatest,
  });

  final TrackPoint point;
  final int number;
  final bool isLatest;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6EAF0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
            child: Text(
              '$number',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${Formatters.coordinate(point.latLng.latitude)}, '
                  '${Formatters.coordinate(point.latLng.longitude)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  Formatters.time(point.timestamp),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isLatest)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Latest',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.success,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.route_rounded, size: 64, color: AppTheme.textSecondary),
            SizedBox(height: 16),
            Text(
              'No locations recorded yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Start tracking to see your route here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}