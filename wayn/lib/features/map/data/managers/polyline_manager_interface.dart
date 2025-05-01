import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

abstract class IPolylineManager {
  Future<void> initialize();
  Future<PolylineAnnotation?> createPolyline(List<Position> coordinates);
  Future<void> removeAll();
}
