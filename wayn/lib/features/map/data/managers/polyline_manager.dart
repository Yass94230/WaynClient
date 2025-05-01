// lib/features/map/data/managers/polyline_manager.dart
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:wayn/features/map/data/managers/polyline_manager_interface.dart';

class PolylineManager implements IPolylineManager {
  PolylineAnnotationManager? _manager;

  final MapboxMap mapController;

  PolylineManager(this.mapController);

  @override
  Future<void> initialize() async {
    _manager ??=
        await mapController.annotations.createPolylineAnnotationManager();
  }

  @override
  Future<PolylineAnnotation?> createPolyline(List<Position> coordinates) async {
    if (_manager == null) {
      await initialize();
    }
    return await _manager?.create(
      PolylineAnnotationOptions(
        geometry: LineString(coordinates: coordinates),
        lineColor: 0xFF0081FF,
        lineWidth: 4.0,
        lineOpacity: 0.7,
      ),
    );
  }

  @override
  Future<void> removeAll() async {
    await _manager?.deleteAll();
  }
}
