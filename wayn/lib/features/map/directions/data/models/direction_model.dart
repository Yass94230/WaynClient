// lib/features/map/directions/data/models/route_coordinates_model.dart

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:wayn/features/map/directions/domain/entities/route_coordinate.dart';

class RouteCoordinatesModel extends RouteCoordinates {
  RouteCoordinatesModel({
    required super.coordinates,
    required super.duration,
    required super.distance,
  });

  factory RouteCoordinatesModel.fromJson(Map<String, dynamic> json) {
    final routes = json['routes'] as List;
    if (routes.isEmpty) {
      throw Exception('No routes found');
    }
    final route = routes[0];
    final geometry = route['geometry'];

    // Convertir les coordonnées en List<Position>
    final List<Position> coordinates =
        (geometry['coordinates'] as List).map((coord) {
      final list = coord as List;
      return Position(
        (list[0] as num).toDouble(), // longitude
        (list[1] as num).toDouble(), // latitude
      );
    }).toList();

    return RouteCoordinatesModel(
      coordinates: coordinates,
      duration: (route['duration'] as num).toDouble(),
      distance: (route['distance'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coordinates': coordinates.map((pos) => [pos.lng, pos.lat]).toList(),
      'duration': duration,
      'distance': distance,
    };
  }

  factory RouteCoordinatesModel.empty() {
    return RouteCoordinatesModel(
      coordinates: [],
      duration: 0,
      distance: 0,
    );
  }
}
