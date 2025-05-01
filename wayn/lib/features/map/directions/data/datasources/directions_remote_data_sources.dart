import 'dart:developer';

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:wayn/features/core/config/mapbox_config.dart';
import 'package:wayn/features/map/directions/data/models/direction_model.dart';

// lib/features/map/directions/data/datasources/directions_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:wayn/features/map/directions/domain/entities/route_coordinate.dart';

abstract class DirectionsRemoteDataSource {
  Future<RouteCoordinatesModel> getRouteCoordinates(
      Point origin, Point destination);

  Stream<RouteCoordinates> streamRouteCoordinates(
      Point origin, Point destination);
}

class DirectionsRemoteDataSourceImpl implements DirectionsRemoteDataSource {
  final Dio dio;

  DirectionsRemoteDataSourceImpl({required this.dio});

  @override
  Future<RouteCoordinatesModel> getRouteCoordinates(
      Point origin, Point destination) async {
    try {
      final url = 'https://api.mapbox.com/directions/v5/mapbox/driving-traffic/'
          '${origin.coordinates.lng},${origin.coordinates.lat};'
          '${destination.coordinates.lng},${destination.coordinates.lat}';

      final response = await dio.get(
        url,
        queryParameters: {
          'geometries': 'geojson',
          'overview': 'full', // pour avoir tous les points de l'itinéraire
          'steps': 'true', // pour avoir les étapes détaillées
          'access_token': MapboxConfig.accessToken,
        },
      );

      if (response.statusCode == 200) {
        return RouteCoordinatesModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          error: 'Failed to load route',
        );
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to load route');
    }
  }

  @override
  Stream<RouteCoordinatesModel> streamRouteCoordinates(
    Point origin,
    Point destination,
  ) async* {
    while (true) {
      try {
        final url =
            'https://api.mapbox.com/directions/v5/mapbox/driving-traffic/'
            '${origin.coordinates.lng},${origin.coordinates.lat};'
            '${destination.coordinates.lng},${destination.coordinates.lat}';

        final response = await dio.get(
          url,
          queryParameters: {
            'geometries': 'geojson',
            'overview': 'full',
            'steps': 'true',
            'access_token': MapboxConfig.accessToken,
            'annotations': 'distance,duration',
          },
        );

        if (response.statusCode == 200) {
          final route = RouteCoordinatesModel.fromJson(response.data);
          final distance = route.distance; // distance en mètres

          // Log pour debug
          log('Distance actuelle: $distance mètres');

          // Simple vérification de distance avec un seuil de 100m
          if (distance <= 100.0) {
            route.isArrived = true;
            log('ARRIVÉE DÉTECTÉE - Distance <= 100m');
          }

          yield route;
        } else {
          throw DioException(
            requestOptions: response.requestOptions,
            error: 'Failed to load route',
          );
        }

        await Future.delayed(const Duration(seconds: 15));
      } on DioException catch (e) {
        log('Erreur lors de la récupération de la route: ${e.message}');
        await Future.delayed(const Duration(seconds: 5));
      }
    }
  }

  // @override
  // Stream<RouteCoordinatesModel> streamRouteCoordinates(
  //   Point origin,
  //   Point destination,
  // ) async* {
  //   const updateInterval = Duration(seconds: 15);
  //   const errorRetryInterval = Duration(seconds: 5);

  //   while (true) {
  //     try {
  //       final url =
  //           'https://api.mapbox.com/directions/v5/mapbox/driving-traffic/'
  //           '${origin.coordinates.lng},${origin.coordinates.lat};'
  //           '${destination.coordinates.lng},${destination.coordinates.lat}';

  //       final response = await dio.get(
  //         url,
  //         queryParameters: {
  //           'geometries': 'geojson',
  //           'overview': 'full',
  //           'steps': 'true',
  //           'annotations': 'distance,duration', // Ajout des annotations
  //           'access_token': MapboxConfig.accessToken,
  //         },
  //       );

  //       if (response.statusCode == 200) {
  //         yield RouteCoordinatesModel.fromJson(response.data);
  //         await Future.delayed(updateInterval);
  //       } else {
  //         throw DioException(
  //           requestOptions: response.requestOptions,
  //           error: 'Failed to load route',
  //         );
  //       }
  //     } on DioException catch (e) {
  //       log('Erreur lors de la récupération de la route: ${e.message}');
  //       await Future.delayed(errorRetryInterval);
  //     } on Exception catch (e) {
  //       log('Erreur inattendue: $e');
  //       await Future.delayed(errorRetryInterval);
  //     }
  //   }
  // }
}
