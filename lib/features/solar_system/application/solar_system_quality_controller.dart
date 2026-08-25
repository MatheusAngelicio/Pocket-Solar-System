import 'package:flutter/foundation.dart';

enum SolarSystemQuality {
  balanced,
  performance;

  String get label => switch (this) {
    SolarSystemQuality.balanced => 'Balanced',
    SolarSystemQuality.performance => 'Performance',
  };

  bool get bloomEnabled => this == SolarSystemQuality.balanced;
}

class SolarSystemQualityController extends ChangeNotifier {
  SolarSystemQuality _quality = SolarSystemQuality.balanced;

  SolarSystemQuality get quality => _quality;

  void setQuality(SolarSystemQuality quality) {
    if (_quality == quality) return;
    _quality = quality;
    notifyListeners();
  }
}
