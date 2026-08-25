// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_solar_system/features/solar_system/application/simulation_controller.dart';
import 'package:pocket_solar_system/features/solar_system/data/solar_system_data.dart';

void main() {
  test('creates the expected initial celestial bodies', () {
    final bodies = createInitialSolarSystem();

    expect(bodies.map((body) => body.name), ['Sol', 'Terra', 'Lua', 'Marte']);
    expect(
      bodies.singleWhere((body) => body.name == 'Lua').distanceFromSun,
      0.8,
    );
  });

  test('advances the virtual clock according to its selected speed', () {
    final controller = SimulationController();

    controller.tick(const Duration(seconds: 1));
    controller.tick(const Duration(seconds: 3));
    expect(controller.elapsedSeconds, 2);

    controller.setSpeed(SimulationSpeed.fast);
    controller.tick(const Duration(seconds: 4));
    expect(controller.elapsedSeconds, 12);
  });

  test('does not advance while paused', () {
    final controller = SimulationController();

    controller.tick(const Duration(seconds: 1));
    controller.togglePause();
    controller.tick(const Duration(seconds: 3));

    expect(controller.elapsedSeconds, 0);
  });
}
