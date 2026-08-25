import 'package:flutter/foundation.dart';

import '../domain/celestial_body_id.dart';

/// Publishes focus requests for the scene camera.
class SolarSystemCameraController extends ChangeNotifier {
  CelestialBodyId? _focusedBodyId;

  CelestialBodyId? get focusedBodyId => _focusedBodyId;

  void focusOn(CelestialBodyId bodyId) {
    _focusedBodyId = bodyId;
    notifyListeners();
  }

  void showOverview() {
    _focusedBodyId = null;
    notifyListeners();
  }
}
