import 'dart:ui';

import 'celestial_body_id.dart';

class CelestialBody {
  const CelestialBody({
    required this.id,
    required this.name,
    required this.color,
    required this.radius,
    required this.orbitRadius,
    required this.rotationSpeed,
    required this.orbitSpeed,
    required this.initialOrbitAngle,
    this.orbitAround,
    this.ring,
  });

  final CelestialBodyId id;
  final String name;
  final Color color;
  final double radius;
  final double orbitRadius;
  final double rotationSpeed;
  final double orbitSpeed;
  final double initialOrbitAngle;
  final CelestialBodyId? orbitAround;
  final CelestialRing? ring;
}

class CelestialRing {
  const CelestialRing({
    required this.color,
    required this.innerRadius,
    required this.outerRadius,
    this.tiltRadians = 0,
  });

  final Color color;
  final double innerRadius;
  final double outerRadius;
  final double tiltRadians;
}
