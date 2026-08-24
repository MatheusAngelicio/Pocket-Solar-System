import 'package:flutter/material.dart';

import 'design_system/app_colors.dart';
import 'design_system/app_layout.dart';
import 'design_system/app_theme.dart';
import 'features/solar_system/data/solar_system_data.dart';
import 'features/solar_system/presentation/solar_system_scene.dart';

void main() {
  runApp(const PocketSolarSystemApp());
}

class PocketSolarSystemApp extends StatelessWidget {
  const PocketSolarSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocket Solar System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const SolarSystemHomePage(),
    );
  }
}

class SolarSystemHomePage extends StatelessWidget {
  const SolarSystemHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SolarSystemScene(bodies: createInitialSolarSystem()),
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
                            Text(
                              'Sol · Terra · Lua · Marte',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
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
        ],
      ),
    );
  }
}
