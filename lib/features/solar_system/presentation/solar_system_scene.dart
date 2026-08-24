import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_layout.dart';
import '../domain/celestial_body.dart';

class SolarSystemScene extends StatefulWidget {
  const SolarSystemScene({super.key, required this.bodies});

  final List<CelestialBody> bodies;

  @override
  State<SolarSystemScene> createState() => _SolarSystemSceneState();
}

class _SolarSystemSceneState extends State<SolarSystemScene> {
  final Scene scene = Scene();
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

      final nodes = <String, Node>{};
      for (final body in widget.bodies) {
        final material = PhysicallyBasedMaterial()
          ..baseColorFactor = _colorFromHex(body.colorHex)
          ..metallicFactor = 0
          ..roughnessFactor = 0.8;

        if (body.distanceFromSun == 0) {
          material
            ..emissiveFactor = _colorFromHex(body.colorHex)
            ..emissiveStrength = 1.5;
        }

        nodes[body.name] = Node(
          name: body.name,
          mesh: Mesh(SphereGeometry(radius: body.radius), material),
        );
      }

      for (final body in widget.bodies) {
        final node = nodes[body.name]!;
        node.position = vm.Vector3(body.distanceFromSun, 0, 0);

        if (body.name == 'Lua' && nodes['Terra'] != null) {
          nodes['Terra']!.add(node);
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

  vm.Vector4 _colorFromHex(int colorHex) {
    return vm.Vector4(
      ((colorHex >> 16) & 0xFF) / 255,
      ((colorHex >> 8) & 0xFF) / 255,
      (colorHex & 0xFF) / 255,
      ((colorHex >> 24) & 0xFF) / 255,
    );
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
      ),
    );
  }
}
