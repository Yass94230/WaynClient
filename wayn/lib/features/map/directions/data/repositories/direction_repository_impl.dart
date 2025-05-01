import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:wayn/features/map/directions/data/datasources/directions_remote_data_sources.dart';
import 'package:wayn/features/map/directions/domain/entities/route_coordinate.dart';
import 'package:wayn/features/map/directions/domain/repositories/direction_repository.dart';

class DirectionsRepositoryImpl implements DirectionsRepository {
  final DirectionsRemoteDataSource remoteDataSource;

  DirectionsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<RouteCoordinates> getRouteCoordinates(
      Point origin, Point destination) {
    return remoteDataSource.getRouteCoordinates(origin, destination);
  }

  @override
  Stream<RouteCoordinates> streamRouteCoordinates(
      Point origin, Point destination) {
    return remoteDataSource.streamRouteCoordinates(origin, destination);
  }
}
