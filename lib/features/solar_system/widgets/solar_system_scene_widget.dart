import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_layout.dart';
import '../application/simulation_controller.dart';
import '../application/solar_system_camera_controller.dart';
import '../domain/celestial_body.dart';
import '../rendering/scene_color_mapper.dart';

class SolarSystemSceneWidget extends StatefulWidget {
  const SolarSystemSceneWidget({
    super.key,
    required this.bodies,
    required this.simulation,
    required this.cameraController,
  });

  final List<CelestialBody> bodies;
  final SimulationController simulation;
  final SolarSystemCameraController cameraController;

  @override
  State<SolarSystemSceneWidget> createState() => _SolarSystemSceneState();
}

class _SolarSystemSceneState extends State<SolarSystemSceneWidget> {
  static const _overviewDistance = 15.0;
  static const _minimumCameraDistance = 2.5;
  static const _maximumCameraDistance = 24.0;

  final Scene scene = Scene();
  final Map<String, Node> _nodes = {};
  late OrbitCameraController _orbitCamera = _createOrbitCamera();
  late final CameraComponent _cameraComponent = CameraComponent(
    activateOnMount: true,
  );
  late final Node _cameraNode = Node(name: 'Câmera')
    ..addComponent(_cameraComponent)
    ..addComponent(_orbitCamera);
  Node? _selectedNode;
  bool _wasSimulationPaused = false;
  bool _isReady = false;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    widget.cameraController.addListener(_onCameraRequest);
    widget.simulation.addListener(_onSimulationChanged);
    _wasSimulationPaused = widget.simulation.isPaused;
    _loadScene();
  }

  @override
  void didUpdateWidget(covariant SolarSystemSceneWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cameraController != widget.cameraController) {
      oldWidget.cameraController.removeListener(_onCameraRequest);
      widget.cameraController.addListener(_onCameraRequest);
    }

    if (oldWidget.simulation != widget.simulation) {
      oldWidget.simulation.removeListener(_onSimulationChanged);
      widget.simulation.addListener(_onSimulationChanged);
      _wasSimulationPaused = widget.simulation.isPaused;
    }
  }

  @override
  void dispose() {
    widget.cameraController.removeListener(_onCameraRequest);
    widget.simulation.removeListener(_onSimulationChanged);
    super.dispose();
  }

  Future<void> _loadScene() async {
    try {
      await Scene.initializeStaticResources();
      scene.add(_cameraNode);

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
        _onCameraRequest();
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

  OrbitCameraController _createOrbitCamera() {
    return OrbitCameraController(
      target: vm.Vector3.zero(),
      distance: _overviewDistance,
      polar: 0.3,
      minDistance: _minimumCameraDistance,
      maxDistance: _maximumCameraDistance,
      minPolar: -1.2,
      maxPolar: 1.2,
      smoothing: 0.16,
    );
  }

  void _onCameraRequest() {
    if (!_isReady) return;

    final bodyName = widget.cameraController.focusedBodyName;
    if (bodyName == null) {
      _restoreOverview();
      return;
    }

    _focusOnBody(bodyName);
  }

  void _onSimulationChanged() {
    final isPaused = widget.simulation.isPaused;
    if (_wasSimulationPaused && !isPaused) {
      widget.cameraController.showOverview();
    }
    _wasSimulationPaused = isPaused;
  }

  void _focusOnBody(String bodyName) {
    final node = _nodes[bodyName];
    final body = widget.bodies
        .where((body) => body.name == bodyName)
        .firstOrNull;
    if (node == null || body == null) return;

    _selectedNode?.highlightColor = null;
    _selectedNode = node..highlightColor = vm.Vector4(1, 0.82, 0.3, 1);

    final focusPosition = node.globalTransform.getTranslation();
    final focusBounds = vm.Aabb3.minMax(
      focusPosition - vm.Vector3.all(body.radius),
      focusPosition + vm.Vector3.all(body.radius),
    );
    _orbitCamera.frame(focusBounds, margin: 2.5);
  }

  void _restoreOverview() {
    _selectedNode?.highlightColor = null;
    _selectedNode = null;

    if (_orbitCamera.isAttached) {
      _cameraNode.removeComponent(_orbitCamera);
    }
    _orbitCamera = _createOrbitCamera();
    _cameraNode.addComponent(_orbitCamera);
    if (mounted) setState(() {});
  }

  void _selectBody(Offset position, Size viewSize) {
    final ray = _cameraComponent.toCamera().screenPointToRay(
      position,
      viewSize,
    );
    final hit = scene.raycast(ray, where: _nodes.values.contains);
    final bodyName = hit?.node.name;
    if (bodyName != null) {
      widget.simulation.pause();
      widget.cameraController.focusOn(bodyName);
    }
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

    final focusedBodyName = widget.cameraController.focusedBodyName;
    final focusedNode = focusedBodyName == null
        ? null
        : _nodes[focusedBodyName];
    if (focusedNode != null) {
      _orbitCamera.target = focusedNode.globalTransform.getTranslation();
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
      child: CameraControls(
        controller: _orbitCamera,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) =>
                  _selectBody(details.localPosition, constraints.biggest),
              child: SceneView(
                scene,
                onTick: (elapsed, _) => _animate(elapsed),
              ),
            );
          },
        ),
      ),
    );
  }
}
