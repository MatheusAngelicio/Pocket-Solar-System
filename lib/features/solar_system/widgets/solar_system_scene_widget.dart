import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_layout.dart';
import '../application/simulation_controller.dart';
import '../domain/celestial_body.dart';
import 'scene_color_mapper.dart';

class SolarSystemSceneWidget extends StatefulWidget {
  const SolarSystemSceneWidget({
    super.key,
    required this.bodies,
    required this.simulation,
  });

  final List<CelestialBody> bodies;
  final SimulationController simulation;

  @override
  State<SolarSystemSceneWidget> createState() => _SolarSystemSceneState();
}

class _SolarSystemSceneState extends State<SolarSystemSceneWidget> {
  final Scene scene = Scene();
  final Map<String, Node> _nodes = {};
  bool _isReady = false;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _loadScene();
  }

  Future<void> _loadScene() async {
    try {
      await Scene.initializeStaticResources();

      for (final body in widget.bodies) {
        final material = PhysicallyBasedMaterial()
          ..baseColorFactor = SceneColorMapper.toLinearVector4(body.color)
          ..metallicFactor = 0
          ..roughnessFactor = 0.8;

        if (body.distanceFromSun == 0) {
          material
            ..emissiveFactor = SceneColorMapper.toLinearVector4(body.color)
            ..emissiveStrength = 1.5;
        }

        _nodes[body.name] = Node(
          name: body.name,
          mesh: Mesh(SphereGeometry(radius: body.radius), material),
        );
      }

      for (final body in widget.bodies) {
        final node = _nodes[body.name]!;
        node.position = _orbitPosition(body, 0);

        if (body.name == 'Lua' && _nodes['Terra'] != null) {
          _nodes['Terra']!.add(node);
        } else {
          scene.add(node);
        }
      }

      if (mounted) {
        setState(() => _isReady = true);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _loadError = error);
      }
    }
  }

  vm.Vector3 _orbitPosition(CelestialBody body, double elapsedSeconds) {
    final angle = body.initialOrbitAngle + elapsedSeconds * body.orbitSpeed;
    return vm.Vector3(
      body.distanceFromSun * math.cos(angle),
      0,
      body.distanceFromSun * math.sin(angle),
    );
  }

  void _animate(Duration elapsed) {
    widget.simulation.tick(elapsed);
    final elapsedSeconds = widget.simulation.elapsedSeconds;

    for (final body in widget.bodies) {
      final node = _nodes[body.name];
      if (node == null) continue;

      node.rotation = vm.Quaternion.axisAngle(
        vm.Vector3(0, 1, 0),
        elapsedSeconds * body.rotationSpeed,
      );

      if (body.distanceFromSun > 0) {
        node.position = _orbitPosition(body, elapsedSeconds);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadError != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.lg),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.card,
          ),
          child: Text(
            'Não foi possível carregar a cena 3D: $_loadError',
            style: const TextStyle(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (!_isReady) {
      return const Center(child: CircularProgressIndicator());
    }

    return ColoredBox(
      color: AppColors.space,
      child: SceneView(
        scene,
        camera: PerspectiveCamera(
          position: vm.Vector3(0, 4.5, -15),
          target: vm.Vector3.zero(),
        ),
        onTick: (elapsed, _) => _animate(elapsed),
      ),
    );
  }
}
