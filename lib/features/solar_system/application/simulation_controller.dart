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

/// Maintains the virtual clock used by the entire simulation.
class SimulationController extends ChangeNotifier {
  Duration? _lastFrame;
  double _elapsedSeconds = 0;
  bool _isPaused = false;
  SimulationSpeed _speed = SimulationSpeed.normal;

  double get elapsedSeconds => _elapsedSeconds;
  bool get isPaused => _isPaused;
  SimulationSpeed get speed => _speed;

  /// Advances the virtual clock using the time supplied by the renderer.
  void tick(Duration elapsed) {
    final previousFrame = _lastFrame;
    if (previousFrame == null) {
      _lastFrame = elapsed;
      return;
    }

    final delta = elapsed - previousFrame;
    if (delta.isNegative) return;

    _lastFrame = elapsed;
    if (_isPaused) return;

    _elapsedSeconds +=
        delta.inMicroseconds /
        Duration.microsecondsPerSecond *
        _speed.multiplier;
  }

  void togglePause() {
    if (_isPaused) {
      resume();
    } else {
      pause();
    }
  }

  void pause() {
    if (_isPaused) return;

    _isPaused = true;
    notifyListeners();
  }

  void resume() {
    if (!_isPaused) return;

    _isPaused = false;
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
