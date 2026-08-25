import 'package:flutter/material.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_layout.dart';
import '../application/simulation_controller.dart';
import '../application/solar_system_camera_controller.dart';
import '../domain/celestial_body.dart';

/// Alternativa acessível à seleção direta no cenário 3D.
class CelestialBodyActionsWidget extends StatelessWidget {
  const CelestialBodyActionsWidget({
    super.key,
    required this.bodies,
    required this.simulation,
    required this.cameraController,
    required this.onBodySelected,
  });

  final List<CelestialBody> bodies;
  final SimulationController simulation;
  final SolarSystemCameraController cameraController;
  final ValueChanged<CelestialBody> onBodySelected;

  void _select(CelestialBody body) {
    simulation.pause();
    cameraController.focusOn(body.id);
    onBodySelected(body);
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.94),
        borderRadius: AppRadii.pill,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.42)),
      ),
      child: PopupMenuButton<CelestialBody>(
        tooltip: 'Selecionar um astro',
        icon: const Icon(Icons.list_alt_rounded),
        onSelected: _select,
        itemBuilder: (context) => bodies
            .map(
              (body) => PopupMenuItem(
                value: body,
                child: Semantics(
                  label: 'Selecionar ${body.name}',
                  child: Row(
                    children: [
                      ExcludeSemantics(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: body.color,
                            shape: BoxShape.circle,
                          ),
                          child: const SizedBox(width: 12, height: 12),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(body.name),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
