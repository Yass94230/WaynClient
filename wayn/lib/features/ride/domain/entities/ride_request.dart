// lib/features/ride/domain/entities/ride_request.dart

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:wayn/features/authentification/domain/entities/user.dart';
import 'package:wayn/features/ride/data/models/ride_request_model.dart';
import 'package:wayn/features/ride/domain/entities/ride_id_generator.dart';
import 'package:wayn/features/ride/domain/entities/ride_status.dart';

class RideRequest {
  final RideIdGenerator id;
  final String pickupAddress;
  final String destinationAddress;
  final double grossPrice;
  final double netPrice;
  final Duration timeToPickup;
  final Duration totalRideTime;
  final double distance;
  final DateTime createdAt;
  final Position origin;
  final Position destination;
  final RideStatus status;
  final User user;

  const RideRequest({
    required this.id,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.grossPrice,
    required this.netPrice,
    required this.timeToPickup,
    required this.totalRideTime,
    required this.distance,
    required this.createdAt,
    required this.origin,
    required this.destination,
    required this.status,
    required this.user,
  });

  // Pour faciliter la comparaison des entités
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RideRequest &&
        other.id == id &&
        other.pickupAddress == pickupAddress &&
        other.destinationAddress == destinationAddress &&
        other.grossPrice == grossPrice &&
        other.netPrice == netPrice &&
        other.timeToPickup == timeToPickup &&
        other.totalRideTime == totalRideTime &&
        other.distance == distance &&
        other.createdAt == createdAt &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        pickupAddress.hashCode ^
        destinationAddress.hashCode ^
        grossPrice.hashCode ^
        netPrice.hashCode ^
        timeToPickup.hashCode ^
        totalRideTime.hashCode ^
        distance.hashCode ^
        createdAt.hashCode ^
        status.hashCode;
  }
}

// lib/features/ride/data/models/ride_request_model.dart

// Ajoutez cette extension à votre RideRequestModel
extension RideRequestModelX on RideRequestModel {
  RideRequest toDomain() {
    return RideRequest(
      id: id,
      pickupAddress: pickupAddress,
      destinationAddress: destinationAddress,
      grossPrice: grossPrice,
      netPrice: netPrice,
      timeToPickup: timeToPickup,
      totalRideTime: totalRideTime,
      distance: distance,
      createdAt: createdAt,
      status: status,
      origin: origin,
      destination: destination,
      user: user,
    );
  }
}

// Extension optionnelle pour convertir de l'entité vers le modèle si nécessaire
extension RideRequestX on RideRequest {
  RideRequestModel toModel() {
    return RideRequestModel(
      id: id,
      pickupAddress: pickupAddress,
      destinationAddress: destinationAddress,
      grossPrice: grossPrice,
      timeToPickup: timeToPickup,
      totalRideTime: totalRideTime,
      distance: distance,
      createdAt: createdAt,
      status: status,
      user: user,
      origin: origin,
      destination: destination,
    );
  }
}
