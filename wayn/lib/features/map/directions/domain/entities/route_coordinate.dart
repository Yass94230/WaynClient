import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class RouteCoordinates {
  final List<Position> coordinates;
  final double duration;
  final double distance;
  bool? isArrived;

  RouteCoordinates({
    required this.coordinates,
    required this.duration,
    required this.distance,
    this.isArrived,
  });
}
