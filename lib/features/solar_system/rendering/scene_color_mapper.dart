import 'dart:math' as math;
import 'dart:ui';

import 'package:vector_math/vector_math.dart' as vm;

/// Converte cores sRGB da interface em valores lineares para materiais 3D.
abstract final class SceneColorMapper {
  static vm.Vector4 toLinearVector4(Color color) {
    return vm.Vector4(
      _toLinear(color.r),
      _toLinear(color.g),
      _toLinear(color.b),
      color.a,
    );
  }

  static vm.Vector3 toLinearVector3(Color color) {
    final linearColor = toLinearVector4(color);
    return vm.Vector3(linearColor.x, linearColor.y, linearColor.z);
  }

  static double _toLinear(double channel) {
    if (channel <= 0.04045) return channel / 12.92;
    return math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }
}
