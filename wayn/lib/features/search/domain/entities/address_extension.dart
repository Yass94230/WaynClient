// lib/features/search/domain/entities/address_extension.dart

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:wayn/features/search/domain/entities/address.dart';

extension AddressX on Address {
  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'mainText': mainText,
      'secondaryText': secondaryText,
      'coordinates': {
        'latitude': coordinates.coordinates.lat,
        'longitude': coordinates.coordinates.lng,
      },
    };
  }

  static Address fromJson(Map<String, dynamic> json) {
    final coordinatesMap = json['coordinates'] as Map<String, dynamic>;

    return Address(
      placeId: json['placeId'] as String,
      mainText: json['mainText'] as String,
      secondaryText: json['secondaryText'] as String,
      coordinates: Point(
        coordinates: Position(
          coordinatesMap['latitude'] as double,
          coordinatesMap['longitude'] as double,
        ),
      ),
    );
  }

  // Méthode utilitaire pour créer une Address depuis lat/lng
  static Address fromLatLng(
    double lat,
    double lng, {
    required String placeId,
    required String mainText,
    required String secondaryText,
  }) {
    return Address(
      placeId: placeId,
      mainText: mainText,
      secondaryText: secondaryText,
      coordinates: Point(
        coordinates: Position(lat, lng),
      ),
    );
  }

  // Méthode utilitaire pour obtenir une représentation textuelle complète
  String get formattedAddress => '$mainText, $secondaryText';
}

// Extension pour faciliter la manipulation des coordonnées Point de Mapbox
extension PointX on Point {
  Map<String, dynamic> toJson() {
    return {
      'latitude': coordinates.lat,
      'longitude': coordinates.lng,
    };
  }

  static Point fromJson(Map<String, dynamic> json) {
    return Point(
      coordinates: Position(
        json['latitude'] as double,
        json['longitude'] as double,
      ),
    );
  }
}
