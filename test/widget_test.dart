// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_solar_system/features/solar_system/application/simulation_controller.dart';
import 'package:pocket_solar_system/features/solar_system/application/solar_system_camera_controller.dart';
import 'package:pocket_solar_system/features/solar_system/data/solar_system_colors.dart';
import 'package:pocket_solar_system/features/solar_system/data/solar_system_data.dart';
import 'package:pocket_solar_system/features/solar_system/domain/celestial_body_id.dart';

void main() {
  test('creates the expected initial celestial bodies', () {
    final bodies = createInitialSolarSystem();

    expect(bodies, hasLength(10));
    expect(
      bodies.map((body) => body.name),
      containsAll([
        'Sol',
        'Mercúrio',
        'Vênus',
        'Terra',
        'Lua',
        'Marte',
        'Júpiter',
        'Saturno',
        'Urano',
        'Netuno',
      ]),
    );
    expect(
      bodies.singleWhere((body) => body.id == CelestialBodyId.moon).orbitAround,
      CelestialBodyId.earth,
    );
    expect(
      bodies.singleWhere((body) => body.id == CelestialBodyId.saturn).ring,
      isNotNull,
    );
    expect(
      bodies.singleWhere((body) => body.id == CelestialBodyId.earth).color,
      SolarSystemColors.earth,
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
    controller.pause();
    controller.tick(const Duration(seconds: 3));

    expect(controller.elapsedSeconds, 0);

    controller.resume();
    controller.tick(const Duration(seconds: 4));
    expect(controller.elapsedSeconds, 1);
  });

  test('publishes the requested camera focus', () {
    final controller = SolarSystemCameraController();

    controller.focusOn(CelestialBodyId.earth);
    expect(controller.focusedBodyId, CelestialBodyId.earth);

    controller.showOverview();
    expect(controller.focusedBodyId, isNull);
  });
}
