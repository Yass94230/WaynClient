// lib/features/ride/data/models/ride_request_model.dart

import 'dart:developer' as l;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:wayn/features/authentification/data/models/user_model.dart';
import 'package:wayn/features/authentification/domain/entities/user.dart';
import 'package:wayn/features/ride/domain/entities/ride_status.dart';
import 'package:wayn/features/ride/domain/entities/ride_id_generator.dart';

class RideRequestModel {
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

  RideRequestModel({
    required this.id,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.grossPrice,
    required this.timeToPickup,
    required this.totalRideTime,
    required this.distance,
    required this.origin,
    required this.destination,
    this.status = RideStatus.created,
    required this.user,
    DateTime? createdAt,
  })  : netPrice = grossPrice * 0.75,
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(), // Conversion du RideIdGenerator en String
      'pickupAddress': pickupAddress,
      'destinationAddress': destinationAddress,
      'grossPrice': grossPrice,
      'netPrice': netPrice,
      'timeToPickup': timeToPickup.inSeconds,
      'totalRideTime': totalRideTime.inSeconds,
      'distance': distance,
      'createdAt': createdAt.toIso8601String(),
      'status': status.toJson(),
      'origin': [origin.lng, origin.lat],
      'destination': [destination.lng, destination.lat],
      'user': user is UserModel
          ? (user as UserModel).toMap()
          : UserModel(
              id: user.id,
              email: user.email,
              phoneNumber: user.phoneNumber,
              firstName: user.firstName,
              lastName: user.lastName,
              sexe: user.sexe,
              choices: user.choices,
              firebaseToken: user.firebaseToken,
              stripeId: user.stripeId,
              createdAt: user.createdAt,
            ).toMap(),
    };
  }

  factory RideRequestModel.fromJson(Map<String, dynamic> json) {
    final createdAtData = json['createdAt'];
    final DateTime createdAt;

    if (createdAtData is Timestamp) {
      createdAt = createdAtData.toDate();
    } else if (createdAtData is String) {
      createdAt = DateTime.parse(createdAtData);
    } else {
      throw const FormatException('Format de date invalide pour createdAt');
    }

    final statusData = json['status'];
    final RideStatus status;
    try {
      status = RideStatusX.fromJson(statusData);
    } catch (e) {
      l.log('Erreur lors du parsing du status: $statusData');
      rethrow;
    }

    final userData = json['user'] as Map<String, dynamic>;
    final userId = userData['id'] as String;
    final user = UserModel.fromFirestore(userData, userId);

    // Fonction pour gérer les coordonnées qui peuvent être soit GeoPoint soit List
    Position getPosition(dynamic coordData) {
      if (coordData is GeoPoint) {
        return Position(coordData.longitude, coordData.latitude);
      } else if (coordData is List) {
        return Position(
          (coordData[0] as num).toDouble(),
          (coordData[1] as num).toDouble(),
        );
      } else {
        throw FormatException('Format de coordonnées invalide: $coordData');
      }
    }

    final originData = json['origin'];
    final destinationData = json['destination'];

    return RideRequestModel(
      id: RideIdGenerator.fromString(json['id'] as String),
      pickupAddress: json['pickupAddress'] as String,
      destinationAddress: json['destinationAddress'] as String,
      grossPrice: (json['grossPrice'] as num).toDouble(),
      timeToPickup: Duration(seconds: json['timeToPickup'] as int),
      totalRideTime: Duration(seconds: json['totalRideTime'] as int),
      distance: (json['distance'] as num).toDouble(),
      createdAt: createdAt,
      status: status,
      user: user,
      origin: getPosition(originData),
      destination: getPosition(destinationData),
    );
  }

  RideRequestModel copyWith({
    RideIdGenerator? id,
    String? pickupAddress,
    String? destinationAddress,
    double? grossPrice,
    double? netPrice,
    Duration? timeToPickup,
    Duration? totalRideTime,
    double? distance,
    DateTime? createdAt,
    RideStatus? status,
    User? user,
    Position? origin,
    Position? destination,
  }) {
    return RideRequestModel(
      id: id ?? this.id,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      grossPrice: grossPrice ?? this.grossPrice,
      timeToPickup: timeToPickup ?? this.timeToPickup,
      totalRideTime: totalRideTime ?? this.totalRideTime,
      distance: distance ?? this.distance,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      user: user ?? this.user,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
    );
  }
}
