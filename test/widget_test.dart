// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

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
}
