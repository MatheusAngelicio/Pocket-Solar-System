import 'package:flutter/foundation.dart';

import '../domain/celestial_body_id.dart';

/// Publica pedidos de foco para a câmera da cena.
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
