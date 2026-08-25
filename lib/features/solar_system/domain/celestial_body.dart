import 'dart:ui';

import 'celestial_body_id.dart';
import 'celestial_body_information.dart';

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
    required this.information,
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
  final CelestialBodyInformation information;
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
