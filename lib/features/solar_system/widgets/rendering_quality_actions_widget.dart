import 'package:flutter/material.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_layout.dart';
import '../application/solar_system_quality_controller.dart';

class RenderingQualityActionsWidget extends StatelessWidget {
  const RenderingQualityActionsWidget({super.key, required this.controller});

  final SolarSystemQualityController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.94),
          borderRadius: AppRadii.pill,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
        ),
        child: PopupMenuButton<SolarSystemQuality>(
          tooltip: 'Qualidade gráfica: ${controller.quality.label}',
          icon: Icon(
            controller.quality == SolarSystemQuality.balanced
                ? Icons.auto_awesome_rounded
                : Icons.bolt_rounded,
          ),
          onSelected: controller.setQuality,
          itemBuilder: (context) => SolarSystemQuality.values
              .map(
                (quality) => PopupMenuItem(
                  value: quality,
                  child: Row(
                    children: [
                      Icon(
                        quality == SolarSystemQuality.balanced
                            ? Icons.auto_awesome_rounded
                            : Icons.bolt_rounded,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(quality.label),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
