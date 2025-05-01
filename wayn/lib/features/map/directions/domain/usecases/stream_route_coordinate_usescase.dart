import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:wayn/features/map/directions/domain/entities/route_coordinate.dart';
import 'package:wayn/features/map/directions/domain/repositories/direction_repository.dart';

class StreamRouteCoordinateUsescase {
  final DirectionsRepository repository;

  StreamRouteCoordinateUsescase(this.repository);

  Stream<RouteCoordinates> execute(Point origin, Point destination) {
    return repository.streamRouteCoordinates(origin, destination);
  }
}
