import 'package:flutter/material.dart';

import '../controllers/tracking_controller.dart';
import '../core/constants.dart';
import '../core/formatters.dart';
import '../core/theme.dart';

class StatsPanel extends StatelessWidget {
  const StatsPanel({
    super.key,
    required this.controller,
    required this.onToggleTracking,
  });

  final TrackingController controller;
  final VoidCallback onToggleTracking;

  @override
  Widget build(BuildContext context) {
    final current = controller.current;
    final isLive = controller.isTracking;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatusPill(isLive: isLive),
                const Spacer(),
                if (current != null)
                  Text(
                    'Updated ${Formatters.time(current.timestamp)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _InfoBlock(
                    label: 'Latitude',
                    value: current == null
                        ? '--'
                        : Formatters.coordinate(current.latLng.latitude),
                  ),
                ),
                Expanded(
                  child: _InfoBlock(
                    label: 'Longitude',
                    value: current == null
                        ? '--'
                        : Formatters.coordinate(current.latLng.longitude),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.route_rounded,
                    label: 'Distance',
                    value: Formatters.distance(controller.distanceMeters),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatTile(
                    icon: Icons.update_rounded,
                    label: 'Updates',
                    value: '${controller.updateCount}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatTile(
                    icon: Icons.gps_fixed_rounded,
                    label: 'Accuracy',
                    value: current == null
                        ? '--'
                        : Formatters.accuracy(current.accuracy),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: onToggleTracking,
                icon: Icon(
                  isLive ? Icons.pause_rounded : Icons.play_arrow_rounded,
                ),
                label: Text(isLive ? 'Pause tracking' : 'Resume tracking'),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.isLive});

  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final color = isLive ? AppTheme.success : AppTheme.textSecondary;
    final seconds = AppConstants.updateInterval.inSeconds;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            isLive ? 'Live · every ${seconds}s' : 'Paused',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}