// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pocket_solar_system/features/solar_system/application/simulation_controller.dart';
import 'package:pocket_solar_system/features/solar_system/application/solar_system_camera_controller.dart';
import 'package:pocket_solar_system/features/solar_system/application/solar_system_quality_controller.dart';
import 'package:pocket_solar_system/features/solar_system/data/solar_system_colors.dart';
import 'package:pocket_solar_system/features/solar_system/data/solar_system_data.dart';
import 'package:pocket_solar_system/features/solar_system/domain/celestial_body_id.dart';
import 'package:pocket_solar_system/features/solar_system/domain/celestial_body_information.dart';
import 'package:pocket_solar_system/features/solar_system/domain/celestial_surface.dart';
import 'package:pocket_solar_system/features/solar_system/widgets/celestial_body_actions_widget.dart';
import 'package:pocket_solar_system/features/solar_system/widgets/gesture_tutorial_widget.dart';

void main() {
  test('creates the expected initial celestial bodies', () {
    final bodies = createInitialSolarSystem();

    expect(bodies, hasLength(10));
    expect(
      bodies.map((body) => body.name),
      containsAll([
        'Sun',
        'Mercury',
        'Venus',
        'Earth',
        'Moon',
        'Marte',
        'Jupiter',
        'Saturn',
        'Uranus',
        'Neptune',
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
      bodies
          .singleWhere((body) => body.id == CelestialBodyId.earth)
          .information
          .type,
      CelestialBodyType.terrestrialPlanet,
    );
    expect(
      bodies.singleWhere((body) => body.id == CelestialBodyId.earth).color,
      SolarSystemColors.earth,
    );
    expect(
      bodies.singleWhere((body) => body.id == CelestialBodyId.jupiter).surface,
      CelestialSurface.gaseous,
    );

    final bodyIds = bodies.map((body) => body.id).toSet();
    for (final body in bodies) {
      expect(
        body.orbitAround == null || bodyIds.contains(body.orbitAround),
        isTrue,
      );
    }
    expect(
      bodies.where((body) => body.orbitAround == null).single.id,
      CelestialBodyId.sun,
    );

    for (final body in bodies) {
      final visited = <CelestialBodyId>{body.id};
      var current = body;
      while (current.orbitAround != null) {
        final parentId = current.orbitAround!;
        expect(
          visited.add(parentId),
          isTrue,
          reason: 'An orbit cannot form a cycle.',
        );
        current = bodies.singleWhere((candidate) => candidate.id == parentId);
      }
    }
  });

  test('advances the virtual clock according to its selected speed', () {
    final controller = SimulationController();

    controller.tick(const Duration(seconds: 1));
    controller.tick(const Duration(seconds: 3));
    expect(controller.elapsedSeconds, 2);

    controller.setSpeed(SimulationSpeed.fast);
    controller.tick(const Duration(seconds: 4));
    expect(controller.elapsedSeconds, 12);

    controller.tick(const Duration(seconds: 2));
    expect(controller.elapsedSeconds, 12);

    controller.tick(const Duration(seconds: 5));
    expect(controller.elapsedSeconds, 22);

    controller.reset();
    expect(controller.elapsedSeconds, 0);
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

  test('switches between balanced and performance rendering profiles', () {
    final controller = SolarSystemQualityController();

    expect(controller.quality, SolarSystemQuality.balanced);
    expect(controller.quality.bloomEnabled, isTrue);

    controller.setQuality(SolarSystemQuality.performance);
    expect(controller.quality.bloomEnabled, isFalse);
  });

  testWidgets('shows the gesture tutorial only until it is dismissed', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Stack(children: [GestureTutorialWidget()])),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Explore the Solar System'), findsOneWidget);
    await tester.tap(find.text('Start exploring'));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool(GestureTutorialWidget.preferenceKey), isTrue);
    expect(find.text('Explore the Solar System'), findsNothing);
  });

  testWidgets('selects a celestial body through the accessible list', (
    tester,
  ) async {
    final bodies = createInitialSolarSystem();
    final simulation = SimulationController();
    final camera = SolarSystemCameraController();
    CelestialBodyId? selectedBodyId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CelestialBodyActionsWidget(
            bodies: bodies,
            simulation: simulation,
            cameraController: camera,
            onBodySelected: (body) => selectedBodyId = body.id,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Select a celestial body'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Earth'));
    await tester.pumpAndSettle();

    expect(simulation.isPaused, isTrue);
    expect(camera.focusedBodyId, CelestialBodyId.earth);
    expect(selectedBodyId, CelestialBodyId.earth);
  });
}
