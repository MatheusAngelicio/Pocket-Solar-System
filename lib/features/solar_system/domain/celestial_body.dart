class CelestialBody {
  const CelestialBody({
    required this.name,
    required this.colorHex,
    required this.radius,
    required this.distanceFromSun,
    required this.rotationSpeed,
  });

  final String name;
  final int colorHex;
  final double radius;
  final double distanceFromSun;
  final double rotationSpeed;
}
