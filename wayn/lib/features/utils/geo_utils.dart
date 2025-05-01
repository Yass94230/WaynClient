import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class GeoUtils {
  /// Calcule la distance en kilomètres entre deux points géographiques
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371.0; // Rayon de la Terre en kilomètres

    // Conversion en radians
    final lat1Rad = lat1 * pi / 180;
    final lon1Rad = lon1 * pi / 180;
    final lat2Rad = lat2 * pi / 180;
    final lon2Rad = lon2 * pi / 180;

    // Différences
    final dLat = lat2Rad - lat1Rad;
    final dLon = lon2Rad - lon1Rad;

    // Formule haversine
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  /// Calcule les limites approximatives pour une zone de recherche
  static Map<String, GeoPoint> calculateBoundingBox(
    double centerLat,
    double centerLon,
    double radiusInKm,
  ) {
    // Conversion approximative (1 degré = ~111km à l'équateur)
    final latRange = radiusInKm / 111.0;
    final lonRange = radiusInKm / (111.0 * cos(centerLat * pi / 180));

    return {
      'northeast': GeoPoint(
        centerLat + latRange,
        centerLon + lonRange,
      ),
      'southwest': GeoPoint(
        centerLat - latRange,
        centerLon - lonRange,
      ),
    };
  }
}
