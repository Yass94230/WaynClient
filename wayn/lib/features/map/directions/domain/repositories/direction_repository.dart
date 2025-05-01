import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:wayn/features/map/directions/domain/entities/route_coordinate.dart';

abstract class DirectionsRepository {
  Future<RouteCoordinates> getRouteCoordinates(Point origin, Point destination);

  Stream<RouteCoordinates> streamRouteCoordinates(
      Point origin, Point destination);
}
