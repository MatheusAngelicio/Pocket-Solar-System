import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_layout.dart';
import '../application/simulation_controller.dart';
import '../application/solar_system_camera_controller.dart';
import '../domain/celestial_body.dart';
import '../domain/celestial_body_id.dart';
import '../rendering/scene_color_mapper.dart';

class SolarSystemSceneWidget extends StatefulWidget {
  const SolarSystemSceneWidget({
    super.key,
    required this.bodies,
    required this.simulation,
    required this.cameraController,
    required this.onBodySelected,
  });

  final List<CelestialBody> bodies;
  final SimulationController simulation;
  final SolarSystemCameraController cameraController;
  final ValueChanged<CelestialBody> onBodySelected;

  @override
  State<SolarSystemSceneWidget> createState() => _SolarSystemSceneState();
}

class _SolarSystemSceneState extends State<SolarSystemSceneWidget> {
  static const _overviewDistance = 25.0;
  static const _minimumCameraDistance = 2.5;
  static const _maximumCameraDistance = 40.0;
  static const _minimumCameraPolar = 0.18;
  static const _maximumCameraPolar = 1.15;

  final Scene scene = Scene();
  final Map<CelestialBodyId, Node> _nodes = {};
  final Map<CelestialBodyId, Node> _visualNodes = {};
  final Map<Node, CelestialBody> _bodiesByNode = {};
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

        if (body.orbitAround == null) {
          material
            ..emissiveFactor = SceneColorMapper.toLinearVector4(body.color)
            ..emissiveStrength = 1.5;
        }

        final visualNode = Node(
          name: body.name,
          mesh: Mesh(SphereGeometry(radius: body.radius), material),
        );
        final orbitNode = Node(name: '${body.name} órbita')..add(visualNode);
        _nodes[body.id] = orbitNode;
        _visualNodes[body.id] = visualNode;
        _bodiesByNode[visualNode] = body;

        if (body.ring case final ring?) {
          visualNode.add(_createPlanetaryRing(ring));
        }
      }

      for (final body in widget.bodies) {
        final node = _nodes[body.id]!;
        node.position = _orbitPosition(body, 0);

        if (body.orbitAround case final parentId?) {
          final parent = _nodes[parentId];
          if (parent == null) {
            throw StateError('Corpo-pai ausente para ${body.name}.');
          }
          parent.add(node);
        } else {
          scene.add(node);
        }
      }

      for (final body in widget.bodies) {
        if (body.orbitAround case final parentId?) {
          _nodes[parentId]!.add(_createOrbitTrail(body));
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
      body.orbitRadius * math.cos(angle),
      0,
      body.orbitRadius * math.sin(angle),
    );
  }

  Node _createOrbitTrail(CelestialBody body) {
    final material = UnlitMaterial()
      ..baseColorFactor = SceneColorMapper.toLinearVector4(
        body.color.withValues(alpha: 0.22),
      )
      ..alphaMode = AlphaMode.blend;

    return _createDoubleSidedRing(
      name: 'Órbita ${body.name}',
      innerRadius: body.orbitRadius - 0.018,
      outerRadius: body.orbitRadius + 0.018,
      material: material,
    );
  }

  Node _createPlanetaryRing(CelestialRing ring) {
    final material = UnlitMaterial()
      ..baseColorFactor = SceneColorMapper.toLinearVector4(ring.color)
      ..alphaMode = AlphaMode.blend;

    return _createDoubleSidedRing(
      name: 'Anéis',
      innerRadius: ring.innerRadius,
      outerRadius: ring.outerRadius,
      material: material,
      tiltRadians: ring.tiltRadians,
    );
  }

  Node _createDoubleSidedRing({
    required String name,
    required double innerRadius,
    required double outerRadius,
    required UnlitMaterial material,
    double tiltRadians = 0,
  }) {
    final geometry = RingGeometry(
      innerRadius: innerRadius,
      outerRadius: outerRadius,
      segments: 96,
    );
    final ring = Node(name: name)
      ..rotation = vm.Quaternion.axisAngle(vm.Vector3(1, 0, 0), tiltRadians);
    final frontFace = Node(mesh: Mesh(geometry, material))
      ..castsShadows = false
      ..raycastable = false;
    final backFace = Node(mesh: Mesh(geometry, material))
      ..rotation = vm.Quaternion.axisAngle(vm.Vector3(1, 0, 0), math.pi)
      ..castsShadows = false
      ..raycastable = false;

    ring
      ..add(frontFace)
      ..add(backFace);
    return ring;
  }

  OrbitCameraController _createOrbitCamera() {
    return OrbitCameraController(
      target: vm.Vector3.zero(),
      distance: _overviewDistance,
      polar: 0.3,
      minDistance: _minimumCameraDistance,
      maxDistance: _maximumCameraDistance,
      minPolar: _minimumCameraPolar,
      maxPolar: _maximumCameraPolar,
      panSpeed: 0,
      smoothing: 0.16,
    );
  }

  void _onCameraRequest() {
    if (!_isReady) return;

    final bodyId = widget.cameraController.focusedBodyId;
    if (bodyId == null) {
      _restoreOverview();
      return;
    }

    _focusOnBody(bodyId);
  }

  void _onSimulationChanged() {
    final isPaused = widget.simulation.isPaused;
    if (_wasSimulationPaused && !isPaused) {
      widget.cameraController.showOverview();
    }
    _wasSimulationPaused = isPaused;
  }

  void _focusOnBody(CelestialBodyId bodyId) {
    final node = _nodes[bodyId];
    final visualNode = _visualNodes[bodyId];
    final body = widget.bodies.where((body) => body.id == bodyId).firstOrNull;
    if (node == null || visualNode == null || body == null) return;

    _selectedNode?.highlightColor = null;
    _selectedNode = visualNode..highlightColor = vm.Vector4(1, 0.82, 0.3, 1);

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
    final hit = scene.raycast(ray, where: _bodiesByNode.containsKey);
    final body = hit == null ? null : _bodiesByNode[hit.node];
    if (body != null) {
      widget.simulation.pause();
      widget.cameraController.focusOn(body.id);
      widget.onBodySelected(body);
    }
  }

  void _animate(Duration elapsed) {
    widget.simulation.tick(elapsed);
    final elapsedSeconds = widget.simulation.elapsedSeconds;

    for (final body in widget.bodies) {
      final node = _nodes[body.id];
      final visualNode = _visualNodes[body.id];
      if (node == null || visualNode == null) continue;

      visualNode.rotation = vm.Quaternion.axisAngle(
        vm.Vector3(0, 1, 0),
        elapsedSeconds * body.rotationSpeed,
      );

      if (body.orbitAround != null) {
        node.position = _orbitPosition(body, elapsedSeconds);
      }
    }

    final focusedBodyId = widget.cameraController.focusedBodyId;
    final focusedNode = focusedBodyId == null ? null : _nodes[focusedBodyId];
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
