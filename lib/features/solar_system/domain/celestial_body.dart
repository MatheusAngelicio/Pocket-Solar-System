class CelestialBody {
  const CelestialBody({
    required this.name,
    required this.colorHex,
    required this.radius,
    required this.distanceFromSun,
    required this.rotationSpeed,
    required this.orbitSpeed,
    required this.initialOrbitAngle,
  });

  final String name;
  final int colorHex;
  final double radius;
  final double distanceFromSun;
  final double rotationSpeed;
  final double orbitSpeed;
  final double initialOrbitAngle;
}
