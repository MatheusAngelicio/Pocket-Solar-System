import '../domain/celestial_body.dart';

List<CelestialBody> createInitialSolarSystem() {
  return const [
    CelestialBody(
      name: 'Sol',
      colorHex: 0xFFFFD54F,
      radius: 1.6,
      distanceFromSun: 0,
      rotationSpeed: 0.18,
    ),
    CelestialBody(
      name: 'Terra',
      colorHex: 0xFF4FC3F7,
      radius: 0.45,
      distanceFromSun: 4.5,
      rotationSpeed: 0.9,
    ),
    CelestialBody(
      name: 'Lua',
      colorHex: 0xFFE0E0E0,
      radius: 0.14,
      distanceFromSun: 0.8,
      rotationSpeed: 1.4,
    ),
    CelestialBody(
      name: 'Marte',
      colorHex: 0xFFE57373,
      radius: 0.38,
      distanceFromSun: 6.5,
      rotationSpeed: 0.7,
    ),
  ];
}
