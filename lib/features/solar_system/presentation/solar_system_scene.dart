import 'package:flutter/material.dart';

import '../domain/celestial_body.dart';

class SolarSystemScene extends StatelessWidget {
  const SolarSystemScene({super.key, required this.bodies});

  final List<CelestialBody> bodies;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand();
  }
}
