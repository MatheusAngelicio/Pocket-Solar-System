import '../domain/celestial_body.dart';
import 'solar_system_colors.dart';

// Distâncias e velocidades visuais, ajustadas para leitura em uma tela móvel.
List<CelestialBody> createInitialSolarSystem() {
  return const [
    CelestialBody(
      name: 'Sol',
      color: SolarSystemColors.sun,
      radius: 1.6,
      distanceFromSun: 0,
      rotationSpeed: 0.18,
      orbitSpeed: 0,
      initialOrbitAngle: 0,
    ),
    CelestialBody(
      name: 'Terra',
      color: SolarSystemColors.earth,
      radius: 0.45,
      distanceFromSun: 4.5,
      rotationSpeed: 0.9,
      orbitSpeed: 0.28,
      initialOrbitAngle: 0,
    ),
    CelestialBody(
      name: 'Lua',
      color: SolarSystemColors.moon,
      radius: 0.14,
      distanceFromSun: 0.8,
      rotationSpeed: 1.4,
      orbitSpeed: 1.6,
      initialOrbitAngle: 0.6,
    ),
    CelestialBody(
      name: 'Marte',
      color: SolarSystemColors.mars,
      radius: 0.38,
      distanceFromSun: 6.5,
      rotationSpeed: 0.7,
      orbitSpeed: 0.2,
      initialOrbitAngle: 2.2,
    ),
  ];
}
