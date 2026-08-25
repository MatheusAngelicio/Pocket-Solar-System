import 'package:flutter/material.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_layout.dart';
import '../domain/celestial_body.dart';
import '../domain/celestial_body_information.dart';

class CelestialBodyDetailsSheetWidget extends StatelessWidget {
  const CelestialBodyDetailsSheetWidget({super.key, required this.body});

  final CelestialBody body;

  @override
  Widget build(BuildContext context) {
    final information = body.information;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.textSecondary,
                    borderRadius: AppRadii.pill,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: body.color,
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox(width: 18, height: 18),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          body.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          information.type.label,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close details',
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _InformationItemWidget(
                    label: 'Radius',
                    value: '${_formatNumber(information.radiusKm)} km',
                  ),
                  _InformationItemWidget(
                    label: 'Distance from Sun',
                    value:
                        '${_formatNumber(information.distanceFromSunMillionKm)} million km',
                  ),
                  _InformationItemWidget(
                    label: 'Day length',
                    value: information.dayDuration,
                  ),
                  _InformationItemWidget(
                    label: 'Year length',
                    value: information.yearDuration,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: AppRadii.card,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          information.fact,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InformationItemWidget extends StatelessWidget {
  const _InformationItemWidget({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 156,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.space,
          borderRadius: AppRadii.card,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.xxs),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}

extension on CelestialBodyType {
  String get label => switch (this) {
    CelestialBodyType.star => 'Star',
    CelestialBodyType.terrestrialPlanet => 'Terrestrial planet',
    CelestialBodyType.gasGiant => 'Gas giant',
    CelestialBodyType.iceGiant => 'Ice giant',
    CelestialBodyType.naturalSatellite => 'Natural satellite',
  };
}

String _formatNumber(double value) {
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
}
