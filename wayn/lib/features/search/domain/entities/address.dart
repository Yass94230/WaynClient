// lib/features/search/domain/entities/address.dart
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class Address {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final Point coordinates;

  Address({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    Point? coordinates, // Valeur par défaut
  }) : coordinates = coordinates ?? Point(coordinates: Position(0.0, 0.0));

  Address copyWith({
    String? placeId,
    String? mainText,
    String? secondaryText,
    Point? coordinates,
  }) {
    return Address(
      placeId: placeId ?? this.placeId,
      mainText: mainText ?? this.mainText,
      secondaryText: secondaryText ?? this.secondaryText,
      coordinates: coordinates ?? this.coordinates,
    );
  }

  // Pour faciliter le debugging
  @override
  String toString() {
    return 'Address(placeId: $placeId, mainText: $mainText, secondaryText: $secondaryText, coordinates: (${coordinates.coordinates.lng}, ${coordinates.coordinates.lat}))';
  }

  // Pour les comparaisons
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Address &&
        other.placeId == placeId &&
        other.mainText == mainText &&
        other.secondaryText == secondaryText &&
        other.coordinates.coordinates.lng == coordinates.coordinates.lng &&
        other.coordinates.coordinates.lat == coordinates.coordinates.lat;
  }

  @override
  int get hashCode {
    return placeId.hashCode ^
        mainText.hashCode ^
        secondaryText.hashCode ^
        coordinates.coordinates.lng.hashCode ^
        coordinates.coordinates.lat.hashCode;
  }

  // Méthodes utilitaires pour obtenir la latitude et longitude séparément
  double get latitude => coordinates.coordinates.lat as double;
  double get longitude => coordinates.coordinates.lng as double;
}
