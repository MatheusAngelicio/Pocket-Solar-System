enum CelestialBodyType {
  star,
  terrestrialPlanet,
  gasGiant,
  iceGiant,
  naturalSatellite,
}

class CelestialBodyInformation {
  const CelestialBodyInformation({
    required this.type,
    required this.radiusKm,
    required this.distanceFromSunMillionKm,
    required this.dayDuration,
    required this.yearDuration,
    required this.fact,
  });

  final CelestialBodyType type;
  final double radiusKm;
  final double distanceFromSunMillionKm;
  final String dayDuration;
  final String yearDuration;
  final String fact;
}
