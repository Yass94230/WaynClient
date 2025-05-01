// ride_confirmation_state.dart

import 'package:equatable/equatable.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:wayn/features/map/domain/entities/driver.dart';
import 'package:wayn/features/ride/domain/entities/ride_request.dart';

abstract class RideConfirmationState extends Equatable {
  const RideConfirmationState();

  @override
  List<Object?> get props => [];
}

// État initial
class RideConfirmationInitial extends RideConfirmationState {}

// État pendant la recherche des drivers
class SearchingDrivers extends RideConfirmationState {
  final List<Driver> availableDrivers;
  final String vehicleType;
  final int remainingTimeInSeconds;
  final RideRequest rideRequest; // Ajout du rideRequest

  const SearchingDrivers({
    required this.availableDrivers,
    required this.vehicleType,
    required this.remainingTimeInSeconds,
    required this.rideRequest,
  });

  SearchingDrivers copyWith({
    List<Driver>? availableDrivers,
    String? vehicleType,
    int? remainingTimeInSeconds,
    RideRequest? rideRequest,
  }) {
    return SearchingDrivers(
      availableDrivers: availableDrivers ?? this.availableDrivers,
      vehicleType: vehicleType ?? this.vehicleType,
      remainingTimeInSeconds:
          remainingTimeInSeconds ?? this.remainingTimeInSeconds,
      rideRequest: rideRequest ?? this.rideRequest,
    );
  }
}

class TrackingStarted extends RideConfirmationState {
  final Driver driver;
  final RideRequest rideRequest;

  const TrackingStarted({required this.driver, required this.rideRequest});
}

class DriverPositionUpdated extends RideConfirmationState {
  final Position position;
  final Driver driver;
  final RideRequest rideRequest;

  const DriverPositionUpdated(
      {required this.position,
      required this.driver,
      required this.rideRequest});
}

class DriverArrived extends RideConfirmationState {
  final Position position;
  final Driver driver;
  final RideRequest rideRequest;

  const DriverArrived({
    required this.position,
    required this.driver,
    required this.rideRequest,
  });
}

class FullRideStarted extends RideConfirmationState {
  final Driver driver;
  final RideRequest rideRequest;

  const FullRideStarted({required this.rideRequest, required this.driver});
}

// État quand aucun driver n'accepte la course
class NoDriversFound extends RideConfirmationState {
  final String reason; // Raison (timeout, refus, etc.)

  const NoDriversFound(this.reason);

  @override
  List<Object?> get props => [reason];
}

// État en cas d'erreur
class RideConfirmationError extends RideConfirmationState {
  final String message;

  const RideConfirmationError(this.message);

  @override
  List<Object?> get props => [message];
}

// État quand l'utilisateur annule
class RideConfirmationCancelled extends RideConfirmationState {}
