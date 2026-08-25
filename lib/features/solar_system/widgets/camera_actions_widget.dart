import 'package:flutter/material.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_layout.dart';
import '../application/solar_system_camera_controller.dart';

class CameraActionsWidget extends StatelessWidget {
  const CameraActionsWidget({super.key, required this.controller});

  final SolarSystemCameraController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.94),
        borderRadius: AppRadii.pill,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: IconButton(
        onPressed: controller.showOverview,
        tooltip: 'Voltar à visão geral',
        icon: const Icon(Icons.center_focus_strong_rounded),
      ),
    );
  }
}
