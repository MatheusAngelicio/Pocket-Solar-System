import 'package:flutter_scene/scene.dart';

import '../domain/celestial_body_id.dart';
import '../domain/celestial_surface.dart';

class SolarSystemTextures {
  const SolarSystemTextures({
    required this.solar,
    required this.rocky,
    required this.gaseous,
    required this.earth,
    required this.starfield,
  });

  final Texture2D solar;
  final Texture2D rocky;
  final Texture2D gaseous;
  final Texture2D earth;
  final Texture2D starfield;

  Texture2D forBody(CelestialBodyId id, CelestialSurface surface) =>
      switch (id) {
        CelestialBodyId.earth => earth,
        _ => forSurface(surface),
      };

  Texture2D forSurface(CelestialSurface surface) => switch (surface) {
    CelestialSurface.solar => solar,
    CelestialSurface.rocky => rocky,
    CelestialSurface.gaseous => gaseous,
  };
}

abstract final class SolarSystemTextureCatalog {
  static const _solarPath = 'assets/textures/sun_surface.png';
  static const _rockyPath = 'assets/textures/rocky_surface.png';
  static const _gaseousPath = 'assets/textures/gas_surface.png';
  static const _earthPath = 'assets/textures/earth_surface.png';
  static const _starfieldPath = 'assets/textures/starfield_enhanced.png';

  static Future<SolarSystemTextures> load() async {
    final textures = await Future.wait([
      Texture2D.fromAsset(_solarPath),
      Texture2D.fromAsset(_rockyPath),
      Texture2D.fromAsset(_gaseousPath),
      Texture2D.fromAsset(_earthPath),
      Texture2D.fromAsset(_starfieldPath),
    ]);

    return SolarSystemTextures(
      solar: textures[0],
      rocky: textures[1],
      gaseous: textures[2],
      earth: textures[3],
      starfield: textures[4],
    );
  }
}
