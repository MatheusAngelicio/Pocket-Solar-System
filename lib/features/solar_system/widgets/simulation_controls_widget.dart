import 'package:flutter/material.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_layout.dart';
import '../application/simulation_controller.dart';

class SimulationControlsWidget extends StatelessWidget {
  const SimulationControlsWidget({super.key, required this.controller});

  final SimulationController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.94),
            borderRadius: AppRadii.card,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.18),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Wrap(
              spacing: AppSpacing.xxs,
              runSpacing: AppSpacing.xxs,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                IconButton.filledTonal(
                  onPressed: controller.togglePause,
                  tooltip: controller.isPaused
                      ? 'Resume simulation'
                      : 'Pause simulation',
                  icon: Icon(
                    controller.isPaused
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                  ),
                ),
                for (final speed in SimulationSpeed.values) ...[
                  ChoiceChip(
                    label: Text(speed.label),
                    selected: controller.speed == speed,
                    onSelected: (_) => controller.setSpeed(speed),
                  ),
                  if (speed != SimulationSpeed.values.last)
                    const SizedBox(width: AppSpacing.xxs),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
