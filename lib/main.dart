import 'package:flutter/material.dart';

import 'design_system/app_colors.dart';
import 'design_system/app_layout.dart';
import 'design_system/app_theme.dart';
import 'features/solar_system/data/solar_system_data.dart';
import 'features/solar_system/application/solar_system_camera_controller.dart';
import 'features/solar_system/application/solar_system_quality_controller.dart';
import 'features/solar_system/application/simulation_controller.dart';
import 'features/solar_system/widgets/camera_actions_widget.dart';
import 'features/solar_system/widgets/celestial_body_actions_widget.dart';
import 'features/solar_system/widgets/celestial_body_details_sheet_widget.dart';
import 'features/solar_system/widgets/gesture_tutorial_widget.dart';
import 'features/solar_system/widgets/simulation_controls_widget.dart';
import 'features/solar_system/widgets/solar_system_scene_widget.dart';
import 'features/solar_system/widgets/rendering_quality_actions_widget.dart';
import 'features/solar_system/domain/celestial_body.dart';

void main() {
  runApp(const PocketSolarSystemAppWidget());
}

class PocketSolarSystemAppWidget extends StatelessWidget {
  const PocketSolarSystemAppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocket Solar System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const SolarSystemHomePageWidget(),
    );
  }
}

class SolarSystemHomePageWidget extends StatefulWidget {
  const SolarSystemHomePageWidget({super.key});

  @override
  State<SolarSystemHomePageWidget> createState() => _SolarSystemHomePageState();
}

class _SolarSystemHomePageState extends State<SolarSystemHomePageWidget> {
  final _camera = SolarSystemCameraController();
  final _simulation = SimulationController();
  final _quality = SolarSystemQualityController();
  late final _bodies = createInitialSolarSystem();
  CelestialBody? _selectedBody;

  @override
  void dispose() {
    _camera.dispose();
    _simulation.dispose();
    _quality.dispose();
    super.dispose();
  }

  Future<void> _showBodyInformation(CelestialBody body) async {
    setState(() => _selectedBody = body);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.42,
      ),
      builder: (context) => CelestialBodyDetailsSheetWidget(body: body),
    );

    if (!mounted || _selectedBody != body) return;
    setState(() => _selectedBody = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SolarSystemSceneWidget(
            bodies: _bodies,
            simulation: _simulation,
            cameraController: _camera,
            qualityController: _quality,
            onBodySelected: _showBodyInformation,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Align(
                alignment: Alignment.topCenter,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.92),
                    borderRadius: AppRadii.card,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.public_rounded, color: AppColors.secondary),
                        SizedBox(width: AppSpacing.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Sistema Solar',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CelestialBodyActionsWidget(
                      bodies: _bodies,
                      simulation: _simulation,
                      cameraController: _camera,
                      onBodySelected: _showBodyInformation,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    CameraActionsWidget(controller: _camera),
                    const SizedBox(height: AppSpacing.sm),
                    RenderingQualityActionsWidget(controller: _quality),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SimulationControlsWidget(controller: _simulation),
              ),
            ),
          ),
          const GestureTutorialWidget(),
        ],
      ),
    );
  }
}
