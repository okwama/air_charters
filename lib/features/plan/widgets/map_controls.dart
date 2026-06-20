import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/theme/app_theme.dart';

class MapControls extends StatelessWidget {
  final VoidCallback onMyLocationTap;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final bool showZoomControls;

  const MapControls({
    super.key,
    required this.onMyLocationTap,
    this.onZoomIn,
    this.onZoomOut,
    this.showZoomControls = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Zoom controls (optional)
        if (showZoomControls && onZoomIn != null && onZoomOut != null) ...[
          _buildControlButton(
            icon: LucideIcons.plus,
            onTap: onZoomIn!,
          ),
          const SizedBox(height: 8),
          _buildControlButton(
            icon: LucideIcons.minus,
            onTap: onZoomOut!,
          ),
          const SizedBox(height: 16),
        ],

        // My location button
        _buildControlButton(
          icon: LucideIcons.navigation,
          onTap: onMyLocationTap,
          color: AppTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: color ?? Colors.black87,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
