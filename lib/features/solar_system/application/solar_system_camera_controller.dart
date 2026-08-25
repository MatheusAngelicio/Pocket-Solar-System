import 'package:flutter/foundation.dart';

/// Publica pedidos de foco para a câmera da cena.
class SolarSystemCameraController extends ChangeNotifier {
  String? _focusedBodyName;

  String? get focusedBodyName => _focusedBodyName;

  void focusOn(String bodyName) {
    _focusedBodyName = bodyName;
    notifyListeners();
  }

  void showOverview() {
    _focusedBodyName = null;
    notifyListeners();
  }
}
