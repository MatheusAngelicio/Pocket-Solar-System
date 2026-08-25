import 'package:flutter/foundation.dart';

enum SimulationSpeed {
  quarter(0.25, '0.25x'),
  normal(1, '1x'),
  fast(10, '10x'),
  veryFast(100, '100x');

  const SimulationSpeed(this.multiplier, this.label);

  final double multiplier;
  final String label;
}

/// Mantém o relógio virtual usado por toda a simulação.
class SimulationController extends ChangeNotifier {
  Duration? _lastFrame;
  double _elapsedSeconds = 0;
  bool _isPaused = false;
  SimulationSpeed _speed = SimulationSpeed.normal;

  double get elapsedSeconds => _elapsedSeconds;
  bool get isPaused => _isPaused;
  SimulationSpeed get speed => _speed;

  /// Avança o relógio virtual usando o tempo fornecido pelo renderizador.
  void tick(Duration elapsed) {
    final previousFrame = _lastFrame;
    _lastFrame = elapsed;

    if (_isPaused || previousFrame == null) return;

    final delta = elapsed - previousFrame;
    if (delta.isNegative) return;

    _elapsedSeconds +=
        delta.inMicroseconds /
        Duration.microsecondsPerSecond *
        _speed.multiplier;
  }

  void togglePause() {
    _isPaused = !_isPaused;
    notifyListeners();
  }

  void setSpeed(SimulationSpeed speed) {
    if (_speed == speed) return;

    _speed = speed;
    notifyListeners();
  }

  void reset() {
    _elapsedSeconds = 0;
    _lastFrame = null;
    notifyListeners();
  }
}
